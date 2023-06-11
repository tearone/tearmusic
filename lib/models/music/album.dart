import 'package:tearmusic/models/music/artist.dart';
import 'package:tearmusic/models/music/images.dart';
import 'package:tearmusic/models/model.dart';

class MusicAlbum extends Model {
  final String name;
  final int trackCount;
  final DateTime releaseDate;
  final List<MusicArtist> artists;
  final Images? images;

  MusicAlbum({
    required Map json,
    required String id,
    required this.name,
    required this.trackCount,
    required this.releaseDate,
    required this.artists,
    required this.images,
  }) : super(id: id, json: json, key: "$name ${artists.firstOrNull?.name}", type: "album");

  factory MusicAlbum.decode(Map json) {
    final images = json["images"] as List?;
    return MusicAlbum(
      json: json,
      id: json["id"],
      name: json["name"] ?? "Album",
      trackCount: json["track_count"] ?? 0,
      releaseDate: DateTime.tryParse(json["release_date"] ?? "") ?? DateTime.fromMillisecondsSinceEpoch(0),
      artists: (json["artists"] as List).map((e) => MusicArtist.decode(e)).toList().cast<MusicArtist>(),
      images: images != null && images.isNotEmpty ? Images.decode(images.cast<Map>()) : null,
    );
  }

  Map encode() => json ?? {};

  static List<MusicAlbum> decodeList(List<Map> encoded) =>
      encoded.where((e) => e["id"] != null).map((e) => MusicAlbum.decode(e)).toList().cast<MusicAlbum>();
  static List<Map> encodeList(List<MusicAlbum> models) => models.map((e) => e.encode()).toList().cast<Map>();

  String get artistsLabel {
    if (artists.length == 2) {
      return "${artists[0].name} & ${artists[1].name}";
    }
    return artists.map((e) => e.name).join(", ");
  }

  String get shortTitle {
    if (trackCount == 1) {
      return "Single";
    }
    return "Album";
  }

  String get title {
    if (trackCount == 1) {
      return "Single";
    }
    return "Album";
  }
}
