import 'package:flutter/material.dart';
import 'package:tearmusic/ui/mobile/navigator.dart';

class ThemePageState {
  ThemeData? _appThemeB;
  ThemeData? _navigationTheme;
  Color? _key;
}

class ThemeProvider extends ChangeNotifier {
  static final defaultTheme = coloredTheme(Colors.blue);

  MobileRoute? _currentRoute;
  final Map<MobileRoute, ThemePageState> _pages = {};
  ThemePageState get _defaultPlaceholderPage => ThemePageState();
  ThemePageState get _currentPage => _pages[_currentRoute] ?? _defaultPlaceholderPage;

  ThemeData? get _appThemeB => _currentPage._appThemeB;
  set _appThemeB(value) => _currentPage._appThemeB = value;
  ThemeData? get _navigationTheme => _currentPage._navigationTheme;
  set _navigationTheme(value) => _currentPage._navigationTheme = value;
  Color? get _key => _currentPage._key;
  set _key(value) => _currentPage._key = value;

  late ThemeData _appThemeA;
  ThemeData get appTheme => _appThemeB ?? _appThemeA;
  ThemeData get navigationTheme => _navigationTheme ?? _appThemeA;
  Color get key => _key ?? Colors.blue;

  ThemeProvider() {
    setTheme(defaultTheme);
  }

  void setState(MobileRoute route) {
    if (!_pages.keys.contains(route)) {
      _pages[route] = ThemePageState();
    }
  }

  void restoreState(MobileRoute route) {
    _currentRoute = route;
  }

  void tempAppTheme(ThemeData theme) {
    _appThemeB = theme;
    notifyListeners();
  }

  void tempNavTheme(ThemeData theme) {
    _navigationTheme = theme;
    notifyListeners();
  }

  void resetTheme() {
    _appThemeB = null;
    _navigationTheme = null;
    notifyListeners();
  }

  void setTheme(ThemeData theme) {
    _appThemeA = theme;
    notifyListeners();
  }

  void setThemeKey(Color color) {
    _key = color;
    setTheme(coloredTheme(color));
  }

  static ThemeData coloredTheme(Color color) {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: color,
      brightness: Brightness.dark,
      fontFamily: "Montserrat",
    );
  }
}
