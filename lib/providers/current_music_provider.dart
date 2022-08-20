import 'dart:developer';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/widgets.dart';
import 'package:just_audio/just_audio.dart';
import 'package:tearmusic/models/library.dart';
import 'package:tearmusic/models/music/playlist.dart';
import 'package:tearmusic/models/music/track.dart';
import 'package:tearmusic/player/audio_source.dart';
import 'package:tearmusic/providers/music_info_provider.dart';
import 'package:tearmusic/providers/user_provider.dart';

enum AudioLoadingState { ready, loading, error }

enum PlayingFrom { none, album, playlist }

class CurrentMusicProvider extends BaseAudioHandler with ChangeNotifier {
  CurrentMusicProvider({required MusicInfoProvider musicApi, required UserProvider userApi})
      : _musicApi = musicApi,
        _userApi = userApi;

  Future<void> init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    session.interruptionEventStream.listen((event) {
      if (event.begin) {
        switch (event.type) {
          case AudioInterruptionType.duck:
            // Another app started playing audio and we should duck.
            break;
          case AudioInterruptionType.pause:
          case AudioInterruptionType.unknown:
            // Another app started playing audio and we should pause.
            break;
        }
      } else {
        switch (event.type) {
          case AudioInterruptionType.duck:
            // The interruption ended and we should unduck.
            break;
          case AudioInterruptionType.pause:
          // The interruption ended and we should resume.
          case AudioInterruptionType.unknown:
            // The interruption ended but we should not resume.
            break;
        }
      }
    });

    session.becomingNoisyEventStream.listen((_) {
      // The user unplugged the headphones, so we should pause or lower the volume.
    });

    session.devicesChangedEventStream.listen((event) {
      log('Devices added: ${event.devicesAdded}');
      log('Devices removed: ${event.devicesRemoved}');
    });
  }

  final UserProvider _userApi;
  final MusicInfoProvider _musicApi;

  final player = AudioPlayer(handleInterruptions: false);

  AudioLoadingState audioLoading = AudioLoadingState.ready;
  PlayingFrom playingFrom = PlayingFrom.none;
  MusicTrack? playing;
  TearMusicAudioSource? tma;
  MusicPlaylist? playlist;

  double get progress => player.duration != null ? player.position.inMilliseconds / player.duration!.inMilliseconds : 0;

  // ! POC only
  Future<void> playTrack(MusicTrack track) async {
    player.stop();

    playing = track;
    audioLoading = AudioLoadingState.loading;
    notifyListeners();

    tma = TearMusicAudioSource(track, api: _musicApi);
    final result = await tma!.head();

    if (result) {
      audioLoading = AudioLoadingState.ready;
    } else {
      audioLoading = AudioLoadingState.error;
    }
    notifyListeners();

    await player.setAudioSource(tma!);
    final silence = await tma!.silence();

    if (silence.isNotEmpty) {
      silence.sort((a, b) => a.start.compareTo(b.start));
      if (silence.first.start < const Duration(seconds: 1)) {
        log("-> ${silence.first.end}");
        player.seek(silence.first.end);
      }
    }

    player.play();

    _userApi.putLibrary(playing!, LibraryType.track_history);

    if (!tma!.playback.isCompleted) await tma!.body();
  }
}
