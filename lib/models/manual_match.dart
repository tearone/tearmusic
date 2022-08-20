class ManualMatch {
  final String name;
  final String artist;
  final String imageUrl;
  final Duration duration;
  final String videoId;

  ManualMatch({
    required this.name,
    required this.artist,
    required this.imageUrl,
    required this.duration,
    required this.videoId,
  });

  factory ManualMatch.decode(Map json) {
    return ManualMatch(
      name: json['name'],
      artist: json['artist'],
      imageUrl: json['image'],
      duration: Duration(seconds: json['duration'].toInt()),
      videoId: json['video_id'],
    );
  }

  static List<ManualMatch> decodeList(List<Map> list) => list.map((e) => ManualMatch.decode(e)).toList().cast<ManualMatch>();
}
