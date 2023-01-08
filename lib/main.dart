import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:tearmusic/api/base_api.dart';
import 'package:tearmusic/providers/current_music_provider.dart';
import 'package:tearmusic/providers/music_info_provider.dart';
import 'package:tearmusic/providers/navigator_provider.dart';
import 'package:tearmusic/providers/theme_provider.dart';
import 'package:tearmusic/providers/user_provider.dart';
import 'package:tearmusic/providers/will_pop_provider.dart';
import 'package:tearmusic/ui/mobile/app.dart';

void main() async {
  if (kIsWeb) return;

  // Initialize Hive
  await Hive.initFlutter();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Create Providers
  final baseApi = BaseApi();
  final musicInfoProvider = MusicInfoProvider(base: baseApi);

  final userProvider = UserProvider(base: baseApi, musicInfo: musicInfoProvider);
  final currentMusicProvider = CurrentMusicProvider();
  userProvider.setCurrentMusicProvider(currentMusicProvider);

  final themeProvider = ThemeProvider();

  // Initialize background audio
  // await AudioService.init(
  //   builder: () => currentMusicProvider,
  //   config: AudioServiceConfig(
  //     androidNotificationIcon: "mipmap/ic_splash",
  //     androidNotificationChannelId: "one.tear.tearmusic.channel.audio",
  //     androidNotificationChannelName: "Music playback",
  //     androidNotificationChannelDescription: "Music playback",
  //     androidNotificationClickStartsActivity: true,
  //     androidNotificationOngoing: false,
  //     androidResumeOnClick: true,
  //     androidShowNotificationBadge: false,
  //     androidStopForegroundOnPause: false,
  //     fastForwardInterval: const Duration(seconds: 10),
  //     rewindInterval: const Duration(seconds: 10),
  //     preloadArtwork: true,
  //     notificationColor: Colors.blue.shade900,
  //   ),
  // );

  // Initialize providers
  await userProvider.init();
  await musicInfoProvider.init();
  await currentMusicProvider.init();
  if (Platform.isAndroid) await FlutterDisplayMode.setHighRefreshRate();

  final providers = [
    ChangeNotifierProvider(create: (_) => userProvider),
    Provider(create: (_) => musicInfoProvider),
    ChangeNotifierProvider(create: (_) => themeProvider),
    ChangeNotifierProvider(create: (_) => currentMusicProvider),
    Provider(create: (_) => WillPopProvider()),
    ChangeNotifierProvider(create: (_) => NavigatorProvider(theme: themeProvider)),
  ];

  // Run app
  runApp(App(providers: providers));
}
