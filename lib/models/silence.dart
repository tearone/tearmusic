class SilenceData {
  final Duration start;
  final Duration end;
  final Duration duration;

  SilenceData({
    required this.start,
    required this.end,
    required this.duration,
  });

  factory SilenceData.decode(Map json) {
    return SilenceData(
      start: Duration(milliseconds: (json['start'] * 1000).round()),
      end: Duration(milliseconds: (json['end'] * 1000).round()),
      duration: Duration(milliseconds: ((json['dur'] ?? json['duration']) * 1000).round()),
    );
  }

  static List<SilenceData> decodeList(List<Map> list) => list.map((e) => SilenceData.decode(e)).toList().cast<SilenceData>();
}
