import 'dart:developer';

import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  await Hive.initFlutter();
  final box = await Hive.openBox("user");

  runApp(MyApp(box));
}

class MyApp extends StatelessWidget {
  const MyApp(this.box, {super.key});

  final Box box;

  @override
  Widget build(BuildContext context) {
    final user = box.get("access_token");

    if (user == null) {
      uriLinkStream.listen((event) {
        if (event != null && event.queryParameters["access_token"] != null) {
          box.put("access_token", event.queryParameters["access_token"]);
          box.put("refresh_token", event.queryParameters["refresh_token"]);
        }
      }, onError: (err) {
        log("[ERROR] UriLinkStream: $err");
      });

      launchUrl(Uri.parse("https://api.tear.one/oauth/discord/redirect"), mode: LaunchMode.externalApplication);
    }

    return MaterialApp(
      title: 'Material App',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Material App Bar'),
        ),
        body: Center(
          child: TextButton(
            child: Text('Hello World ${box.get("access_token")}'),
            onPressed: () => FlutterClipboard.copy(box.get("access_token")),
          ),
        ),
      ),
    );
  }
}
