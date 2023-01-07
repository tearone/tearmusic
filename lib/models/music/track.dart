import 'package:tearmusic/models/music/album.dart';
import 'package:tearmusic/models/music/artist.dart';
import 'package:tearmusic/models/model.dart';

class MusicTrack extends Model {
  final String name;
  final Duration duration;
  final bool explicit;
  final int trackNumber;
  final MusicAlbum? album;
  final List<MusicArtist> artists;
  final String? streamUrl;
  final List<int>? waveform;

  MusicTrack({
    required Map json,
    required String id,
    required this.name,
    required this.duration,
    required this.explicit,
    required this.trackNumber,
    required this.album,
    required this.artists,
    this.streamUrl,
    this.waveform,
  }) : super(id: id, json: json, key: "$name ${artists.first.name}", type: "track");

  factory MusicTrack.decode(Map json, {MusicAlbum? album}) {
    if (album != null) json['album'] = album.json;

    return MusicTrack(
      json: json,
      id: json["id"] ?? "",
      name: json["name"],
      duration: Duration(milliseconds: json["duration_ms"]),
      explicit: json["explicit"],
      trackNumber: json["track_number"],
      album: album ?? (json["album"] != null ? MusicAlbum.decode(json["album"]) : null),
      artists: json["artists"].map((e) => MusicArtist.decode(e)).toList().cast<MusicArtist>(),
      streamUrl: json["streamUrl"],
      waveform: json["waveform"],
    );
  }

  Map encode() => json ?? {};

  static List<MusicTrack> decodeList(List<Map> encoded, {MusicAlbum? album}) =>
      encoded.where((e) => e["id"] != null).map((e) => MusicTrack.decode(e, album: album)).toList().cast<MusicTrack>();
  static List<Map> encodeList(List<MusicTrack> models) => models.map((e) => e.encode()).toList().cast<Map>();

  String get artistsLabel {
    if (artists.length == 2) {
      return "${artists[0].name} & ${artists[1].name}";
    }
    return artists.map((e) => e.name).join(", ");
  }
}
