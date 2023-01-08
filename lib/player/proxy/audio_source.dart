import 'dart:async';
import 'dart:io';

import 'package:tearmusic/player/proxy/audio_buffer.dart';

class AudioSource {
  // Url of the audio stream source
  final Uri streamUri;

  // Length of the audio stream
  Future<int> get contentLength => _contentLength.future;
  final _contentLength = Completer<int>();

  late final Stream<List<int>> _stream;

  late final AudioBuffer _buffer;

  // Read lock
  final _ready = Completer();

  AudioSource({required this.streamUri});

  factory AudioSource.fromUri(Uri source) {
    return AudioSource(streamUri: source);
  }

  Future<void> init() async {
    _stream = await _openStream();
    _buffer = AudioBuffer.alloc(await contentLength);
    _ready.complete();
    await _buffer.addStream(_stream);
  }

  Future<Stream<List<int>>> _openStream() async {
    final client = HttpClient();
    final request = await client.getUrl(streamUri);
    request.headers.removeAll(HttpHeaders.acceptEncodingHeader);
    final response = await request.close();
    _contentLength.complete(response.contentLength);
    return () async* {
      yield* response;
      client.close();
    }();
  }

  Stream<List<int>> read({int seek = 0}) async* {
    await _ready.future;
    yield* _buffer.read(seek: seek);
  }
}
