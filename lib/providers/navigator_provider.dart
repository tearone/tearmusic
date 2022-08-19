import 'package:flutter/material.dart';
import 'package:tearmusic/providers/theme_provider.dart';

class NavigatorProvider {
  final List<String> _uriHistory = [];
  late NavigatorState _state;
  late ScaffoldMessengerState _messenger;
  final ThemeProvider _theme;

  NavigatorProvider({required ThemeProvider theme}) : _theme = theme;

  void setScaffoldState(ScaffoldMessengerState value) {
    _messenger = value;
  }

  void setState(NavigatorState value) {
    _state = value;
  }

  // NavigatorState get navigator => _state;

  Future<T?> push<T>(Route<T> route, {String? uri}) {
    if (uri != null) {
      if (_uriHistory.isNotEmpty && _uriHistory.last == uri) return Future.value(null);
      _uriHistory.add(uri);
    }
    return _state.push(route);
  }

  void pop<T extends Object?>([T? result]) {
    if (_uriHistory.isNotEmpty) _uriHistory.removeLast();
    _state.pop(result);
  }

  void clearHistory() {
    _uriHistory.clear();
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
