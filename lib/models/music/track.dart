import 'package:tearmusic/models/music/album.dart';
import 'package:tearmusic/models/music/artist.dart';

class MusicTrack {
  final String id;
  final String name;
  final Duration duration;
  final bool explicit;
  final int trackNumber;
  final MusicAlbum? album;
  final List<MusicArtist> artists;

  MusicTrack({
    required this.id,
    required this.name,
    required this.duration,
    required this.explicit,
    required this.trackNumber,
    required this.album,
    required this.artists,
  });

  factory MusicTrack.fromJson(Map json) {
    return MusicTrack(
      id: json["id"] ?? "",
      name: json["name"],
      duration: Duration(milliseconds: json["duration_ms"]),
      explicit: json["explicit"],
      trackNumber: json["track_number"],
      album: json["album"] != null ? MusicAlbum.fromJson(json["album"]) : null,
      artists: json["artists"].map((e) => MusicArtist.fromJson(e)).toList().cast<MusicArtist>(),
    );
  }

  String get artistsLabel {
    if (artists.length == 2) {
      return "${artists[0].name} & ${artists[1].name}";
    }
    return artists.map((e) => e.name).join(", ");
  }

  @override
  bool operator ==(other) => other is MusicTrack && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
