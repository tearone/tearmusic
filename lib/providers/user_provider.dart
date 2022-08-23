import 'dart:convert';
import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tearmusic/api/base_api.dart';
import 'package:tearmusic/api/user_api.dart';
import 'package:tearmusic/exceptionts.dart';
import 'package:tearmusic/models/library.dart';
import 'package:tearmusic/models/model.dart';
import 'package:tearmusic/models/player_info.dart';
import 'package:tearmusic/providers/music_info_provider.dart';

class UserProvider extends ChangeNotifier {
  UserProvider({required BaseApi base, required MusicInfoProvider musicInfo})
      : _api = UserApi(base: base),
        _musicInfoProvider = musicInfo;

  Future<void> init() async {
    _store = await Hive.openBox("user");
    _username = _store.get("username");
    _avatar = _store.get("avatar");
    _id = _store.get("id");

    try {
      final stLibrary = _store.get("library");
      if (stLibrary != null) library = UserLibrary.decode(jsonDecode(stLibrary));
    } catch (e) {
      log("Library decode error: $e");
    }

    try {
      final stPlayerInfo = _store.get("player_info");
      if (stPlayerInfo != null) playerInfo = PlayerInfo.decode(jsonDecode(stPlayerInfo));
    } catch (e) {
      log("Player Info decode error: $e");
    }

    String? accessToken = _store.get("access_token");
    String? refreshToken = _store.get("refresh_token");

    _api.base.refreshCallback = loginCallback;
    _api.base.setAuth(accessToken, refreshToken);
    _musicInfoProvider.userId = _id ?? "";

    if (accessToken != null) loggedIn = true;
    notifyListeners();

    _getUser();
  }

  late Box _store;
  final UserApi _api;
  final MusicInfoProvider _musicInfoProvider;

  bool loggedIn = false;

  String? _id;
  String? _username;
  String? _avatar;
  UserLibrary? library;
  PlayerInfo playerInfo = PlayerInfo(version: 0);
  String get username => _username ?? "";
  String get avatar => _avatar ?? "";

  Future<void> logoutCallback() async {
    _api.base.destroyToken();

    _store.delete("username");
    _store.delete("avatar");
    _store.delete("access_token");
    _store.delete("refresh_token");
    _store.delete("library");
    _store.delete("player_info");

    final cacheBox = await Hive.openBox("cached_images");
    cacheBox.clear();

    loggedIn = false;

    notifyListeners();
  }

  Future<void> loginCallback(String? accessToken, String? refreshToken) async {
    if (accessToken == null || refreshToken == null) return;

    _store.put("access_token", accessToken);
    _store.put("refresh_token", refreshToken);

    _api.base.setAuth(accessToken, refreshToken);
    notifyListeners();

    await _getUser();
  }

  Future<void> _getUser() async {
    try {
      final user = await _api.getInfo();
      final lib = await _api.getLibrary();
      final pinfo = await _api.getPlayerInfo();

      _username = user.username;
      _avatar = user.avatar;
      _id = user.id;
      library = lib;
      playerInfo = pinfo;
      notifyListeners();

      _musicInfoProvider.userId = _id ?? "";

      _store.put("username", _username);
      _store.put("avatar", _avatar);
      _store.put("id", _id);
      _store.put("library", jsonEncode(library!.encode()));
      _store.put("player_info", jsonEncode(playerInfo.encode()));
    } on AuthException {
      loggedIn = false;
      notifyListeners();
    }
  }

  Future<UserLibrary> getLibrary() async {
    if (library == null) {
      library = await _api.getLibrary();
      _store.put("library", jsonEncode(library!.encode()));
    }

    return library!;
  }

  Future<void> putLibrary(Model model, LibraryType type, {String? fromId, String? fromType}) async {
    await getLibrary();

    final id = model.id;

    switch (type) {
      case LibraryType.liked_tracks:
        if (library!.liked_tracks.contains(id)) return;
        library!.liked_tracks = [...library!.liked_tracks, id];
        break;
      case LibraryType.liked_artists:
        if (library!.liked_artists.contains(id)) return;
        library!.liked_artists = [...library!.liked_artists, id];
        break;
      case LibraryType.liked_albums:
        if (library!.liked_albums.contains(id)) return;
        library!.liked_albums = [...library!.liked_albums, id];
        break;
      case LibraryType.liked_playlists:
        if (library!.liked_playlists.contains(id)) return;
        library!.liked_playlists = [...library!.liked_playlists, id];
        break;
      case LibraryType.track_history:
        library!.track_history = library!.track_history
            .where((item) => item.track_id != id)
            .toList()
            .sublist((library!.track_history.length - 49).clamp(0, 49), library!.track_history.isEmpty ? 0 : library!.track_history.length - 1)
          ..add(UserTrackHistory(date: DateTime.now().millisecondsSinceEpoch, track_id: id, from_id: fromId, from_type: fromType));
        break;
    }

    await _api.putLibrary(id, type);
    _store.put("library", jsonEncode(library!.encode()));

    notifyListeners();
  }

  Future<void> deleteLibrary(Model model, LibraryType type) async {
    await getLibrary();

    final id = model.id;

    switch (type) {
      case LibraryType.liked_tracks:
        if (!library!.liked_tracks.contains(id)) return;
        library!.liked_tracks = library!.liked_tracks.where((l) => l != id).toList();
        break;
      case LibraryType.liked_artists:
        if (!library!.liked_artists.contains(id)) return;
        library!.liked_artists = library!.liked_artists.where((l) => l != id).toList();
        break;
      case LibraryType.liked_albums:
        if (!library!.liked_albums.contains(id)) return;
        library!.liked_albums = library!.liked_albums.where((l) => l != id).toList();
        break;
      case LibraryType.liked_playlists:
        if (!library!.liked_playlists.contains(id)) return;
        library!.liked_playlists = library!.liked_playlists.where((l) => l != id).toList();
        break;
      case LibraryType.track_history:
        break;
    }

    await _api.deleteLibrary(id, type);
    _store.put("library", jsonEncode(library!.encode()));

    notifyListeners();
  }

  // QUEUE STUFF

  void _stackPlayerOperation(Map body, {int? newVersion}) {
    playerInfo.operations.add(body);
    if (newVersion != null) playerInfo.version = newVersion;
  }

  void postAdd(String id, {PlayerInfoPostType whereTo = PlayerInfoPostType.normal, fromPrimary = false, int? newVersion}) {
    switch (whereTo) {
      case PlayerInfoPostType.primary:
        playerInfo.primaryQueue.add(id);
        break;
      case PlayerInfoPostType.normal:
        playerInfo.queueHistory.add(QueueHistory(id: id, fromPrimary: fromPrimary));
        break;
      case PlayerInfoPostType.history:
        playerInfo.normalQueue.add(id);
        break;
    }

    final body = {"id": id, "where_to": whereTo.name, "from_primary": fromPrimary};
    _stackPlayerOperation(body, newVersion: newVersion);
  }

  void postRemove(int index, {PlayerInfoPostType removeFrom = PlayerInfoPostType.normal, int? newVersion}) {
    switch (removeFrom) {
      case PlayerInfoPostType.primary:
        if (checkCorrectIndex(0, index, playerInfo.primaryQueue)) playerInfo.primaryQueue.removeAt(index);
        break;
      case PlayerInfoPostType.normal:
        if (checkCorrectIndex(0, index, playerInfo.normalQueue)) playerInfo.normalQueue.removeAt(index);
        break;
      case PlayerInfoPostType.history:
        if (checkCorrectIndex(0, index, playerInfo.queueHistory)) playerInfo.queueHistory.removeAt(index);
        break;
    }
    final body = {"index": index, "remove_from": removeFrom.name};
    _stackPlayerOperation(body, newVersion: newVersion);
  }

  void postReorder(int fromIndex, int toIndex,
      {PlayerInfoReorderMoveType moveFrom = PlayerInfoReorderMoveType.normal,
      PlayerInfoReorderMoveType moveTo = PlayerInfoReorderMoveType.normal,
      int? newVersion}) {
    String moveId;

    if (moveFrom == PlayerInfoReorderMoveType.primary) {
      if (checkCorrectIndex(0, fromIndex, playerInfo.primaryQueue)) return;

      moveId = playerInfo.primaryQueue[fromIndex];
      playerInfo.primaryQueue.removeAt(fromIndex);
    } else {
      if (checkCorrectIndex(0, fromIndex, playerInfo.normalQueue)) return;

      moveId = playerInfo.normalQueue[fromIndex];
      playerInfo.normalQueue.removeAt(fromIndex);
    }

    if (moveTo == PlayerInfoReorderMoveType.primary) {
      if (checkCorrectIndex(1, toIndex, playerInfo.primaryQueue)) return;

      playerInfo.primaryQueue.insert(toIndex, moveId);
    } else {
      if (checkCorrectIndex(1, toIndex, playerInfo.normalQueue)) return;

      playerInfo.normalQueue.insert(toIndex, moveId);
    }

    final body = {"from_index": fromIndex, "to_index": toIndex, "move_from": moveFrom, "move_to": moveTo};
    _stackPlayerOperation(body, newVersion: newVersion);
  }

  void postOverwrite({int? newVersion}) {
    final body = {
      "new_normal_queue": playerInfo.normalQueue,
      "new_primary_queue": playerInfo.primaryQueue,
      "new_queue_history": playerInfo.queueHistory
    };
    _stackPlayerOperation(body, newVersion: newVersion);
  }
}

bool checkCorrectIndex(int type, int index, List list) {
  return (index < 0 || (type == 0 ? index >= list.length : index > list.length));
}
