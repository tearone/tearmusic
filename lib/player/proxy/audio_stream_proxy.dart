import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:tearmusic/player/proxy/request_handler.dart';

class AudioStreamProxy {
  late final ServerSocket _socket;
  late final HttpServer server;
  final _handler = ProxyRequestHandler();

  String get address => "${_socket.address.address}:${_socket.port}";

  Future<void> start() async {
    _socket = await ServerSocket.bind("127.0.0.1", 0);
    server = HttpServer.listenOn(_socket);
    log("Started proxy server on $address");
  }

  Future<void> stop({bool force = false}) async {
    log("Stopped proxy server on $address");
    await server.close(force: force);
  }

  Future<void> listen() async {
    await for (var request in server) {
      log("[PROXY] <- ${request.method} ${request.uri.path}");

      // Send request handler to thread
      _handler.handleRequest(request).then((_) {
        log("[PROXY] <-- HTTP ${request.response.statusCode} ${request.response.headers.contentType}");
        request.response.close();
      });
    }
  }

  String getStream(String streamId) => "http://$address/stream/$streamId";

  void addStream(String streamId, String streamUrl) {
    _handler.addStream(streamId, streamUrl);
  }
}
