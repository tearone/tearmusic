import 'dart:convert';
import 'dart:developer';

import 'package:tearmusic/api/base_api.dart';
import 'package:http/http.dart' as http;
import 'package:tearmusic/exceptionts.dart';
import 'package:tearmusic/models/library.dart';
import 'package:tearmusic/models/user_info.dart';

class UserApi {
  UserApi({required this.base});

  BaseApi base;

  void _reschk(http.Response res, String cause) {
    cause = "UserApi.$cause";
    if (res.statusCode == 401) {
      throw AuthException(cause);
    }
    if (res.statusCode == 404) {
      throw NotFoundException(cause);
    }
    if (res.statusCode != 200) {
      log("Unknown Request: ${res.statusCode}");
      throw UnknownRequestException(cause);
    }
  }

  Future<UserInfo> getInfo() async {
    final res = await http.get(
      Uri.parse("${BaseApi.url}/user/info"),
      headers: {"authorization": await base.getToken()},
    );

    _reschk(res, "getInfo");

    return UserInfo.decode(jsonDecode(res.body));
  }

  Future<UserLibrary> getLibrary() async {
    final res = await http.get(
      Uri.parse("${BaseApi.url}/user/music-library"),
      headers: {"authorization": await base.getToken()},
    );

    _reschk(res, "getLibrary");

    return UserLibrary.decode(jsonDecode(res.body));
  }

  Future<void> putLibrary(String id, LibraryType type) async {
    final res = await http.put(Uri.parse("${BaseApi.url}/user/music-library"),
        headers: {"authorization": await base.getToken(), "content-type": "application/json"}, body: jsonEncode({"id": id, "type": type.name}));

    _reschk(res, "putLibrary");
  }

  Future<void> deleteLibrary(String id, LibraryType type) async {
    final res = await http.delete(Uri.parse("${BaseApi.url}/user/music-library"),
        headers: {"authorization": await base.getToken(), "content-type": "application/json"}, body: jsonEncode({"id": id, "type": type.name}));

    _reschk(res, "deleteLibrary");
  }
}
