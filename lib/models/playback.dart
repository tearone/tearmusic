import 'dart:typed_data';
import 'package:tearmusic/models/silence.dart';

class PlaybackHead {
  final Uint8List prefetch;
  final String videoId;
  final List<SilenceData> silence;

  PlaybackHead({
    required this.prefetch,
    required this.videoId,
    required this.silence,
  });

  factory PlaybackHead.decode(Object? data) {
    final json = (data as Map);
    return PlaybackHead(
      prefetch: json['buffer'].buffer.asUint8List(),
      videoId: json['videoId'],
      silence: SilenceData.decodeList((json['silence'] as List).cast<Map>()),
    );
  }
}

class Playback {
  final String streamUrl;
  final List<double> waveform;
  final List<SilenceData> silence;

  Playback({
    required this.streamUrl,
    required this.waveform,
    required this.silence,
  });

  factory Playback.decode(Map json) {
    return Playback(
      streamUrl: json['cdn'],
      waveform: json['proc']['waveform'].cast<double>(),
      silence: SilenceData.decodeList((json['proc']['silence'] as List).cast<Map>()),
    );
  }
}
