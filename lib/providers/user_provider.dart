import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tearmusic/api/base_api.dart';
import 'package:tearmusic/api/user_api.dart';
import 'package:tearmusic/exceptionts.dart';
import 'package:tearmusic/models/library.dart';
import 'package:tearmusic/models/model.dart';
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
    final stLibrary = _store.get("library");
    if(stLibrary != null) _library = UserLibrary.decode(jsonDecode(stLibrary));

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
  UserLibrary? _library;
  String get username => _username ?? "";
  String get avatar => _avatar ?? "";

  Future<void> logoutCallback() async {
    _api.base.destroyToken();

    _store.delete("username");
    _store.delete("avatar");
    _store.delete("access_token");
    _store.delete("refresh_token");
    _store.delete("library");

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
      final library = await _api.getLibrary();

      _username = user.username;
      _avatar = user.avatar;
      _id = user.id;
      _library = library;
      notifyListeners();

      _musicInfoProvider.userId = _id ?? "";

      _store.put("username", _username);
      _store.put("avatar", _avatar);
      _store.put("id", _id);
      _store.put("library", jsonEncode(_library!.encode()));
    } on AuthException {
      loggedIn = false;
      notifyListeners();
    }
  }

  Future<UserLibrary> getLibrary() async {
    if (_library == null) {
      final library = await _api.getLibrary();
      _library = library;
      _store.put("library", jsonEncode(_library!.encode()));
    }

    return _library!;
  }

  Future<void> putLibrary(Model model, LibraryType type) async {
    await getLibrary();

    final id = model.id;

    switch (type) {
      case LibraryType.liked_tracks:
        if (_library!.liked_tracks.contains(id)) return;
        _library!.liked_tracks.add(id);
        break;
      case LibraryType.liked_artists:
        if (_library!.liked_artists.contains(id)) return;
        _library!.liked_artists.add(id);
        break;
      case LibraryType.liked_albums:
        if (_library!.liked_albums.contains(id)) return;
        _library!.liked_albums.add(id);
        break;
      case LibraryType.liked_playlists:
        if (_library!.liked_playlists.contains(id)) return;
        _library!.liked_playlists.add(id);
        break;
      case LibraryType.track_history:
        _library!.track_history = _library!.track_history
            .where((item) => item != id)
            .toList()
            .sublist((_library!.track_history.length - 49).clamp(0, 49), _library!.track_history.length - 1)
          ..add(id);
        break;
    }

    await _api.putLibrary(id, type);
    _store.put("library", jsonEncode(_library!.encode()));
  }

  Future<void> deleteLibrary(Model model, LibraryType type) async {
    await getLibrary();

    final id = model.id;

    switch (type) {
      case LibraryType.liked_tracks:
        if (!_library!.liked_tracks.contains(id)) return;
        _library!.liked_tracks.remove(id);
        break;
      case LibraryType.liked_artists:
        if (!_library!.liked_artists.contains(id)) return;
        _library!.liked_artists.remove(id);
        break;
      case LibraryType.liked_albums:
        if (!_library!.liked_albums.contains(id)) return;
        _library!.liked_albums.remove(id);
        break;
      case LibraryType.liked_playlists:
        if (!_library!.liked_playlists.contains(id)) return;
        _library!.liked_playlists.remove(id);
        break;
      case LibraryType.track_history:
        break;
    }

    await _api.deleteLibrary(id, type);
    _store.put("library", jsonEncode(_library!.encode()));
  }
}
