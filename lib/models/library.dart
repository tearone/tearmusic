// ignore_for_file: non_constant_identifier_names, constant_identifier_names

class UserLibrary {
  List<String> liked_tracks = [];
  List<String> liked_artists = [];
  List<String> liked_albums = [];
  List<String> liked_playlists = [];
  List<String> track_history = [];

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
      track_history: (json["track_history"] as List).cast<String>(),
    );
  }

  Map encode() => {
        "liked_tracks": liked_tracks,
        "liked_artists": liked_artists,
        "liked_albums": liked_albums,
        "liked_playlists": liked_playlists,
        "track_history": track_history,
      };
}

enum LibraryType {liked_tracks, liked_artists, liked_albums, liked_playlists, track_history}