import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:tearmusic/ui/mobile/navigator.dart';

class App extends StatelessWidget {
  const App({super.key, required this.providers});

  final List<SingleChildWidget> providers;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tear Music',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.dark,
        fontFamily: "Montserrat",
      ),
      builder: (context, child) {
        return MultiProvider(
          providers: providers,
          child: child,
        );
      },
      home: const NavigationScreen(),
    );
  }
}
