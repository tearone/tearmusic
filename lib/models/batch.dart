// ignore_for_file: non_constant_identifier_names, constant_identifier_names

import 'package:tearmusic/models/model.dart';
import 'package:tearmusic/models/music/album.dart';
import 'package:tearmusic/models/music/artist.dart';
import 'package:tearmusic/models/music/playlist.dart';
import 'package:tearmusic/models/music/track.dart';

class BatchLibrary {
  List<MusicTrack> tracks = [];
  List<MusicArtist> artists = [];
  List<MusicAlbum> albums = [];
  List<MusicPlaylist> playlists = [];
  List<BatchTrackHistory> track_history = [];

  BatchLibrary({
    required this.tracks,
    required this.artists,
    required this.albums,
    required this.playlists,
    required this.track_history,
  });

  factory BatchLibrary.decode(Map json) {
    return BatchLibrary(
        tracks: ((json["tracks"] ?? []) as List).map((e) => MusicTrack.decode(e)).toList(),
        artists: ((json["artists"] ?? []) as List).map((e) => MusicArtist.decode(e)).toList(),
        albums: ((json["albums"] ?? []) as List).map((e) => MusicAlbum.decode(e)).toList(),
        playlists: ((json["playlists"] ?? []) as List).map((e) => MusicPlaylist.decode(e)).toList(),
        track_history: ((json["track_history"] ?? []) as List).map((e) => BatchTrackHistory.decode(e)).toList());
  }

  Map encode() => {
        "tracks": tracks.map((e) => e.encode()),
        "artists": artists.map((e) => e.encode()),
        "albums": albums.map((e) => e.encode()),
        "playlists": playlists.map((e) => e.encode()),
        "track_history": track_history.map((e) => e.encode()),
      };
}

class BatchTrackHistory {
  MusicTrack track;
  Model? from;
  String type;
  int date;

  BatchTrackHistory({
    required this.track,
    this.from,
    required this.type,
    required this.date,
  });

  factory BatchTrackHistory.decode(Map json) {
    return BatchTrackHistory(
      track: MusicTrack.decode(json["track"]),
      from: json["from"] != null
          ? (json["type"] == "playlist"
              ? MusicPlaylist.decode(json["from"])
              : json["type"] == "album"
                  ? MusicAlbum.decode(json["from"])
                  : null)
          : null,
      type: json["type"],
      date: json["date"],
    );
  }

  Map encode() => {
        "track": track.encode(),
        "from": from != null
            ? type == "playlist"
                ? (from as MusicPlaylist).encode()
                : type == "album"
                    ? (from as MusicAlbum).encode()
                    : null
            : null,
        "type": type,
        "date": date,
      };
}
