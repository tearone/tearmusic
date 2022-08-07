import 'package:tearmusic/models/music/playlist.dart';
import 'package:tearmusic/models/music/track.dart';

class SearchResults {
  final List<MusicTrack> tracks;
  final List<MusicPlaylist> playlists;

  SearchResults({required this.tracks, required this.playlists});

  factory SearchResults.fromJson(Map json) {
    return SearchResults(
      tracks: json["tracks"].map((e) => MusicTrack.fromJson(e)).toList().cast<MusicTrack>(),
      playlists: json["playlists"].map((e) => MusicPlaylist.fromJson(e)).toList().cast<MusicPlaylist>(),
    );
  }

  bool get isEmpty => tracks.isEmpty && playlists.isEmpty;
  bool get isNotEmpty => !isEmpty;
}
