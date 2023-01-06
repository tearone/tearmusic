import 'dart:developer';
import 'dart:io';

class AudioStreamProvider {
  late final ServerSocket socket;
  late final HttpServer server;

  Future<void> startServer() async {
    socket = await ServerSocket.bind("127.0.0.1", 0);
    server = HttpServer.listenOn(socket);
    log("Started proxy server on $socket");
  }

  Future<void> stopServer({bool force = false}) async {
    await server.close(force: force);
  }
}
