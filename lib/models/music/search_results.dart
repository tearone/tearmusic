import 'package:tearmusic/models/music/track.dart';

class SearchResults {
  final List<MusicTrack> tracks;

  SearchResults({required this.tracks});

  factory SearchResults.fromJson(Map json) {
    return SearchResults(
      tracks: json["tracks"].map((e) => MusicTrack.fromJson(e)).toList().cast<MusicTrack>(),
    );
  }
}
