import 'package:flutter/material.dart';
import 'package:sheet/route.dart';
import 'package:tearmusic/providers/theme_provider.dart';
import 'package:tearmusic/ui/mobile/common/bottom_sheet.dart';
import 'package:tearmusic/ui/mobile/navigator.dart';

class NavigatorPageState {
  final List<String> _uriHistory = [];
  NavigatorState _state;

  NavigatorPageState({
    required NavigatorState state,
  }) : _state = state;
}

class NavigatorProvider extends ChangeNotifier {
  late ScaffoldMessengerState _messenger;
  final ThemeProvider _theme;

  MobileRoute? currentRoute;
  final Map<MobileRoute, NavigatorPageState> _pages = {};
  NavigatorPageState get _currentPage => _pages[currentRoute]!;

  List<String> get _uriHistory => _currentPage._uriHistory;
  NavigatorState get _state => _currentPage._state;

  NavigatorProvider({required ThemeProvider theme}) : _theme = theme;

  void setScaffoldState(ScaffoldMessengerState value) {
    _messenger = value;
  }

  void setState(MobileRoute route, NavigatorState value) {
    if (!_pages.keys.contains(route)) {
      _pages[route] = NavigatorPageState(state: value);
    } else {
      _pages[route]!._state = value;
    }
  }

  void restoreState(MobileRoute route, {bool notify = false}) {
    currentRoute = route;
    if (notify) notifyListeners();
  }

  Future<T?> push<T>(Route<T> route, {String? uri}) {
    if (uri != null) {
      if (_uriHistory.isNotEmpty && _uriHistory.last == uri) return Future.value(null);
      _uriHistory.add(uri);
    }
    return _state.push(route);
  }

  Future<T?> pushModal<T>({required Widget Function(BuildContext) builder, String? uri}) {
    return push<T>(
      SheetRoute<T>(
        builder: builder,
        // duration: const Duration(milliseconds: 300),
        // animationCurve: Curves.fastLinearToSlowEaseIn,
      ),
      uri: uri,
    ).then((value) {
      if (_uriHistory.isNotEmpty) _uriHistory.removeLast();
      return value;
    });
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
