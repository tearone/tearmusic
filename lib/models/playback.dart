import 'dart:convert';

class Playback {
  final String streamUrl;
  final List<int> waveform;

  Playback({
    required this.streamUrl,
    required this.waveform,
  });

  factory Playback.decode(Map json) {
    return Playback(
      streamUrl: json['streamUrl'],
      waveform: json['waveform'] != null ? base64.decode(json['waveform'] as String) : List.generate(50, (index) => 10), // yes this is needed
    );
  }
}
