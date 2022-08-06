import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class UserProvider extends ChangeNotifier {
  String? _accessToken;
  bool loggedIn = false;

  String? _username;
  String get username => _username ?? "";

  String get accessToken => _accessToken ?? "";

  Future<void> loginCallback(String? accessToken, String? refreshToken) async {
    if (accessToken == null || refreshToken == null) return;

    _accessToken = accessToken;

    final res = await http.get(
      Uri.parse("https://api.tear.one/user/info"),
      headers: {"authorization": accessToken},
    );

    _username = jsonDecode(res.body)['username'];

    notifyListeners();
  }
}
