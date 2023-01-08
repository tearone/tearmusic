import 'dart:developer';
import 'dart:io';

import 'package:tearmusic/player/proxy/audio_source.dart';

class Range {
  final int? start;
  final int? end;

  const Range({required this.start, required this.end});

  static const empty = Range(start: null, end: null);

  factory Range.fromHeaders(HttpHeaders headers) {
    if (headers[HttpHeaders.rangeHeader] == null) return Range.empty;

    final header = headers[HttpHeaders.rangeHeader]!.first;

    List<String> parts = header.split("=");

    if (parts.length != 2 || parts[0] != "bytes") return Range.empty;

    List<String> rangeParts = parts[1].split('-');

    if (rangeParts.length != 2) return Range.empty;

    int? start = int.tryParse(rangeParts[0]);
    int? end = int.tryParse(rangeParts[1]);

    return Range(start: start, end: end);
  }

  Range clamp(int min, int max) => Range(start: (start ?? min).clamp(min, max), end: (end ?? max).clamp(min, max));
}

class ProxyRequestHandler {
  // Response content type
  final _proxyContentType = ContentType("audio", "aac");

  // Active audio streams
  // Ideally, there should be only one per track
  final Map<String, AudioSource> _streams = {};
  final List<String> _lastStream = [];

  Future<void> addStream(String streamId, String streamUrl) async {
    // Don't add stream if already exists
    if (_streams.keys.contains(streamId)) return;

    // Purge unused streams
    while (_lastStream.length > 5) {
      final purge = _lastStream.removeAt(0);
      _streams.remove(purge);
      log("[HANDLER] Discarded stream $purge");
    }

    // Create new stream
    final source = AudioSource.fromUri(Uri.parse(streamUrl));

    // Add stream
    _streams[streamId] = source;
    _lastStream.add(streamId);
    log("[HANDLER] Added stream $streamId");

    // Initialize stream
    await source.init();
  }

  // Get /stream/{id} from path
  String? _streamId(Uri requestUri) {
    if (requestUri.pathSegments.length < 2 || requestUri.pathSegments[0] != "stream") return null;

    return requestUri.pathSegments[1];
  }

  // Handles the incoming proxy request
  Future<void> handleRequest(HttpRequest request) async {
    final streamId = _streamId(request.uri);

    if (streamId == null || !_streams.keys.contains(streamId)) {
      request.response.statusCode = 404;
      return;
    }

    print(request.headers);

    // Add static response headers
    _addHeaders(request);

    final source = _streams[streamId]!;

    final sourceSize = await source.contentLength;
    final range = Range.fromHeaders(request.headers).clamp(0, sourceSize - 1);
    final size = range.end! + 1 - range.start!;
    request.response.contentLength = size;
    request.response.headers.add(HttpHeaders.contentRangeHeader, "bytes ${range.start!}-${range.end}/$sourceSize");

    int written = 0;

    // Respond with an audio stream
    await for (final chunk in source.read(seek: range.start!)) {
      final copy = chunk.getRange(0, (range.end! + 1 - written).clamp(0, chunk.length)).toList();
      request.response.add(copy);
      written += copy.length;

      if (written >= size) {
        break;
      }
    }

    log("[PROXY] Sent $written bytes");
  }

  void _addHeaders(HttpRequest request) {
    // Cache control
    request.response.headers.add(HttpHeaders.pragmaHeader, "no-cache");
    request.response.headers.add(HttpHeaders.cacheControlHeader, "no-cache");
    request.response.headers.add(HttpHeaders.expiresHeader, "Mon, 26 Jul 1997 05:00:00 GMT");

    // ICY Default
    request.response.headers.add("icy-pub", "0");
    request.response.headers.add("icy-description", "Unspecified description");
    request.response.headers.add("icy-url", "");
    request.response.headers.add("icy-name", "");
    request.response.headers.add("icy-metaint", "0");
    request.response.headers.add("icy-genre", "various");

    // Content type
    request.response.headers.contentType = _proxyContentType;

    // Accept range requests
    request.response.headers.add(HttpHeaders.acceptRangesHeader, "bytes");
  }
}
