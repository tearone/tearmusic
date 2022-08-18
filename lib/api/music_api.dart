import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:cbor/simple.dart';
import 'package:tearmusic/api/base_api.dart';
import 'package:http/http.dart' as http;
import 'package:tearmusic/exceptionts.dart';
import 'package:tearmusic/models/music/album.dart';
import 'package:tearmusic/models/music/artist.dart';
import 'package:tearmusic/models/music/lyrics.dart';
import 'package:tearmusic/models/music/playlist.dart';
import 'package:tearmusic/models/music/search_results.dart';
import 'package:tearmusic/models/music/track.dart';
import 'package:tearmusic/models/playback.dart';

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
      log("Unknown Request: ${res.statusCode}");
      throw UnknownRequestException(cause);
    }
  }

  Future<SearchResults> search(String query) async {
    final res = await http.get(
      Uri.parse("${BaseApi.url}/music/search?query=${Uri.encodeComponent(query)}"),
      headers: {"authorization": await base.getToken()},
    );

    _reschk(res, "search");
    return SearchResults.decode(jsonDecode(res.body));
  }

  Future<PlaylistDetails> playlistTracks(MusicPlaylist playlist) async {
    final res = await http.get(
      Uri.parse("${BaseApi.url}/music/playlist-tracks?id=${Uri.encodeComponent(playlist.id)}"),
      headers: {"authorization": await base.getToken()},
    );

    _reschk(res, "playlistTracks");
    return PlaylistDetails.decode(jsonDecode(res.body));
  }

  Future<List<MusicTrack>> albumTracks(MusicAlbum album) async {
    final res = await http.get(
      Uri.parse("${BaseApi.url}/music/album-tracks?id=${Uri.encodeComponent(album.id)}"),
      headers: {"authorization": await base.getToken()},
    );

    _reschk(res, "albumTracks");

    final json = (jsonDecode(res.body)['tracks'] as List).cast<Map>();
    return MusicTrack.decodeList(json, album: album);
  }

  Future<List<MusicAlbum>> newReleases() async {
    final res = await http.get(
      Uri.parse("${BaseApi.url}/music/new-releases"),
      headers: {"authorization": await base.getToken()},
    );

    _reschk(res, "newReleases");

    final json = (jsonDecode(res.body)['albums'] as List).cast<Map>();
    return MusicAlbum.decodeList(json);
  }

  Future<List<MusicAlbum>> artistAlbums(MusicArtist artist) async {
    final res = await http.get(
      Uri.parse("${BaseApi.url}/music/artist-albums?id=${Uri.encodeComponent(artist.id)}"),
      headers: {"authorization": await base.getToken()},
    );

    _reschk(res, "artistAlbums");

    final json = (jsonDecode(res.body)['albums'] as List).cast<Map>();
    return MusicAlbum.decodeList(json);
  }

  Future<List<MusicTrack>> artistTracks(MusicArtist artist) async {
    final res = await http.get(
      Uri.parse("${BaseApi.url}/music/artist-tracks?id=${Uri.encodeComponent(artist.id)}"),
      headers: {"authorization": await base.getToken()},
    );

    _reschk(res, "artistTracks");

    final json = (jsonDecode(res.body)['tracks'] as List).cast<Map>();
    return MusicTrack.decodeList(json);
  }

  Future<List<MusicArtist>> artistRelated(MusicArtist artist) async {
    final res = await http.get(
      Uri.parse("${BaseApi.url}/music/artist-related?id=${Uri.encodeComponent(artist.id)}"),
      headers: {"authorization": await base.getToken()},
    );

    _reschk(res, "artistRelated");

    final json = (jsonDecode(res.body)['artists'] as List).cast<Map>();
    return MusicArtist.decodeList(json);
  }

  Future<MusicLyrics> lyrics(MusicTrack track) async {
    final res = await http.get(
      Uri.parse("${BaseApi.url}/music/lyrics"
          "?artist=${Uri.encodeComponent(track.artists.first.name)}"
          "&track=${Uri.encodeComponent(track.name)}"
          "&duration=${track.duration.inSeconds}"),
      headers: {"authorization": await base.getToken()},
    );

    _reschk(res, "lyrics");

    final json = jsonDecode(res.body) as Map;
    json['id'] = track.id;
    return MusicLyrics.decode(json);
  }

  Future<PlaybackHead> playbackHead(MusicTrack track) async {
    String url = "${BaseApi.url}/music/playback";
    url += "?id=${Uri.encodeComponent(track.id)}";
    url += "&artists=${Uri.encodeComponent(jsonEncode(track.artists.map((e) => e.name).toList()))}";
    url += "&track=${Uri.encodeComponent(track.name)}";
    url += "&duration=${track.duration.inSeconds}";
    url += (track.album != null ? "&album=${Uri.encodeComponent(track.album!.name)}" : "");

    final res = await http.get(
      Uri.parse(url),
      headers: {"authorization": await base.getToken()},
    );

    _reschk(res, "playbackHead");

    final data = cbor.decode(res.bodyBytes);

    return PlaybackHead.decode(data);
  }

  Future<Playback> playback(MusicTrack track, {required String userId, String? videoId, bool sub = true}) async {
    String url = "${BaseApi.url}/music/playback";
    url += "?id=${Uri.encodeComponent(track.id)}";
    if (videoId != null) {
      url += "&video_id=${Uri.encodeComponent(videoId)}";
    } else {
      url += "&artists=${Uri.encodeComponent(jsonEncode(track.artists.map((e) => e.name).toList()))}";
      url += "&track=${Uri.encodeComponent(track.name)}";
      url += "&duration=${track.duration.inSeconds}";
      url += (track.album != null ? "&album=${Uri.encodeComponent(track.album!.name)}" : "");
    }

    final res = await http.post(
      Uri.parse(url),
      headers: {"authorization": await base.getToken()},
    );

    _reschk(res, "playback");

    final data = jsonDecode(res.body);

    return Playback.decode(data);
  }

  Future<void> purgeCache(MusicTrack track) async {
    final res = await http.delete(
      Uri.parse("${BaseApi.url}/music/playback?id=${Uri.encodeComponent(track.id)}"),
      headers: {"authorization": await base.getToken()},
    );

    _reschk(res, "purgeCache");
  }
}
