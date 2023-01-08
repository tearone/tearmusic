import 'dart:async';
import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:tearmusic/models/music/track.dart';
import 'package:tearmusic/player/virtual_player.dart';
import 'package:tearmusic/providers/music_info_provider.dart';

enum AudioLoadingState { ready, loading, error }

class CurrentMusicProvider extends ChangeNotifier {
  CurrentMusicProvider({required MusicInfoProvider musicApi}) : _player = VirtualPlayer(musicApi: musicApi);

  final VirtualPlayer _player;

  MusicTrack? get playing => _currentTrack;
  MusicTrack? _currentTrack;

  double get progress => _player.position.inMilliseconds / (_player.duration?.inMilliseconds ?? 0);
  Duration get position => _player.position;
  Stream<Duration> get positionStream => _player.positionStream;
  bool get isPlaying => _player.isPlaying;
  Stream<bool> get isPlayingStream => _player.isPlayingStream;
  Duration? get duration => _player.duration;
  AudioLoadingState _loadingState = AudioLoadingState.ready;
  AudioLoadingState get audioLoading => _loadingState;
  set audioLoading(AudioLoadingState value) {
    _loadingState = value;
    notifyListeners();
  }

  Future<void> init() async {
    await _player.startServer();
  }

  void play() {
    _player.play();
  }

  Future<void> playTrack(MusicTrack track) async {
    audioLoading = AudioLoadingState.loading;
    _currentTrack = track;
    notifyListeners();
    log("[CURRENTMUSIC] Playing ${track.name}");
    await _player.playTrack(track);
    notifyListeners();
    if (_currentTrack != track) return;
    _player.play();
    audioLoading = AudioLoadingState.ready;
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  void pause() async {
    _player.pause();
  }
}
