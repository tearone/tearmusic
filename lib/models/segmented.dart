class Segmented {
  final Duration start;
  final Duration end;

  Segmented({
    required this.start,
    required this.end,
  });

  factory Segmented.decode(Map json) {
    return Segmented(
      start: Duration(milliseconds: (((json['start'] as num?)?.toDouble() ?? 0.0) * 1000).round()),
      end: Duration(milliseconds: (((json['end'] as num?)?.toDouble() ?? 0.0) * 1000).round()),
    );
  }

  static List<Segmented> decodeList(List<Map> list) => list.map((e) => Segmented.decode(e)).toList().cast<Segmented>();

  Duration get duration => end - start;
}

class TempoSegment extends Segmented {
  final double bpm;

  TempoSegment({
    required this.bpm,
    required Duration start,
    required Duration end,
  }) : super(start: start, end: end);

  factory TempoSegment.decode(Map json) {
    final segment = Segmented.decode(json);
    return TempoSegment(
      bpm: (json['tempo'] as num?)?.toDouble() ?? 90.0,
      start: segment.start,
      end: segment.end,
    );
  }

  static List<TempoSegment> decodeList(List<Map> list) => list.map((e) => TempoSegment.decode(e)).toList().cast<TempoSegment>();
}
