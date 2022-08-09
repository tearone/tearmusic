import 'package:tearmusic/models/music/album.dart';
import 'package:tearmusic/models/music/artist.dart';
import 'package:tearmusic/models/music/playlist.dart';
import 'package:tearmusic/models/music/track.dart';

class SearchResults {
  final List<MusicTrack> tracks;
  final List<MusicPlaylist> playlists;
  final List<MusicAlbum> albums;
  final List<MusicArtist> artists;

  SearchResults({required this.tracks, required this.playlists, required this.albums, required this.artists});

  factory SearchResults.decode(Map json) {
    return SearchResults(
      tracks: MusicTrack.decodeList((json["tracks"] as List).cast<Map>()),
      playlists: MusicPlaylist.decodeList((json["playlists"] as List).cast<Map>()),
      albums: MusicAlbum.decodeList((json["albums"] as List).cast<Map>()),
      artists: MusicArtist.decodeList((json["artists"] as List).cast<Map>()),
    );
  }

  factory SearchResults.decodeFilter(Map json, {required String filter}) {
    final tracks = MusicTrack.decodeList((json["tracks"] as List).cast<Map>());
    final playlists = MusicPlaylist.decodeList((json["playlists"] as List).cast<Map>());
    final albums = MusicAlbum.decodeList((json["albums"] as List).cast<Map>());
    final artists = MusicArtist.decodeList((json["artists"] as List).cast<Map>());

    return SearchResults(
      tracks: tracks.where((e) => e.match(filter)).toList(),
      playlists: playlists.where((e) => e.match(filter)).toList(),
      albums: albums.where((e) => e.match(filter)).toList(),
      artists: artists.where((e) => e.match(filter)).toList(),
    );
  }

  bool get isEmpty => tracks.isEmpty && playlists.isEmpty && albums.isEmpty && artists.isEmpty;
  bool get isNotEmpty => !isEmpty;
}
