import 'package:flutter/material.dart';
import 'package:tearmusic/providers/theme_provider.dart';

class NavigatorProvider {
  late ScaffoldMessengerState _messenger;
  final ThemeProvider _theme;

  NavigatorProvider({required ThemeProvider theme}) : _theme = theme;

  void setState(ScaffoldMessengerState value) {
    _messenger = value;
  }

  void showSnackBar(SnackBar snackBar) {
    final theme = _theme.appTheme;
    _messenger.showSnackBar(SnackBar(
      content: DefaultTextStyle(
        style: theme.textTheme.bodyText2!,
        child: snackBar.content,
      ),
      backgroundColor: theme.colorScheme.background,
    ));
  }
}
