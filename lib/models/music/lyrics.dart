import 'package:tearmusic/models/model.dart';

enum LyricsType { unavailable, fullText, subtitle, richsync }

typedef Subtitle = List<TimedSegment>;
typedef RichSync = List<LyricsLine>;

class MusicLyrics extends Model {
  final LyricsType lyricsType;
  final String? fullText;
  final Subtitle? subtitle;
  final RichSync? richSync;

  MusicLyrics({
    required String id,
    required Map json,
    required this.lyricsType,
    required this.fullText,
    required this.richSync,
    required this.subtitle,
  }) : super(id: id, json: json);

  factory MusicLyrics.decode(Map json) {
    Subtitle? subtitle;
    RichSync? richSync;

    if (json["subtitle"] != null) {
      subtitle = TimedSegment.decodeList((json["subtitle"] as List).cast());
    }

    if (json["richsync"] != null) {
      richSync = LyricsLine.decodeList((json["richsync"] as List).cast());
    }

    return MusicLyrics(
      json: json,
      id: json["id"],
      lyricsType: json["richsync"] != null
          ? LyricsType.richsync
          : json["subtitle"] != null
              ? LyricsType.subtitle
              : json["full_text"] != null
                  ? LyricsType.fullText
                  : LyricsType.unavailable,
      fullText: json["full_text"],
      subtitle: subtitle,
      richSync: richSync,
    );
  }

  Map encode() => json;
}

class TimedSegment {
  final String text;
  final Duration offset;

  TimedSegment({required this.text, required this.offset});

  factory TimedSegment.decode(Map json) {
    return TimedSegment(
      text: json['c'] ?? "",
      offset: Duration(milliseconds: ((json['o'] ?? 0).toDouble() * 1000).round()),
    );
  }

  static List<TimedSegment> decodeList(List<Map> encoded) => encoded.map((e) => TimedSegment.decode(e)).toList().cast();
}

class LyricsLine {
  final Duration start;
  final Duration end;
  final Subtitle segments;

  LyricsLine({required this.start, required this.end, required this.segments});

  factory LyricsLine.decode(Map json) {
    return LyricsLine(
      start: Duration(milliseconds: ((json['ts'] ?? 0).toDouble() * 1000).round()),
      end: Duration(milliseconds: ((json['te'] ?? 0).toDouble() * 1000).round()),
      segments: TimedSegment.decodeList((json['l'])),
    );
  }

  static List<LyricsLine> decodeList(List<Map> encoded) => encoded.map((e) => LyricsLine.decode(e)).toList().cast();
}
