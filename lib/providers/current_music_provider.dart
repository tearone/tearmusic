import 'dart:developer';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/widgets.dart';
import 'package:just_audio/just_audio.dart';
import 'package:tearmusic/models/library.dart';
import 'package:tearmusic/models/music/playlist.dart';
import 'package:tearmusic/models/music/track.dart';
import 'package:tearmusic/player/audio_source.dart';
import 'package:tearmusic/player/media_control.dart';
import 'package:tearmusic/providers/music_info_provider.dart';
import 'package:tearmusic/providers/user_provider.dart';

enum AudioLoadingState { ready, loading, error }

enum PlayingFrom { none, album, playlist }

class CurrentMusicProvider extends BaseAudioHandler with ChangeNotifier {
  final UserProvider _userProvider;
  final MusicInfoProvider _musicApi;

  var player = AudioPlayer(handleInterruptions: false);

  AudioLoadingState audioLoading = AudioLoadingState.ready;
  PlayingFrom playingFrom = PlayingFrom.none;
  MusicTrack? playing;
  TearMusicAudioSource? tma;
  MusicPlaylist? playlist;
  bool liked = false;

  double get progress => player.duration != null ? player.position.inMilliseconds / player.duration!.inMilliseconds : 0;

  CurrentMusicProvider({required MusicInfoProvider musicApi, required UserProvider userApi})
      : _musicApi = musicApi,
        _userProvider = userApi;

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

    player.playbackEventStream.listen((event) {
      if (event.processingState == ProcessingState.completed) {
        _userProvider.skipToNext();
      }
    });

    player.playbackEventStream.map(_transformEvent).pipe(playbackState);
  }

  /// Transform a just_audio event into an audio_service state.
  ///
  /// This method is used from the constructor. Every event received from the
  /// just_audio player will be transformed into an audio_service state so that
  /// it can be broadcast to audio_service clients.
  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        TMMediaControl.skipBack,
        if (player.playing) TMMediaControl.pause else TMMediaControl.play,
        TMMediaControl.skipForward,
        if (liked) TMMediaControl.unheart else TMMediaControl.heart,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[player.processingState]!,
      playing: player.playing,
      updatePosition: player.position,
      bufferedPosition: player.bufferedPosition,
      speed: player.speed,
    );
  }

  bool checkThisTrackIsPlaying(MusicTrack track) {
    return _userProvider.playerInfo.currentMusic!.id == track.id;
  }

  // ! POC only
  Future<void> playTrack(MusicTrack track, {bool fromPrimary = true, bool startInstant = true, bool clearHistory = false}) async {
    if (player.playing) player.stop();

    // not being used
    //if (clearHistory) {
    //  _userProvider.postClear(PlayerInfoPostType.history, DateTime.now().millisecondsSinceEpoch);
    //}

    // if (_userProvider.playerInfo.currentMusic == null || _userProvider.playerInfo.currentMusic?.id != track.id) {
    //   _userProvider.postCurrentMusic(track.id, DateTime.now().millisecondsSinceEpoch, fromPrimary: fromPrimary);
    // }

    notifyListeners();

    playing = track;
    liked = (await _userProvider.getLibrary()).liked_tracks.contains(track.id);
    final imageUrl = track.album?.images?.forSize(const Size(200, 200));
    mediaItem.add(MediaItem(
      id: track.id,
      title: track.name,
      album: track.album?.name,
      artUri: imageUrl != null ? Uri.parse(imageUrl) : null,
      artist: track.artistsLabel,
      duration: track.duration,
      rating: Rating.newHeartRating(liked),
    ));
    audioLoading = AudioLoadingState.loading;
    notifyListeners();

    if (!checkThisTrackIsPlaying(track)) {
      return;
    }

    tma = TearMusicAudioSource(track, api: _musicApi);
    final result = await tma!.head();

    if (result) {
      audioLoading = AudioLoadingState.ready;
    } else {
      if (checkThisTrackIsPlaying(track)) {
        audioLoading = AudioLoadingState.error;
        _userProvider.skipToNext();
      }
      notifyListeners();
      return;
    }
    notifyListeners();

    if (!checkThisTrackIsPlaying(track)) {
      return;
    }

    await player.setAudioSource(tma!);
    final silence = await tma!.silence();

    if (silence.isNotEmpty) {
      silence.sort((a, b) => a.start.compareTo(b.start));
      if (silence.first.start < const Duration(seconds: 1)) {
        log("-> ${silence.first.end}");
        player.seek(silence.first.end);
      }
    }

    if (startInstant) player.play();

    // _userProvider.putLibrary(playing!, LibraryType.track_history);

    if (!checkThisTrackIsPlaying(track)) {
      return;
    }

    if (!tma!.playback.isCompleted) await tma!.body();
  }

  @override
  Future<void> play() async {
    player.play();
  }

  @override
  Future<void> pause() async {
    player.pause();
  }

  @override
  Future<void> seek(Duration position) async {
    player.seek(position);
  }

  @override
  Future<void> skipToNext() async {
    _userProvider.skipToNext();
  }

  @override
  Future<void> skipToPrevious() async {
    _userProvider.skipToPrev();
  }

  @override
  Future<void> setRating(Rating rating, [Map<String, dynamic>? extras]) async {
    liked = rating.hasHeart();
    mediaItem.add(mediaItem.value!.copyWith(rating: Rating.newHeartRating(liked)));
    if (playing != null) {
      if (rating.hasHeart()) {
        await _userProvider.putLibrary(playing!, LibraryType.liked_tracks);
      } else {
        await _userProvider.deleteLibrary(playing!, LibraryType.liked_tracks);
      }
    }
    player.setSpeed(1.0); // trigger playback event and update notification
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {}

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {}
}
