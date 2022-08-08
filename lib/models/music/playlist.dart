import 'package:tearmusic/models/music/images.dart';
import 'package:tearmusic/models/music/track.dart';

class MusicPlaylist {
  final String id;
  final String name;
  final String description;
  final Images? images;
  final int trackCount;
  final String owner;

  MusicPlaylist({
    required this.id,
    required this.name,
    required this.description,
    required this.images,
    required this.trackCount,
    required this.owner,
  });

  factory MusicPlaylist.fromJson(Map json) {
    return MusicPlaylist(
      id: json["id"],
      name: json["name"],
      description: json["description"],
      images: json["images"] != null && json["images"].isNotEmpty ? Images.fromJson(json["images"].cast<Map>()) : null,
      trackCount: json["track_count"],
      owner: json["owner"]["name"],
    );
  }

  @override
  bool operator ==(other) => other is MusicPlaylist && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

class PlaylistDetails {
  final List<MusicTrack> tracks;
  final int followers;

  PlaylistDetails({
    required this.tracks,
    required this.followers,
  });

  factory PlaylistDetails.fromJson(Map json) {
    return PlaylistDetails(
      tracks: json['tracks'].where((e) => e['id'] != null).map((e) => MusicTrack.fromJson(e)).toList().cast<MusicTrack>(),
      followers: json['followers'],
    );
  }
}
