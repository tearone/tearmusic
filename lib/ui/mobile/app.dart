import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:tearmusic/providers/theme_provider.dart';
import 'package:tearmusic/ui/mobile/navigator.dart';

class App extends StatelessWidget {
  const App({super.key, required this.providers});

  final List<SingleChildWidget> providers;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: providers,
      child: Builder(builder: (context) {
        return MaterialApp(
          title: 'Tear Music',
          debugShowCheckedModeBanner: false,
          themeMode: ThemeMode.dark,
          darkTheme: context.select<ThemeProvider, ThemeData>((e) => e.appTheme),
          home: const NavigationScreen(),
        );
      }),
    );
  }
}
