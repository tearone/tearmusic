import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tearmusic/api/base_api.dart';
import 'package:tearmusic/api/user_api.dart';
import 'package:tearmusic/exceptionts.dart';
import 'package:tearmusic/models/library.dart';
import 'package:tearmusic/models/model.dart';
import 'package:tearmusic/models/music/playlist.dart';
import 'package:tearmusic/models/music/track.dart';
import 'package:tearmusic/models/player_info.dart';
import 'package:tearmusic/providers/current_music_provider.dart';
import 'package:tearmusic/providers/music_info_provider.dart';

class UserProvider extends ChangeNotifier {
  UserProvider({required BaseApi base, required MusicInfoProvider musicInfo})
      : _api = UserApi(base: base),
        _musicInfoProvider = musicInfo;

  void setCurrentMusicProvider(CurrentMusicProvider currentMusicProvider) {
    _currentMusicProvider = currentMusicProvider;
  }

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

    //try {
    final stPlayerInfo = _store.get("player_info");
    if (stPlayerInfo != null) playerInfo = PlayerInfo.decode(jsonDecode(stPlayerInfo));
    // } catch (e) {
    //   log("Player Info decode error: $e");
    // }

    String? accessToken = _store.get("access_token");
    String? refreshToken = _store.get("refresh_token");

    _api.base.refreshCallback = loginCallback;
    _api.base.setAuth(accessToken, refreshToken);
    _musicInfoProvider.userId = _id ?? "";

    if (accessToken != null) loggedIn = true;
    notifyListeners();

    if (loggedIn) _getUser();
  }

  late Box _store;
  final UserApi _api;
  final MusicInfoProvider _musicInfoProvider;
  late final CurrentMusicProvider _currentMusicProvider;

  bool loggedIn = false;

  String? _id;
  String? _username;
  String? _avatar;
  UserLibrary? library;
  PlayerInfo playerInfo = PlayerInfo(version: 0, queueSource: QueueSource(type: PlayerInfoSourceType.radio));

  Timer playerSyncTimer = Timer(const Duration(seconds: 0), () {});

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

      _username = user.username;
      _avatar = user.avatar;
      _id = user.id;
      library = lib;
      notifyListeners();

      _musicInfoProvider.userId = _id ?? "";

      _store.put("username", _username);
      _store.put("avatar", _avatar);
      _store.put("id", _id);
      _store.put("library", jsonEncode(library!.encode()));

      await matchPlayerInfo();
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
  // QUEUE STUFF

  List<String> getAllTracks({includeHistory = true, includeCurrent = true}) {
    return (playerInfo.normalQueue + playerInfo.primaryQueue + (includeHistory ? playerInfo.queueHistory.map((e) => e.id).toList() : []))
        .toSet()
        .toList();
  }

  Future<void> matchPlayerInfo() async {
    log("[Player] matchPlayerInfo all queued tracks: ${getAllTracks()}");

    // caching tracks
    await _musicInfoProvider.batchTracks(getAllTracks());

    final playerVersion = await _api.getPlayerVersion();

    if (playerVersion == playerInfo.version) {
      log("[Player] matchPlayerInfo version match: $playerVersion");
      playerInfo.operations.clear();
      playerInfo.operationsVersion = playerVersion;
    } else {
      log("[Player] matchPlayerInfo version mismatch: $playerVersion - ${playerInfo.version}");

      if (playerVersion < playerInfo.version) {
        if (playerVersion != playerInfo.operationsVersion) {
          log("[Player] matchPlayerInfo operations version not matches, overwriting");

          playerInfo.operations.clear();
          playerInfo.operationsVersion = playerInfo.version;
          postOverwrite(playerInfo.version);
        } else {
          await syncPlayerOperations();
        }
      } else {
        log("[Player] matchPlayerInfo cloud version is newer, syncing");

        playerInfo = await _api.getPlayerInfo();
      }
    }

    if (playerInfo.currentMusic != null) {
      final currentTrack = await _musicInfoProvider.batchTracks([playerInfo.currentMusic!.id]);

      if (currentTrack.isNotEmpty) {
        log("[Player] Playing current music: ${currentTrack.first}");
        _currentMusicProvider.playTrack(currentTrack.first, startInstant: false);
      } else {
        log("[Player] Failed to play current music because is empty");
      }
    }

    log("[Player] matched info: ${playerInfo.encode()}");
  }

  void _stackPlayerOperation(Map body, int newVersion) {
    if (playerInfo.operations.isEmpty) {
      playerInfo.operationsVersion = playerInfo.version;
    }
    playerInfo.version = newVersion;
    log("[Player] operation version is: ${playerInfo.operationsVersion} - new version is: $newVersion");
    playerInfo.operations.add(body);

    //log("[Player] starting operations sync timer with operations: ${playerInfo.operations}");

    if (playerSyncTimer.isActive) playerSyncTimer.cancel();

    playerSyncTimer = Timer(const Duration(seconds: 3), () {
      log("[Player] pushing operations to db");

      syncPlayerOperations();

      playerSyncTimer.cancel();
    });
  }

  Future<void> syncPlayerOperations() async {
    final isSuccess = await _api.syncPlayerOperations(playerInfo);

    log("[Player] ${isSuccess ? 'Success to' : 'Failed to'} sync player operations: ${playerInfo.operations}");
    log("[Player] new queue: ${getAllTracks(includeHistory: false)}");

    playerInfo.operations.clear();
    playerInfo.operationsVersion = playerInfo.version;
    if (!isSuccess) {
      log("[Player] failed to sync, overwriting with version: ${playerInfo.version}");

      postOverwrite(playerInfo.version);
    }

    _store.put("player_info", jsonEncode(playerInfo.encode()));
  }

  void postAdd(String id, int newVersion, {PlayerInfoPostType whereTo = PlayerInfoPostType.normal, bool fromPrimary = false, bool toStart = false}) {
    switch (whereTo) {
      case PlayerInfoPostType.primary:
        if (toStart) {
          playerInfo.primaryQueue.insert(0, id);
        } else {
          playerInfo.primaryQueue.add(id);
        }
        break;
      case PlayerInfoPostType.history:
        final item = QueueItem(id: id, fromPrimary: fromPrimary);

        playerInfo.queueHistory.add(item);
        break;
      case PlayerInfoPostType.normal:
        if (toStart) {
          playerInfo.normalQueue.insert(0, id);
        } else {
          playerInfo.normalQueue.add(id);
        }
        break;
      case PlayerInfoPostType.current:
        break;
    }

    final body = {"type": "add", "id": id, "where_to": whereTo.name, "from_primary": fromPrimary, "to_start": toStart};
    _stackPlayerOperation(body, newVersion);
  }

  void postRemove(int index, int newVersion, {PlayerInfoPostType removeFrom = PlayerInfoPostType.normal}) {
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
      case PlayerInfoPostType.current:
        break;
    }
    final body = {"type": "remove", "index": index, "remove_from": removeFrom.name};
    _stackPlayerOperation(body, newVersion);
  }

  void postReorder(int fromIndex, int toIndex, int newVersion,
      {PlayerInfoReorderMoveType moveFrom = PlayerInfoReorderMoveType.normal, PlayerInfoReorderMoveType moveTo = PlayerInfoReorderMoveType.normal}) {
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

    final body = {"type": "reorder", "from_index": fromIndex, "to_index": toIndex, "move_from": moveFrom, "move_to": moveTo};
    _stackPlayerOperation(body, newVersion);
  }

  void postOverwrite(int newVersion) {
    final body = {
      "type": "overwrite",
      "new_normal_queue": playerInfo.normalQueue,
      "new_primary_queue": playerInfo.primaryQueue,
      "new_queue_history": playerInfo.queueHistory.map((e) => e.encode()).toList(),
    };
    _stackPlayerOperation(body, newVersion);
  }

  void postCurrentMusic(String id, int newVersion, {bool fromPrimary = false}) {
    final body = {"type": "current", "id": id, "from_primary": fromPrimary};

    playerInfo.currentMusic = QueueItem(id: id, fromPrimary: fromPrimary);

    _stackPlayerOperation(body, newVersion);
  }

  void postClear(PlayerInfoPostType type, int newVersion) {
    final body = {"type": "current", "clear_type": type.name};

    switch (type) {
      case PlayerInfoPostType.primary:
        playerInfo.primaryQueue.clear();
        break;
      case PlayerInfoPostType.normal:
        playerInfo.normalQueue.clear();
        break;
      case PlayerInfoPostType.history:
        playerInfo.queueHistory.clear();
        break;
      case PlayerInfoPostType.current:
        playerInfo.currentMusic = null;
        break;
    }

    _stackPlayerOperation(body, newVersion);
  }

  void postSource(String id, int seed, PlayerInfoSourceType type, List<MusicTrack> tracks, int newVersion) {
    final body = {"type": "source", "id": id, "seed": seed, "source_type": type.name, "tracks": tracks.map((e) => e.id).toList()};

    switch (type) {
      case PlayerInfoSourceType.playlist:
        playerInfo.currentMusic = QueueItem(id: tracks[0].id, fromPrimary: false);
        playerInfo.normalQueue = tracks.map((e) => e.id).toList();
        playerInfo.normalQueue.removeAt(0);
        playerInfo.queueHistory = [];

        _currentMusicProvider.playTrack(tracks[0]);
        break;
      case PlayerInfoSourceType.album:
        break;
      case PlayerInfoSourceType.artist:
        break;
      case PlayerInfoSourceType.radio:
        break;
    }

    _stackPlayerOperation(body, newVersion);
  }

  Future<void> queuePlaylist(MusicPlaylist playlist) async {
    final seed = randomBetween(10000, 99999);

    final playlistDetails = await _musicInfoProvider.playlistTracks(playlist);

    playlistDetails.tracks.shuffle(math.Random(seed));

    // TODO: queue source is radio if length < 50

    final queueTracks = playlistDetails.tracks.sublist(0, playlistDetails.tracks.length.clamp(0, 50));

    playerInfo.normalQueue = queueTracks.map((e) => e.id).toList();

    postSource(playlist.id, seed, PlayerInfoSourceType.playlist, queueTracks, DateTime.now().millisecondsSinceEpoch);
  }

  void skipToPrev() {
    final queueHistory = playerInfo.queueHistory;

    final newVersion = DateTime.now().millisecondsSinceEpoch;

    QueueItem nextToPlay;

    if (playerInfo.queueHistory.isNotEmpty) {
      nextToPlay = queueHistory.last;

      final currentMusic = playerInfo.currentMusic!;

      postRemove(queueHistory.length - 1, newVersion, removeFrom: PlayerInfoPostType.history);
      postAdd(currentMusic.id, newVersion,
          whereTo: currentMusic.fromPrimary ? PlayerInfoPostType.primary : PlayerInfoPostType.normal, toStart: true);

      // if we want "skip" and "prev" track always be the same, we need to add the track to primary:
      // postAdd(currentMusic.id, newVersion,
      //     whereTo: PlayerInfoPostType.primary, toStart: true);
    } else {
      return;
    }

    postCurrentMusic(nextToPlay.id, DateTime.now().millisecondsSinceEpoch, fromPrimary: true);

    log("[Player State] next to play from history: $nextToPlay");

    playTrackById(nextToPlay.id, nextToPlay.fromPrimary);
  }

  void skipToNext() {
    final primaryQueue = playerInfo.primaryQueue;
    final normalQueue = playerInfo.normalQueue;

    final newVersion = DateTime.now().millisecondsSinceEpoch;

    var nextToPlay = "";
    var fromPrimary = true;

    var currentMusicId = playerInfo.currentMusic!.id;

    if (primaryQueue.isNotEmpty) {
      nextToPlay = primaryQueue.first;

      postAdd(currentMusicId, newVersion, whereTo: PlayerInfoPostType.history, fromPrimary: true);
      postRemove(0, newVersion, removeFrom: PlayerInfoPostType.primary);
    } else if (normalQueue.isNotEmpty) {
      nextToPlay = normalQueue.first;

      fromPrimary = false;

      postAdd(currentMusicId, newVersion, whereTo: PlayerInfoPostType.history);
      postRemove(0, newVersion);
    } else {
      return;
    }

    postCurrentMusic(nextToPlay, DateTime.now().millisecondsSinceEpoch, fromPrimary: true);

    log("[Player State] next to play from queue: $nextToPlay");

    playTrackById(nextToPlay, fromPrimary);
  }

  void playTrackById(String id, bool fromPrimary) {
    _currentMusicProvider.seek(Duration.zero);

    final playTrack = _musicInfoProvider.batchTracks([id]);
    playTrack.then((value) {
      _currentMusicProvider.playTrack(value.first, fromPrimary: fromPrimary);
    });
  }
}

bool checkCorrectIndex(int type, int index, List list) {
  return !(index < 0 || (type == 0 ? index >= list.length : index > list.length));
}

int randomBetween(int min, int max) => min + math.Random().nextInt((max + 1) - min);
