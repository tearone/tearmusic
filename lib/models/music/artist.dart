import 'package:tearmusic/models/music/album.dart';
import 'package:tearmusic/models/music/images.dart';
import 'package:tearmusic/models/music/track.dart';

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

  @override
  bool operator ==(other) => other is MusicArtist && other.id == id;

  @override
  int get hashCode => id.hashCode;
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
