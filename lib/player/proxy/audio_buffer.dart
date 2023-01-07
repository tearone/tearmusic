import 'package:tearmusic/player/proxy/audio_chunk.dart';

class AudioBuffer {
  late final List<AudioChunk> _buffers;
  int _cursor = 0;
  AudioChunk get _currentBuffer => _buffers[_cursor.clamp(0, _buffers.length - 1)];

  AudioBuffer.alloc(int size) {
    final int chunkCount = (size / kAudioChunkSize).ceil();
    _buffers = List.generate(chunkCount, (_) => AudioChunk(), growable: false);
  }

  Future<void> addStream(Stream<List<int>> stream) async {
    await for (final chunk in stream) {
      int remaining = chunk.length;
      do {
        remaining = await _currentBuffer.write(chunk.getRange(chunk.length - remaining, chunk.length));
        if (_currentBuffer.full) _cursor += 1;
      } while (remaining > 0);
    }
    _currentBuffer.release();
  }

  Stream<List<int>> read() async* {
    for (final chunk in _buffers) {
      yield await chunk.read();
    }
  }
}
