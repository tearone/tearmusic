import 'package:tearmusic/models/music/images.dart';
import 'package:tearmusic/models/model.dart';
import 'package:tearmusic/models/music/track.dart';

class MusicPlaylist extends Model {
  final String name;
  final String description;
  final Images? images;
  final int trackCount;
  final String owner;

  MusicPlaylist({
    required Map json,
    required String id,
    required this.name,
    required this.description,
    required this.images,
    required this.trackCount,
    required this.owner,
  }) : super(id: id, json: json, key: name, type: "playlist");

  factory MusicPlaylist.decode(Map json) {
    final images = json["images"] as List?;
    return MusicPlaylist(
      json: json,
      id: json["id"],
      name: json["name"],
      description: json["description"],
      images: images != null && images.isNotEmpty ? Images.decode(images.cast<Map>()) : null,
      trackCount: json["track_count"] ?? 0,
      owner: json["owner"] != null ? json["owner"]["name"] : "",
    );
  }

  Map encode() => json;

  static List<MusicPlaylist> decodeList(List<Map> encoded) =>
      encoded.where((e) => e["id"] != null).map((e) => MusicPlaylist.decode(e)).toList().cast<MusicPlaylist>();
  static List<Map> encodeList(List<MusicPlaylist> models) => models.map((e) => e.encode()).toList().cast<Map>();
}

class PlaylistDetails extends Model {
  final List<MusicTrack> tracks;
  final int followers;

  PlaylistDetails({
    required Map json,
    required String id,
    required this.tracks,
    required this.followers,
  }) : super(id: id, json: json, type: "playlistextras");

  factory PlaylistDetails.decode(Map json) {
    final tracks = MusicTrack.decodeList((json['tracks'] as List).cast<Map>());
    return PlaylistDetails(
      json: json,
      id: tracks.map((e) => e.id).join(","),
      tracks: tracks,
      followers: json['followers'] ?? 0,
    );
  }

  Map encode() => json;
}
