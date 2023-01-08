import 'dart:async';

import 'package:synchronized/synchronized.dart';

const int kAudioChunkSize = 16 * 1024;

class AudioChunk {
  // Write head offset
  int _cursor = 0;

  final List<int> _buffer = List.filled(kAudioChunkSize, 0);

  // Read lock
  final _ready = Completer();
  // Write lock
  final _lock = Lock();

  bool get full => _ready.isCompleted;

  // Returns remaining size
  Future<int> write(Iterable<int> buf) async {
    int remaining = 0;
    int copied = 0;

    await _lock.synchronized(() async {
      remaining = _buffer.length - _cursor;
      copied = buf.length.clamp(0, remaining);
      final int end = _cursor + copied;
      if (copied > 0) _buffer.setRange(_cursor, end, buf.take(copied));

      // advance cursor
      _cursor += copied;
      remaining = _buffer.length - _cursor;
    });

    // If buffer is filled, unlock read
    if (remaining == 0 && !_ready.isCompleted) {
      _ready.complete();
    }

    return buf.length - copied;
  }

  // Allow reads after the buffer is filled
  Future<List<int>> read() async {
    await _ready.future;
    return List.from(_buffer.getRange(0, _cursor));
  }

  void release() => _ready.complete();
}
