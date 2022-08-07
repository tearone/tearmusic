import 'dart:convert';

import 'package:tearmusic/api/base_api.dart';
import 'package:http/http.dart' as http;
import 'package:tearmusic/exceptionts.dart';
import 'package:tearmusic/models/music/search_results.dart';

class MusicApi {
  MusicApi({required this.base});

  BaseApi base;

  Future<SearchResults> search() async {
    final res = await http.get(
      Uri.parse("${BaseApi.url}/user/info"),
      headers: {"authorization": await base.getToken()},
    );

    if (res.statusCode != 200) {
      throw AuthException("UserApi.getInfo");
    }

    return SearchResults.fromJson(jsonDecode(res.body));
  }
}
