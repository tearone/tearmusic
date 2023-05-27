import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:tearmusic/api/base_api.dart';
import 'package:http/http.dart' as http;
import 'package:tearmusic/exceptionts.dart';
import 'package:tearmusic/models/batch.dart';
import 'package:tearmusic/models/library.dart';
import 'package:tearmusic/models/manual_match.dart';
import 'package:tearmusic/models/music/album.dart';
import 'package:tearmusic/models/music/artist.dart';
import 'package:tearmusic/models/music/lyrics.dart';
import 'package:tearmusic/models/music/playlist.dart';
import 'package:tearmusic/models/search.dart';
import 'package:tearmusic/models/music/track.dart';
import 'package:tearmusic/models/playback.dart';

class MusicApi {
  MusicApi({required this.base});

  BaseApi base;

  static const baseUrl = "http://localhost:3000/api";

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

  Future<List<SearchSuggestion>> searchSuggest(String query) async {
    final res = await http.get(
      Uri.parse("$baseUrl/music/search-suggest?query=${Uri.encodeComponent(query)}"),
      headers: {"authorization": await base.getToken()},
    );

    _reschk(res, "searchSuggest");

    final json = (jsonDecode(res.body) as List).cast<List>();
    return SearchSuggestion.decodeList(json);
  }

  Future<SearchResults> search(String query) async {
    final res = await http.get(
      Uri.parse("$baseUrl/music/search?query=${Uri.encodeComponent(query)}"),
      headers: {"authorization": await base.getToken()},
    );

    _reschk(res, "search");
    return SearchResults.decode(jsonDecode(res.body));
  }

  Future<PlaylistDetails> playlistTracks(String playlistId) async {
    final res = await http.get(
      Uri.parse("$baseUrl/music/playlist-tracks?id=${Uri.encodeComponent(playlistId)}"),
      headers: {"authorization": await base.getToken()},
    );

    _reschk(res, "playlistTracks");
    return PlaylistDetails.decode(jsonDecode(res.body));
  }

  Future<List<MusicTrack>> albumTracks(String albumId, {MusicAlbum? album}) async {
    final res = await http.get(
      Uri.parse("$baseUrl/music/album-tracks?id=${Uri.encodeComponent(albumId)}${album == null ? '&fetchAlbum' : ''}"),
      headers: {"authorization": await base.getToken()},
    );

    _reschk(res, "albumTracks");

    final bodyJson = jsonDecode(res.body);

    final json = (bodyJson['tracks'] as List).cast<Map>();
    return MusicTrack.decodeList(json, album: album ?? MusicAlbum.decode(bodyJson["album"]));
  }

  Future<List<MusicAlbum>> newReleases() async {
    final res = await http.get(
      Uri.parse("$baseUrl/music/new-releases"),
      headers: {"authorization": await base.getToken()},
    );

    _reschk(res, "newReleases");

    final json = (jsonDecode(res.body)['albums'] as List).cast<Map>();
    return MusicAlbum.decodeList(json);
  }

  Future<List<MusicAlbum>> artistAlbums(MusicArtist artist) async {
    final res = await http.get(
      Uri.parse("$baseUrl/music/artist-albums?id=${Uri.encodeComponent(artist.id)}"),
      headers: {"authorization": await base.getToken()},
    );

    _reschk(res, "artistAlbums");

    final json = (jsonDecode(res.body)['albums'] as List).cast<Map>();
    return MusicAlbum.decodeList(json);
  }

  Future<List<MusicTrack>> artistTracks(MusicArtist artist) async {
    final res = await http.get(
      Uri.parse("$baseUrl/music/artist-tracks?id=${Uri.encodeComponent(artist.id)}"),
      headers: {"authorization": await base.getToken()},
    );

    _reschk(res, "artistTracks");

    final json = (jsonDecode(res.body)['tracks'] as List).cast<Map>();
    return MusicTrack.decodeList(json);
  }

  Future<List<MusicArtist>> artistRelated(MusicArtist artist) async {
    final res = await http.get(
      Uri.parse("$baseUrl/music/artist-related?id=${Uri.encodeComponent(artist.id)}"),
      headers: {"authorization": await base.getToken()},
    );

    _reschk(res, "artistRelated");

    final json = (jsonDecode(res.body)['artists'] as List).cast<Map>();
    return MusicArtist.decodeList(json);
  }

  Future<ArtistDetails> artistDetails(MusicArtist artist) async {
    final res = await http.get(
      Uri.parse("$baseUrl/music/artist?id=${Uri.encodeComponent(artist.id)}"),
      headers: {"authorization": await base.getToken()},
    );

    _reschk(res, "artistDetails");

    final json = jsonDecode(res.body);
    final related = (json['artists'] as List).cast<Map>();
    final tracks = (json['tracks'] as List).cast<Map>();
    final albumsJson = (json['albums'] as List).cast<Map>();

    List<MusicAlbum> albums = MusicAlbum.decodeList(albumsJson);
    albums.sort((a, b) => b.releaseDate.compareTo(a.releaseDate));

    return ArtistDetails(
      artist: MusicArtist.decode(json['artist']),
      tracks: MusicTrack.decodeList(tracks),
      albums: albums.where((e) => e.artists.first == artist).toList(),
      appearsOn: albums.where((e) => e.artists.first != artist).toList(),
      related: MusicArtist.decodeList(related),
    );
  }

  Future<MusicLyrics> lyrics(MusicTrack track) async {
    final res = await http.get(
      Uri.parse("$baseUrl/music/lyrics"
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

  Future<Playback> playback(MusicTrack track) async {
    String url = "$baseUrl/music/playback";
    url += "?id=${Uri.encodeComponent(track.id)}";
    url += "&artists=${Uri.encodeComponent(jsonEncode(track.artists.map((e) => e.name).toList()))}";
    url += "&track=${Uri.encodeComponent(track.name)}";
    url += "&duration=${track.duration.inSeconds}";
    url += (track.album != null ? "&album=${Uri.encodeComponent(track.album!.name)}" : "");

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
      Uri.parse("$baseUrl/music/playback?id=${Uri.encodeComponent(track.id)}"),
      headers: {"authorization": await base.getToken()},
    );

    _reschk(res, "purgeCache");
  }

  Future<List<ManualMatch>> manualMatches(MusicTrack track) async {
    final res = await http.get(
      Uri.parse("$baseUrl/music/manual-matches?id=${Uri.encodeComponent(track.id)}"),
      headers: {"authorization": await base.getToken()},
    );

    _reschk(res, "manualMatches");

    final json = (jsonDecode(res.body)['matches'] as List).cast<Map>();
    return ManualMatch.decodeList(json);
  }

  Future<void> matchManual(MusicTrack track, String videoId) async {
    final res = await http.post(
      Uri.parse("$baseUrl/music/manual-matches?id=${Uri.encodeComponent(track.id)}&video_id=${Uri.encodeComponent(videoId)}"),
      headers: {"authorization": await base.getToken()},
    );

    _reschk(res, "matchManual");
  }

  Future<BatchLibrary> libraryBatch(LibraryType type, {int limit = 10, int offset = 0}) async {
    final res = await http.get(
      Uri.parse("$baseUrl/music/batch-library?limit=$limit&offset=$offset&type=${Uri.encodeComponent(type.name)}"),
      headers: {"authorization": await base.getToken()},
    );

    _reschk(res, "libraryBatch");

    return BatchLibrary.decode(jsonDecode(res.body));
  }

  Future<List<MusicTrack>> batchTracks(List<String> idList) async {
    // log("fetching: $idList");

    final res = await http.get(
      Uri.parse("$baseUrl/music/batch-tracks?ids=${idList.join(',')}"),
      headers: {"authorization": await base.getToken()},
    );

    _reschk(res, "batchTracks");

    return jsonDecode(res.body)["tracks"].map((e) => MusicTrack.decode(e)).toList().cast<MusicTrack>();
  }
}
