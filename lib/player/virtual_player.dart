import 'dart:async';
import 'dart:developer';

import 'package:just_audio/just_audio.dart';
import 'package:tearmusic/models/music/track.dart';
import 'package:tearmusic/player/proxy/audio_stream_proxy.dart';
import 'package:tearmusic/providers/music_info_provider.dart';

class VirtualPlayer {
  VirtualPlayer({required MusicInfoProvider musicApi})
      : _proxy = AudioStreamProxy(),
        _player = AudioPlayer(),
        _musicApi = musicApi;

  final AudioStreamProxy _proxy;
  final AudioPlayer _player;
  final MusicInfoProvider _musicApi;

  Duration get position => _player.position;
  Stream<Duration> get positionStream => _player.positionStream;

  bool get isPlaying => _player.playing;
  Stream<bool> get isPlayingStream => _player.playingStream;

  Duration? get duration => _player.duration;

  Future<void> startServer() async {
    await _proxy.start();
    _proxy.listen();
  }

  Future<void> playTrack(MusicTrack track) async {
    _player.stop();
    String? streamUrl = track.streamUrl;
    if (streamUrl != null) log("[PLAYER] Using cached cdn stream");
    final playback = await _musicApi.playback(track);
    streamUrl ??= playback.streamUrl;
    track.waveform = playback.waveform;
    _proxy.addStream(track.id, streamUrl);
    await _player.setUrl(_proxy.getStream(track.id));
  }

  void pause() => _player.pause();
  void play() => _player.play();
  Future<void> seek(Duration position) => _player.seek(position);
}
