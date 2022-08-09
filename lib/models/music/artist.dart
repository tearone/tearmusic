import 'package:tearmusic/models/music/album.dart';
import 'package:tearmusic/models/music/images.dart';
import 'package:tearmusic/models/model.dart';
import 'package:tearmusic/models/music/track.dart';

class MusicArtist extends Model {
  final String name;
  final List<String> genres;
  final Images? images;
  final int followers;

  MusicArtist({
    required Map json,
    required String id,
    required this.name,
    required this.genres,
    required this.images,
    required this.followers,
  }) : super(id: id, json: json);

  factory MusicArtist.decode(Map json) {
    final images = json["images"] as List?;
    return MusicArtist(
      json: json,
      id: json["id"],
      name: json["name"],
      genres: ((json["genres"] as List?) ?? []).cast<String>(),
      images: images != null && images.isNotEmpty ? Images.decode(images.cast<Map>()) : null,
      followers: json["followers"] ?? 0,
    );
  }

  Map encode() => json;

  static List<MusicArtist> decodeList(List<Map> encoded) =>
      encoded.where((e) => e["id"] != null && e["images"] != null).map((e) => MusicArtist.decode(e)).toList().cast<MusicArtist>();
  static List<Map> encodeList(List<MusicArtist> models) => models.map((e) => e.encode()).toList().cast<Map>();
}

class ArtistDetails {
  final List<MusicTrack> tracks;
  final List<MusicAlbum> albums;
  final List<MusicArtist> related;
  final List<MusicAlbum> appearsOn;

  ArtistDetails({
    required this.tracks,
    required this.albums,
    required this.related,
    required this.appearsOn,
  });
}
