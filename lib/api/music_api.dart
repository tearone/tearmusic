import 'dart:convert';

import 'package:tearmusic/api/base_api.dart';
import 'package:http/http.dart' as http;
import 'package:tearmusic/exceptionts.dart';
import 'package:tearmusic/models/music/album.dart';
import 'package:tearmusic/models/music/playlist.dart';
import 'package:tearmusic/models/music/search_results.dart';
import 'package:tearmusic/models/music/track.dart';

class MusicApi {
  MusicApi({required this.base});

  BaseApi base;

  Future<SearchResults> search(String query) async {
    final res = await http.get(
      Uri.parse("${BaseApi.url}/music/search?query=${Uri.encodeComponent(query)}"),
      headers: {"authorization": await base.getToken()},
    );

    if (res.statusCode != 200) {
      throw AuthException("MusicApi.search");
    }

    return SearchResults.fromJson(jsonDecode(res.body));
  }

  Future<List<MusicTrack>> playlistTracks(MusicPlaylist playlist) async {
    final res = await http.get(
      Uri.parse("${BaseApi.url}/music/playlist-tracks?id=${Uri.encodeComponent(playlist.id)}"),
      headers: {"authorization": await base.getToken()},
    );

    if (res.statusCode != 200) {
      throw AuthException("MusicApi.playlistTracks");
    }

    return jsonDecode(res.body).map((e) => MusicTrack.fromJson(e)).toList().cast<MusicTrack>();
  }

  Future<List<MusicTrack>> albumTracks(MusicAlbum album) async {
    final res = await http.get(
      Uri.parse("${BaseApi.url}/music/album-tracks?id=${Uri.encodeComponent(album.id)}"),
      headers: {"authorization": await base.getToken()},
    );

    if (res.statusCode != 200) {
      throw AuthException("MusicApi.albumTracks");
    }

    return jsonDecode(res.body).where((e) => e['id'] != null).map((e) => MusicTrack.fromJson(e)).toList().cast<MusicTrack>();
  }
}
