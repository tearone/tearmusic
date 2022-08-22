// ignore_for_file: non_constant_identifier_names, constant_identifier_names

class UserLibrary {
  List<String> liked_tracks = [];
  List<String> liked_artists = [];
  List<String> liked_albums = [];
  List<String> liked_playlists = [];
  List<UserTrackHistory> track_history = [];

  UserLibrary({
    required this.liked_tracks,
    required this.liked_artists,
    required this.liked_albums,
    required this.liked_playlists,
    required this.track_history,
  });

  factory UserLibrary.decode(Map json) {
    return UserLibrary(
      liked_tracks: (json["liked_tracks"] as List).cast<String>(),
      liked_artists: (json["liked_artists"] as List).cast<String>(),
      liked_albums: (json["liked_albums"] as List).cast<String>(),
      liked_playlists: (json["liked_playlists"] as List).cast<String>(),
      track_history: (json["track_history"] as List).map((e) => UserTrackHistory.decode(e)).toList(),
    );
  }

  Map encode() {
    //print("encoding ${track_history.map((e) => e.encode())}");
    return {
      "liked_tracks": liked_tracks,
      "liked_artists": liked_artists,
      "liked_albums": liked_albums,
      "liked_playlists": liked_playlists,
      "track_history": track_history.map((e) => e.encode()).toList(),
    };
  }
}

enum LibraryType { liked_tracks, liked_artists, liked_albums, liked_playlists, track_history }

class UserTrackHistory {
  int date;
  String track_id;
  String? from_id;
  String? from_type;

  UserTrackHistory({
    required this.date,
    required this.track_id,
    this.from_id,
    this.from_type,
  });

  factory UserTrackHistory.decode(Map json) {
    return UserTrackHistory(
      date: json["date"],
      track_id: json["track_id"],
      from_id: json["from_id"],
      from_type: json["from_type"],
    );
  }

  Map encode() => {
        "date": date,
        "track_id": track_id,
        "from_id": from_id,
        "from_type": from_type,
      };
}
