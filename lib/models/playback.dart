import 'dart:typed_data';
import 'package:tearmusic/models/segmented.dart';

class PlaybackHead {
  final Uint8List prefetch;
  final List<Segmented> silence;
  final List<TempoSegment> tempo;
  final int sourceLength;

  PlaybackHead({
    required this.prefetch,
    required this.silence,
    required this.tempo,
    required this.sourceLength,
  });

  factory PlaybackHead.decode(Object? data) {
    final json = (data as Map);
    return PlaybackHead(
      prefetch: json['buffer'].buffer.asUint8List(),
      silence: Segmented.decodeList((json['silence'] as List).cast<Map>()),
      tempo: TempoSegment.decodeList((json['tempo'] as List).cast<Map>()),
      sourceLength: json['sourceLength'],
    );
  }
}

class Playback {
  final String streamUrl;
  final List<double> waveform;
  final List<Segmented> silence;

  Playback({
    required this.streamUrl,
    required this.waveform,
    required this.silence,
  });

  factory Playback.decode(Map json) {
    return Playback(
      streamUrl: json['cdn'],
      waveform: (json['proc']['waveform'] as List).cast<num?>().map((e) => e?.toDouble() ?? 0.0).toList(), // yes this is needed
      silence: Segmented.decodeList((json['proc']['silence'] as List).cast<Map>()),
    );
  }
}
