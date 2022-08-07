import 'dart:convert';

import 'package:tearmusic/api/base_api.dart';
import 'package:http/http.dart' as http;
import 'package:tearmusic/exceptionts.dart';
import 'package:tearmusic/models/user_info.dart';

class UserApi {
  UserApi({required this.base});

  BaseApi base;

  Future<UserInfo> getInfo() async {
    final res = await http.get(
      Uri.parse("${BaseApi.url}/user/info"),
      headers: {"authorization": await base.getToken()},
    );

    if (res.statusCode != 200) {
      throw AuthException("UserApi.getInfo");
    }

    return UserInfo.fromJson(jsonDecode(res.body));
  }
}
