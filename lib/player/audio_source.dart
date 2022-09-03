// Feed your own stream of bytes into the player
import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:just_audio/just_audio.dart';
import 'package:tearmusic/exceptionts.dart';
import 'package:tearmusic/models/music/track.dart';
import 'package:tearmusic/models/playback.dart';
import 'package:tearmusic/models/segmented.dart';
import 'package:tearmusic/providers/music_info_provider.dart';
import 'package:http/http.dart' as http;

class TearMusicAudioSource extends StreamAudioSource {
  final MusicTrack track;
  List<int> bytes = [];

  final cached = Completer<bool>();
  final playback = Completer<Playback>();
  PlaybackHead? playbackHead;
  int _sourceLength = 0;
  set sourceLength(value) => _sourceLength = value;
  int get sourceLength => playbackHead != null ? playbackHead!.sourceLength : _sourceLength;
  final MusicInfoProvider _api;

  TearMusicAudioSource(this.track, {required MusicInfoProvider api}) : _api = api;

  Future<List<Segmented>> silence() async => playback.isCompleted ? (await playback.future).silence : playbackHead?.silence ?? [];

  @override
  Future<StreamAudioResponse> request([int? start, int? end, int tries = 0]) async {
    log("[A] StreamAudioRequest($start-$end)");
    start ??= 0;

    await cached.future;
    if (playback.isCompleted || start >= bytes.length) {
      log("[A] not completed");

      try {
        log("[A] trying audio range");

        final pb = await playback.future;
        end ??= sourceLength;

        var req = http.Request('GET', Uri.parse(pb.streamUrl));
        req.headers['range'] = 'bytes=$start-$end';

        final res = await req.send();
        return StreamAudioResponse(
          sourceLength: sourceLength,
          contentLength: int.tryParse(res.headers['content-length'] ?? "") ?? 0,
          offset: start,
          stream: res.stream,
          contentType: Platform.isIOS ? 'audio/mp3' : 'audio/mp4',
        );
      } catch (e) {
        log("[A] audio range got error, retry");

        if (tries >= 5) {
          throw UnknownRequestException("network problem while trying to get range");
        }

        return await Future.delayed(const Duration(seconds: 1), () async => await request(start, end, tries + 1));
      }
    }

    end ??= sourceLength;

    final partial = bytes.sublist(start, end.clamp(0, bytes.length));

    return StreamAudioResponse(
      sourceLength: sourceLength,
      contentLength: end - start,
      offset: start,
      stream: Stream.value(partial),
      contentType: Platform.isIOS ? 'audio/mp3' : 'audio/mp4',
    );
  }

  Future<bool> head() async {
    try {
      playbackHead = await _api.playbackHead(track);
      bytes = playbackHead!.prefetch;
      cached.complete(true);
      return true;
    } catch (err) {
      log(err.toString());
      return await body();
    }
  }

  Future<bool> body() async {
    try {
      final pb = await _api.playback(track);
      if (sourceLength == 0) {
        final res = await http.head(Uri.parse(pb.streamUrl), headers: {"range": "bytes=-"});
        sourceLength = int.tryParse(res.headers['content-range']?.split("/").last ?? "") ?? bytes.length;
      }
      if (!playback.isCompleted) playback.complete(pb);
      if (!cached.isCompleted) cached.complete(true);
      return true;
    } catch (err) {
      log(err.toString());

      return false;

      //if (tries >= 3) return false;

      //log("[R] retry body: $tries");

      //return await Future.delayed(const Duration(seconds: 3), () async => await body(tries: tries + 1));
    }
  }
}
