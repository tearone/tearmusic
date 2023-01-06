import 'dart:developer';

import 'package:audioplayers/audioplayers.dart' as ap;
import 'package:just_audio/just_audio.dart' as ja;
import 'package:tearmusic/models/music/track.dart';
import 'package:tearmusic/player/audio_stream_proxy.dart';
import 'package:tearmusic/providers/music_info_provider.dart';

class VirtualPlayer {
  VirtualPlayer({required MusicInfoProvider musicApi})
      : _proxy = AudioStreamProxy(),
        ap_player = ap.AudioPlayer(playerId: "tmc_player"),
        ja_player = ja.AudioPlayer(),
        _musicApi = musicApi;

  final AudioStreamProxy _proxy;
  final ap.AudioPlayer ap_player;
  final ja.AudioPlayer ja_player;
  final MusicInfoProvider _musicApi;

  Future<void> startServer() async {
    await _proxy.start();
    _proxy.listen();
  }

  Future<void> play(MusicTrack track) async {
    await ja_play(track);
  }

  Future<void> ap_play(MusicTrack track) async {
    ap_player.stop();
    log("[PLAYER] Stopped");
    String? streamUrl = track.streamUrl;
    if (streamUrl != null) log("[PLAYER] Using cached cdn stream");
    streamUrl ??= (await _musicApi.playback(track)).streamUrl;
    log("[PLAYER] Got playback");
    _proxy.loadUri(Uri.parse(streamUrl));
    await ap_player.setSourceUrl(_proxy.streamUri.toString());
    log("[PLAYER] Source set");
    await ap_player.resume();
    log("[PLAYER] Resumed");
  }

  Future<void> ja_play(MusicTrack track) async {
    ja_player.stop();
    log("[PLAYER] Stopped");
    String? streamUrl = track.streamUrl;
    if (streamUrl != null) log("[PLAYER] Using cached cdn stream");
    streamUrl ??= (await _musicApi.playback(track)).streamUrl;
    log("[PLAYER] Got playback");
    _proxy.loadUri(Uri.parse(streamUrl));
    await ja_player.setUrl(_proxy.streamUri.toString());
    // await _audioPlayer.setSourceUrl("https://timesradio.wireless.radio/stream");
    log("[PLAYER] Source set");
    await ja_player.play();
    log("[PLAYER] Resumed");
    ja_player.bufferedPositionStream.listen((event) {
      log("[VIRTUAL] Buffered: $event");
    });
    ja_player.durationStream.listen((event) {
      log("[VIRTUAL] Duration: $event");
    });
    ja_player.positionStream.listen((event) {
      log("[VIRTUAL] Position: $event");
    });
  }
}
