// Feed your own stream of bytes into the player
import 'dart:async';

import 'package:just_audio/just_audio.dart';
import 'package:tearmusic/models/music/track.dart';
import 'package:tearmusic/models/playback.dart';
import 'package:tearmusic/models/silence.dart';
import 'package:tearmusic/providers/music_info_provider.dart';
import 'package:http/http.dart' as http;

class TearMusicAudioSource extends StreamAudioSource {
  final MusicTrack track;
  List<int> bytes = [];
  final cached = Completer<bool>();
  final playback = Completer<Playback>();
  late PlaybackHead playbackHead;
  final MusicInfoProvider _api;

  TearMusicAudioSource(this.track, {required MusicInfoProvider api}) : _api = api;

  Future<List<SilenceData>> silence() async => playback.isCompleted ? (await playback.future).silence : playbackHead.silence;

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    await cached.future;
    start ??= 0;
    if (start >= bytes.length && end == null) await playback.future;
    end ??= bytes.length;

    return StreamAudioResponse(
      sourceLength: bytes.length,
      contentLength: end - start,
      offset: start,
      stream: Stream.value(bytes.sublist(start, end)),
      contentType: 'audio/mp4',
    );
  }

  Future<bool> head() async {
    try {
      playbackHead = await _api.playbackHead(track);
      bytes = playbackHead.prefetch;
      cached.complete(true);
      return true;
    } catch (e) {
      return await body(sub: false);
    }
  }

  Future<bool> body({bool sub = true}) async {
    try {
      final pb = await _api.playback(track, sub: sub, videoId: playbackHead.videoId);
      final res = await http.get(Uri.parse(pb.streamUrl));
      if (res.statusCode < 400) bytes = res.bodyBytes;
      playback.complete(pb);
      cached.complete(true);
      return true;
    } catch (_) {
      return false;
    }
  }
}
