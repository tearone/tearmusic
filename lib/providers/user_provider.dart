import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tearmusic/api/base_api.dart';
import 'package:tearmusic/api/user_api.dart';
import 'package:tearmusic/exceptionts.dart';

class UserProvider extends ChangeNotifier {
  UserProvider({required BaseApi base}) : _api = UserApi(base: base);

  Future<void> init() async {
    _store = await Hive.openBox("user");
    _username = _store.get("username");
    _avatar = _store.get("avatar");

    String? accessToken = _store.get("access_token");
    String? refreshToken = _store.get("refresh_token");

    _api.base.setAuth(accessToken, refreshToken);

    if (accessToken != null) loggedIn = true;
    notifyListeners();

    _getUser();
  }

  late Box _store;
  final UserApi _api;

  bool loggedIn = false;

  String? _username;
  String? _avatar;
  String get username => _username ?? "";
  String get avatar => _avatar ?? "";

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
      notifyListeners();

      _store.put("username", _username);
      _store.put("avatar", _avatar);
    } on AuthException {
      loggedIn = false;
      notifyListeners();
    }
  }
}
