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

  MusicTrack? get playing => _currentTrack;
  MusicTrack? _currentTrack;

  double get progress => 0.0;
  Duration get position => Duration.zero;
  Stream<Duration> get positionStream => Stream.value(position);
  bool get isPlaying => _player.isPlaying;
  Stream<bool> get isPlayingStream => _player.isPlayingStream;
  Duration? get duration => Duration.zero;
  Audio? get tma => Audio(Completer());
  AudioLoadingState get audioLoading => AudioLoadingState.ready;

  Future<void> init() async {
    await _player.startServer();
  }

  void play() {
    _player.play();
  }

  Future<void> playTrack(MusicTrack track) async {
    _currentTrack = track;
    log("[CURRENTMUSIC] Playing ${track.name}");
    await _player.playTrack(track);
    _player.play();
  }

  Future<void> seek(Duration position) async {}

  void pause() async {
    _player.pause();
  }
}
