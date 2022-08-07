import 'package:tearmusic/models/music/images.dart';

class MusicPlaylist {
  final String id;
  final String name;
  final String description;
  final Images images;
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
      images: Images.fromJson(json["images"].cast<Map>()),
      trackCount: json["track_count"],
      owner: json["owner"]["name"],
    );
  }
}
