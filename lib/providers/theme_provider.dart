import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  static final defaultTheme = coloredTheme(Colors.blue);

  ThemeProvider() {
    setTheme(defaultTheme);
  }

  late ThemeData _appThemeA;
  late ThemeData _navigationThemeA;
  ThemeData? _appThemeB;
  ThemeData? _navigationThemeB;

  ThemeData get appTheme => _appThemeB ?? _appThemeA;
  ThemeData get navigationTheme => _navigationThemeB ?? _navigationThemeA;

  void tempAppTheme(ThemeData theme) {
    _appThemeB = theme;
    notifyListeners();
  }

  void tempNavTheme(ThemeData theme) {
    _navigationThemeB = theme;
    notifyListeners();
  }

  void resetTheme() {
    _appThemeB = null;
    _navigationThemeB = null;
    notifyListeners();
  }

  void setTheme(ThemeData theme) {
    _appThemeA = theme;
    _navigationThemeA = theme;
    notifyListeners();
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
