import 'package:flutter/widgets.dart';
import 'package:just_audio/just_audio.dart';
import 'package:tearmusic/models/music/track.dart';
import 'package:tearmusic/providers/music_info_provider.dart';

class CurrentMusicProvider extends ChangeNotifier {
  CurrentMusicProvider({required MusicInfoProvider api}) : _api = api;

  final MusicInfoProvider _api;
  final player = AudioPlayer();
  MusicTrack? playing;

  double get progress => player.duration != null ? player.position.inMilliseconds / player.duration!.inMilliseconds : 0;

  Future<void> playTrack(MusicTrack track) async {
    playing = track;
    notifyListeners();
    String url = await _api.playback(track);
    await play(url);
  }

  Future<void> play(String streamUrl) async {
    await player.stop();
    await player.setUrl(streamUrl);
    player.play();
  }
}
