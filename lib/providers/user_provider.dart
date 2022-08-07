import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

class UserProvider extends ChangeNotifier {
  UserProvider() {
    Hive.openBox("user").then((value) {
      _store = value;
      _accessToken = _store.get("access_token");
      _username = _store.get("username");
      _avatar = _store.get("avatar");

      if (_accessToken != null) loggedIn = true;
      notifyListeners();

      _getUser();
    });
  }

  late Box _store;

  String? _accessToken;
  bool loggedIn = false;

  String? _username;
  String? _avatar;
  String get username => _username ?? "";
  String get avatar => _avatar ?? "";

  String get accessToken => _accessToken ?? "";

  Future<void> loginCallback(String? accessToken, String? refreshToken) async {
    if (accessToken == null || refreshToken == null) return;

    _store.put("access_token", accessToken);
    _store.put("refresh_token", refreshToken);

    _accessToken = accessToken;
    notifyListeners();

    await _getUser();
  }

  Future<void> _getUser() async {
    final res = await http.get(
      Uri.parse("https://api.tear.one/user/info"),
      headers: {"authorization": accessToken},
    );

    final json = jsonDecode(res.body);

    _username = json['username'];
    _avatar = json['avatar'];
    notifyListeners();

    _store.put("username", _username);
    _store.put("avatar", _avatar);
  }
}
