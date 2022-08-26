// Feed your own stream of bytes into the player
import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:just_audio/just_audio.dart';
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

  String get contentType {
    if (Platform.isIOS) {
      return 'audio/mp3';
    } else {
      return 'audio/mp4';
    }
  }

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    log("StreamAudioRequest($start-$end)");
    start ??= 0;

    await cached.future;
    if (start >= bytes.length) await playback.future;
    // if (playback.isCompleted || start >= bytes.length) {
    //   final pb = await playback.future;
    //   end ??= sourceLength;

    //   var req = http.Request('GET', Uri.parse(pb.streamUrl));
    //   req.headers['range'] = 'bytes=$start-$end';

    //   final res = await req.send();

    //   log("SENT");

    //   return StreamAudioResponse(
    //     sourceLength: sourceLength,
    //     contentLength: int.tryParse(res.headers['content-length'] ?? "") ?? 0,
    //     offset: start,
    //     stream: res.stream,
    //     contentType: 'audio/mp3',
    //   );
    // }

    end ??= sourceLength;

    final partial = bytes.sublist(start, end.clamp(0, bytes.length));

    log("srclen $sourceLength");

    return StreamAudioResponse(
      sourceLength: sourceLength,
      contentLength: end - start,
      offset: start,
      stream: Stream.value(partial),
      contentType: contentType,
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
      // if (sourceLength == 0) {
      final res = await http.get(Uri.parse(pb.streamUrl), headers: {"range": "bytes=0-"});
      sourceLength = int.tryParse(res.headers['content-range']?.split("/").last ?? "") ?? bytes.length;
      bytes = res.bodyBytes;
      log("got response ${res.statusCode} ${res.headers}");
      // }
      if (!playback.isCompleted) playback.complete(pb);
      if (!cached.isCompleted) cached.complete(true);
      return true;
    } catch (err) {
      log(err.toString());
      return false;
    }
  }
}
