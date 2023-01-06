import 'dart:async';
import 'dart:developer';
import 'dart:io';

class AudioStreamProxy {
  late final ServerSocket socket;
  late final HttpServer server;

  static const String streamPath = "/stream";

  Uri get streamUri => Uri.http("${socket.address.address}:${socket.port}", streamPath);

  Uri? _sourceUri;

  final List<int> _buffer = [];
  var contentLength = Completer<int>();

  Future<void> loadUri(Uri uri) async {
    _sourceUri = uri;
    final stream = (await getSource());
    if (contentLength.isCompleted && await contentLength.future != stream?.contentLength) {
      contentLength = Completer<int>();
    }
    if (!contentLength.isCompleted) contentLength.complete(stream?.contentLength);
    if (stream != null) {
      _buffer.clear();
      await for (final chunk in stream) {
        _buffer.addAll(chunk);
      }
    }
  }

  Future<void> start() async {
    socket = await ServerSocket.bind("127.0.0.1", 0);
    server = HttpServer.listenOn(socket);
    log("Started proxy server on ${socket.address.address}:${socket.port}");
  }

  Future<void> stop({bool force = false}) async {
    log("Stopped proxy server on ${socket.address.address}:${socket.port}");
    await server.close(force: force);
  }

  Future<void> listen() async {
    await for (var request in server) {
      log("[PROXY] <- ${request.method} ${request.uri.path}");
      handleRequest(request).then((_) {
        log("[PROXY] <-- HTTP ${request.response.statusCode} ${request.response.headers.contentType}");
        request.response.close();
      });
    }
  }

  Future<void> handleRequest(HttpRequest request) async {
    request.response.headers.add("Pragma", "no-cache");
    request.response.headers.add("Cache-Control", "no-cache");
    request.response.headers.add("Expires", "Mon, 26 Jul 1997 05:00:00 GMT");
    request.response.headers.add("Connection", "close");

    // print(request.headers);

    request.response.headers.add("icy-pub", "0");
    request.response.headers.add("icy-description", "Unspecified description");
    request.response.headers.add("icy-url", "");
    request.response.headers.add("icy-name", "");
    request.response.headers.add("icy-metaint", "0");
    request.response.headers.add("icy-genre", "various");
    request.response.headers.add("icy-br", "130");

    if (request.uri.path != streamPath) {
      request.response.statusCode = 404;
      return;
    }

    request.response.headers.contentType = ContentType("audio", "aac");

    final length = await contentLength.future;
    int copied = 0;

    while (copied < length) {
      await Future.delayed(const Duration(milliseconds: 100));
      final end = (copied + (41000).floor()).clamp(0, _buffer.length);
      request.response.add(_buffer.getRange(copied, end).toList());
      final bytes = end - copied;
      copied += bytes;
      log("[PROXY] Sent $bytes bytes");
      print([copied, length]);
    }
  }

  Future<HttpClientResponse?> getSource() async {
    if (_sourceUri == null) return null;
    final req = await HttpClient().getUrl(_sourceUri!);
    final res = await req.close();
    log("[PROXY] -> GET $_sourceUri ${res.headers.contentType}");
    return res;
  }
}
