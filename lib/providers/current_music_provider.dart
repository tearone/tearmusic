import 'dart:async';
import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:tearmusic/models/music/track.dart';
import 'package:tearmusic/models/playback.dart';
import 'package:tearmusic/player/virtual_player.dart';
import 'package:tearmusic/providers/music_info_provider.dart';

class Audio {
  final Completer<Playback> playback;

  Audio(this.playback);
}

enum AudioLoadingState { ready, loading, error }

class CurrentMusicProvider extends ChangeNotifier {
  CurrentMusicProvider({required MusicInfoProvider musicApi}) : _player = VirtualPlayer(musicApi: musicApi);

  final VirtualPlayer _player;

  MusicTrack? get playing => _playing;
  MusicTrack? _playing;

  double get progress => 0.0;
  Duration get position => Duration.zero;
  Stream<Duration> get positionStream => Stream.value(position);
  bool get isPlaying => false;
  Stream<bool> get isPlayingStream => Stream.value(isPlaying);
  Duration? get duration => Duration.zero;
  Audio? get tma => Audio(Completer());
  AudioLoadingState get audioLoading => AudioLoadingState.ready;

  Future<void> init() async {
    await _player.startServer();
  }

  void play() {}

  Future<void> playTrack(MusicTrack track) async {
    _playing = track;
    log("[CURRENTMUSIC] Playing ${track.name}");
    await _player.play(track);
  }

  Future<void> seek(Duration position) async {}

  Future<void> pause() async {}
}
