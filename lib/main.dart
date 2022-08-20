import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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

  await Hive.initFlutter();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final baseApi = BaseApi();
  final musicInfoProvider = MusicInfoProvider(base: baseApi);
  final userProvider = UserProvider(base: baseApi, musicInfo: musicInfoProvider);
  final currentMusicProvider = CurrentMusicProvider(api: musicInfoProvider);
  final themeProvider = ThemeProvider();

  await userProvider.init();
  await musicInfoProvider.init();

  final providers = [
    ChangeNotifierProvider(create: (_) => userProvider),
    Provider(create: (_) => musicInfoProvider),
    ChangeNotifierProvider(create: (_) => themeProvider),
    ChangeNotifierProvider(create: (_) => currentMusicProvider),
    Provider(create: (_) => WillPopProvider()),
    ChangeNotifierProvider(create: (_) => NavigatorProvider(theme: themeProvider)),
  ];

  runApp(App(providers: providers));
}
