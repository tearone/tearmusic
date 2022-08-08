import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tearmusic/api/base_api.dart';
import 'package:tearmusic/providers/music_info_provider.dart';
import 'package:tearmusic/providers/theme_provider.dart';
import 'package:tearmusic/providers/user_provider.dart';
import 'package:tearmusic/ui/mobile/app.dart';

void main() async {
  await Hive.initFlutter();

  final baseApi = BaseApi();
  final userProvider = UserProvider(base: baseApi);
  final musicInfoProvider = MusicInfoProvider(base: baseApi);

  await userProvider.init();

  final providers = [
    ChangeNotifierProvider(create: (_) => userProvider),
    Provider(create: (_) => musicInfoProvider),
    ChangeNotifierProvider(create: (_) => ThemeProvider()),
  ];

  runApp(App(providers: providers));
}
