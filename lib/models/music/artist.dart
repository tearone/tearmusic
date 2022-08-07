class MusicArtist {
  final String id;
  final String name;

  MusicArtist({
    required this.id,
    required this.name,
  });

  factory MusicArtist.fromJson(Map json) {
    return MusicArtist(
      id: json["id"],
      name: json["name"],
    );
  }
}
