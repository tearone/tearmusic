import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:tearmusic/api/base_api.dart';
import 'package:tearmusic/api/music_api.dart';
import 'package:tearmusic/models/model.dart';
import 'package:tearmusic/models/music/album.dart';
import 'package:tearmusic/models/music/artist.dart';
import 'package:tearmusic/models/music/lyrics.dart';
import 'package:tearmusic/models/music/playlist.dart';
import 'package:tearmusic/models/music/search_results.dart';
import 'package:tearmusic/models/music/track.dart';

class MusicInfoProvider {
  MusicInfoProvider({required BaseApi base}) : _api = MusicApi(base: base);

  final MusicApi _api;

  /// Box cache keys
  /// List<MusicTrack> "tracks_$track"
  /// List<MusicAlbum> "albums_$album"
  /// List<MusicPlaylist> "playlists_$playlist"
  /// List<MusicArtist> "artists_$artist"
  late Box _store;

  Future<void> init() async {
    _store = await Hive.openBox("music_cache");
    await _store.clear();
  }

  Future<SearchResults> search(String query) async {
    SearchResults data;
    final cacheKey = "search_results_$query";
    final String? cache = _store.get(cacheKey);
    if (cache != null) {
      final json = jsonDecode(cache) as Map;
      List<Map> tracks = [];
      List<Map> albums = [];
      List<Map> playlists = [];
      List<Map> artists = [];
      for (final id in json['tracks']) {
        tracks.add(jsonDecode(_store.get("tracks_$id")));
      }
      for (final id in json['albums']) {
        albums.add(jsonDecode(_store.get("albums_$id")));
      }
      for (final id in json['playlists']) {
        playlists.add(jsonDecode(_store.get("playlists_$id")));
      }
      for (final id in json['artists']) {
        artists.add(jsonDecode(_store.get("artists_$id")));
      }
      data = SearchResults.decode({
        "tracks": tracks,
        "albums": albums,
        "playlists": playlists,
        "artists": artists,
      });
      // Offline search
      // } else if (no internet connection) {
      //   final ids = _store.keys.where((k) => RegExp(r'^((:?tracks|albums|playlists|artists)_[a-zA-Z0-9:-]+)$').hasMatch(k)).cast<String>();
      //   List<Map> tracks = [];
      //   List<Map> albums = [];
      //   List<Map> playlists = [];
      //   List<Map> artists = [];
      //   for (final id in ids.where((k) => k.startsWith("tracks"))) {
      //     tracks.add(jsonDecode(_store.get(id)));
      //   }
      //   for (final id in ids.where((k) => k.startsWith("albums"))) {
      //     albums.add(jsonDecode(_store.get(id)));
      //   }
      //   for (final id in ids.where((k) => k.startsWith("playlists"))) {
      //     playlists.add(jsonDecode(_store.get(id)));
      //   }
      //   for (final id in ids.where((k) => k.startsWith("artists"))) {
      //     artists.add(jsonDecode(_store.get(id)));
      //   }
      //   data = SearchResults.decodeFilter({
      //     "tracks": tracks,
      //     "albums": albums,
      //     "playlists": playlists,
      //     "artists": artists,
      //   }, filter: query);
    } else {
      data = await _api.search(query);
      _store.put(
          cacheKey,
          jsonEncode({
            'tracks': Model.encodeIdList(data.tracks),
            'albums': Model.encodeIdList(data.albums),
            'playlists': Model.encodeIdList(data.playlists),
            'artists': Model.encodeIdList(data.artists),
          }));
      for (final e in data.tracks) {
        _store.put("tracks_$e", jsonEncode(e.encode()));
      }
      for (final e in data.albums) {
        _store.put("albums_$e", jsonEncode(e.encode()));
      }
      for (final e in data.playlists) {
        _store.put("playlists_$e", jsonEncode(e.encode()));
      }
      for (final e in data.artists) {
        _store.put("artists_$e", jsonEncode(e.encode()));
      }
    }
    return data;
  }

  Future<PlaylistDetails> playlistTracks(MusicPlaylist playlist) async {
    PlaylistDetails data;
    final cacheKey = "playlist_tracks_$playlist";
    final String? cache = _store.get(cacheKey);
    if (cache != null) {
      final json = jsonDecode(cache) as Map;
      List<Map> tracks = (json['tracks'] as List).map((id) => jsonDecode(_store.get("tracks_$id"))).toList().cast();
      data = PlaylistDetails.decode({'tracks': tracks, 'followers': json['followers']});
    } else {
      data = await _api.playlistTracks(playlist);
      _store.put(cacheKey, jsonEncode({'tracks': Model.encodeIdList(data.tracks), 'followers': data.followers}));
      for (final e in data.tracks) {
        _store.put("tracks_$e", jsonEncode(e.encode()));
      }
    }
    return data;
  }

  Future<List<MusicTrack>> albumTracks(MusicAlbum album) async {
    List<MusicTrack> data = [];
    final cacheKey = "album_tracks_$album";
    final String? cache = _store.get(cacheKey);
    if (cache != null) {
      final json = jsonDecode(cache) as List;
      data = MusicTrack.decodeList(json.map((id) => jsonDecode(_store.get("tracks_$id"))).toList().cast());
    } else {
      data = await _api.albumTracks(album);
      _store.put(cacheKey, jsonEncode(Model.encodeIdList(data)));
      for (final e in data) {
        _store.put("tracks_$e", jsonEncode(e.encode()));
      }
    }
    return data;
  }

  Future<List<MusicAlbum>> newReleases() async {
    List<MusicAlbum> data = [];
    const cacheKey = "new_releases";
    final String? cache = _store.get(cacheKey);
    if (cache != null) {
      final json = jsonDecode(cache) as List;
      data = MusicAlbum.decodeList(json.map((id) => jsonDecode(_store.get("albums_$id"))).toList().cast());
    } else {
      data = await _api.newReleases();
      _store.put(cacheKey, jsonEncode(Model.encodeIdList(data)));
      for (final e in data) {
        _store.put("albums_$e", jsonEncode(e.encode()));
      }
    }
    return data;
  }

  Future<List<MusicAlbum>> artistAlbums(MusicArtist artist) async {
    List<MusicAlbum> data;
    final cacheKey = "artist_albums_$artist";
    final String? cache = _store.get(cacheKey);
    if (cache != null) {
      final json = jsonDecode(cache) as List;
      data = MusicAlbum.decodeList(json.map((id) => jsonDecode(_store.get("albums_$id"))).toList().cast());
    } else {
      data = await _api.artistAlbums(artist);
      _store.put(cacheKey, jsonEncode(Model.encodeIdList(data)));
      for (final e in data) {
        _store.put("albums_$e", jsonEncode(e.encode()));
      }
    }
    return data.toSet().toList();
  }

  Future<List<MusicTrack>> artistTracks(MusicArtist artist) async {
    List<MusicTrack> data = [];
    final cacheKey = "artist_tracks_$artist";
    final String? cache = _store.get(cacheKey);
    if (cache != null) {
      final json = jsonDecode(cache) as List;
      data = MusicTrack.decodeList(json.map((id) => jsonDecode(_store.get("tracks_$id"))).toList().cast());
    } else {
      data = await _api.artistTracks(artist);
      _store.put(cacheKey, jsonEncode(Model.encodeIdList(data)));
      for (final e in data) {
        _store.put("tracks_$e", jsonEncode(e.encode()));
      }
    }
    return data;
  }

  Future<List<MusicArtist>> artistRelated(MusicArtist artist) async {
    List<MusicArtist> data = [];
    final cacheKey = "artist_related_$artist";
    final String? cache = _store.get(cacheKey);
    if (cache != null) {
      final json = jsonDecode(cache) as List;
      data = MusicArtist.decodeList(json.map((id) => jsonDecode(_store.get("artists_$id"))).toList().cast());
    } else {
      data = await _api.artistRelated(artist);
      _store.put(cacheKey, jsonEncode(Model.encodeIdList(data)));
      for (final e in data) {
        _store.put("artists_$e", jsonEncode(e.encode()));
      }
    }
    return data;
  }

  Future<MusicLyrics> lyrics(MusicTrack track) async {
    MusicLyrics data;
    final cacheKey = "track_lyrics_$track";
    final String? cache = _store.get(cacheKey);
    if (cache != null) {
      final json = jsonDecode(cache) as Map;
      data = MusicLyrics.decode(json);
    } else {
      data = await _api.lyrics(track);
      _store.put(cacheKey, jsonEncode(data.encode()));
    }
    return data;
  }

  Future<String> playback(MusicTrack track) async {
    return await _api.playback(track);
  }

  Future<void> purgeCache(MusicTrack track) async {
    await _api.purgeCache(track);
  }
}
