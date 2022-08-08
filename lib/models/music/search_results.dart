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

  factory SearchResults.fromJson(Map json) {
    return SearchResults(
      tracks: json["tracks"].map((e) => MusicTrack.fromJson(e)).toList().cast<MusicTrack>(),
      playlists: json["playlists"].map((e) => MusicPlaylist.fromJson(e)).toList().cast<MusicPlaylist>(),
      albums: json["albums"].map((e) => MusicAlbum.fromJson(e)).toList().cast<MusicAlbum>(),
      artists: json["artists"].map((e) => MusicArtist.fromJson(e)).toList().cast<MusicArtist>(),
    );
  }

  bool get isEmpty => tracks.isEmpty && playlists.isEmpty && albums.isEmpty && artists.isEmpty;
  bool get isNotEmpty => !isEmpty;
}
