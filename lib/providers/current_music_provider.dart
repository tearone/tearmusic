import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:tearmusic/models/music/track.dart';
import 'package:tearmusic/models/playback.dart';
import 'package:tearmusic/providers/audio_stream_provider.dart';

class Audio {
  final Completer<Playback> playback;

  Audio(this.playback);
}

enum AudioLoadingState { ready, loading, error }

class CurrentMusicProvider extends ChangeNotifier {
  MusicTrack? _playing;
  MusicTrack? get playing => _playing;
  double get progress => 0.0;
  Duration get position => Duration.zero;
  Stream<Duration> get positionStream => Stream.value(position);
  bool get isPlaying => false;
  Stream<bool> get isPlayingStream => Stream.value(isPlaying);
  Duration? get duration => Duration.zero;
  Audio? get tma => Audio(Completer());
  AudioLoadingState get audioLoading => AudioLoadingState.ready;

  Future<void> init() async {}

  void play() {}

  Future<void> playTrack(MusicTrack track) async {
    _playing = track;
    final stream = AudioStreamProvider();
    await stream.startServer();
    await Future.delayed(const Duration(seconds: 3));
    await stream.stopServer();
  }

  Future<void> seek(Duration position) async {}

  Future<void> pause() async {}
}
