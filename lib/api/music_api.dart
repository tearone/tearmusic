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

  void _reschk(http.Response res, String cause) {
    cause = "MusicApi.$cause";
    if (res.statusCode == 401) {
      throw AuthException(cause);
    }
    if (res.statusCode == 404) {
      throw NotFoundException(cause);
    }
    if (res.statusCode != 200) {
      throw UnknownRequestException(cause);
    }
  }

  Future<SearchResults> search(String query) async {
    final res = await http.get(
      Uri.parse("${BaseApi.url}/music/search?query=${Uri.encodeComponent(query)}"),
      headers: {"authorization": await base.getToken()},
    );

    _reschk(res, "search");

    return SearchResults.fromJson(jsonDecode(res.body));
  }

  Future<PlaylistDetails> playlistTracks(MusicPlaylist playlist) async {
    final res = await http.get(
      Uri.parse("${BaseApi.url}/music/playlist-tracks?id=${Uri.encodeComponent(playlist.id)}"),
      headers: {"authorization": await base.getToken()},
    );

    _reschk(res, "playlistTracks");

    return PlaylistDetails.fromJson(jsonDecode(res.body));
  }

  Future<List<MusicTrack>> albumTracks(MusicAlbum album) async {
    final res = await http.get(
      Uri.parse("${BaseApi.url}/music/album-tracks?id=${Uri.encodeComponent(album.id)}"),
      headers: {"authorization": await base.getToken()},
    );

    _reschk(res, "albumTracks");

    return jsonDecode(res.body)['tracks'].where((e) => e['id'] != null).map((e) => MusicTrack.fromJson(e)).toList().cast<MusicTrack>();
  }

  Future<List<MusicAlbum>> newReleases() async {
    final res = await http.get(
      Uri.parse("${BaseApi.url}/music/new-releases"),
      headers: {"authorization": await base.getToken()},
    );

    _reschk(res, "newReleases");

    return jsonDecode(res.body)['albums'].map((e) => MusicAlbum.fromJson(e)).toList().cast<MusicAlbum>();
  }

  Future<List<MusicAlbum>> artistAlbums() async {
    final res = await http.get(
      Uri.parse("${BaseApi.url}/music/artist-albums"),
      headers: {"authorization": await base.getToken()},
    );

    _reschk(res, "artistAlbums");

    return jsonDecode(res.body)['albums'].map((e) => MusicAlbum.fromJson(e)).toList().cast<MusicAlbum>();
  }

  Future<List<MusicTrack>> artistTracks() async {
    final res = await http.get(
      Uri.parse("${BaseApi.url}/music/artist-tracks"),
      headers: {"authorization": await base.getToken()},
    );

    _reschk(res, "artistTracks");

    return jsonDecode(res.body)['tracks'].map((e) => MusicTrack.fromJson(e)).toList().cast<MusicTrack>();
  }
}
