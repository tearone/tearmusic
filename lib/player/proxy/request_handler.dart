import 'dart:developer';
import 'dart:io';

import 'package:tearmusic/player/proxy/audio_source.dart';

class ProxyRequestHandler {
  // Response content type
  final _proxyContentType = ContentType("audio", "aac");

  // Active audio streams
  // Ideally, there should be only one per track
  final Map<String, AudioSource> _streams = {};

  Future<void> addStream(String streamId, String streamUrl) async {
    final source = AudioSource.fromUri(Uri.parse(streamUrl));
    _streams[streamId] = source;
    log("[HANDLER] Added stream $streamId");
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

    // Add static response headers
    _addHeaders(request);

    final source = _streams[streamId]!;

    // Respond with an audio stream
    await for (final chunk in source.read()) {
      request.response.add(chunk);
    }
  }

  void _addHeaders(HttpRequest request) {
    // Cache control
    request.response.headers.add("Pragma", "no-cache");
    request.response.headers.add("Cache-Control", "no-cache");
    request.response.headers.add("Expires", "Mon, 26 Jul 1997 05:00:00 GMT");

    // ICY Default
    request.response.headers.add("icy-pub", "0");
    request.response.headers.add("icy-description", "Unspecified description");
    request.response.headers.add("icy-url", "");
    request.response.headers.add("icy-name", "");
    request.response.headers.add("icy-metaint", "0");
    request.response.headers.add("icy-genre", "various");

    // Content type
    request.response.headers.contentType = _proxyContentType;
  }
}
