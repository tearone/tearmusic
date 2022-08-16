import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tearmusic/api/base_api.dart';
import 'package:tearmusic/api/user_api.dart';
import 'package:tearmusic/exceptionts.dart';
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
  String get username => _username ?? "";
  String get avatar => _avatar ?? "";

  Future<void> logoutCallback() async {
    _api.base.destroyToken();

    _store.delete("username");
    _store.delete("avatar");
    _store.delete("access_token");
    _store.delete("refresh_token");

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

      _username = user.username;
      _avatar = user.avatar;
      _id = user.id;
      notifyListeners();

      _musicInfoProvider.userId = _id ?? "";

      _store.put("username", _username);
      _store.put("avatar", _avatar);
      _store.put("id", _id);
    } on AuthException {
      loggedIn = false;
      notifyListeners();
    }
  }
}
