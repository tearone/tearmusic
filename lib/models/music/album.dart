import 'package:tearmusic/models/music/artist.dart';
import 'package:tearmusic/models/music/images.dart';

enum AlbumType { single, album, compilation }

class MusicAlbum {
  final String id;
  final String name;
  final AlbumType albumType;
  final int trackCount;
  final DateTime releaseDate;
  final List<MusicArtist> artists;
  final Images images;

  MusicAlbum({
    required this.id,
    required this.name,
    required this.albumType,
    required this.trackCount,
    required this.releaseDate,
    required this.artists,
    required this.images,
  });

  factory MusicAlbum.fromJson(Map json) {
    return MusicAlbum(
      id: json["id"],
      name: json["name"],
      albumType: AlbumType.values[["single", "album", "compilation"].indexOf(json["album_type"])],
      trackCount: json["track_count"],
      releaseDate: DateTime.tryParse(json["release_date"] ?? "") ?? DateTime.fromMillisecondsSinceEpoch(0),
      artists: json["artists"].map((e) => MusicArtist.fromJson(e)).toList().cast<MusicArtist>(),
      images: Images.fromJson(json["images"].cast<Map>()),
    );
  }
}
