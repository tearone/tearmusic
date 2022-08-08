import 'package:tearmusic/models/music/images.dart';

class MusicArtist {
  final String id;
  final String name;
  final List<String> genres;
  final Images? images;
  final int followers;

  MusicArtist({
    required this.id,
    required this.name,
    required this.genres,
    required this.images,
    required this.followers,
  });

  factory MusicArtist.fromJson(Map json) {
    return MusicArtist(
      id: json["id"] ?? "",
      name: json["name"],
      genres: (json["genres"] ?? []).cast<String>(),
      images: json["images"] != null && json["images"].isNotEmpty ? Images.fromJson(json["images"].cast<Map>()) : null,
      followers: json["followers"] ?? 0,
    );
  }
}
