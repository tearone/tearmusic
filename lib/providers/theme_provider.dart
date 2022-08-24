import 'dart:async';
import 'dart:developer';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:tearmusic/ui/mobile/navigator.dart';

class ThemePageState {
  ThemeData? _appThemeB;
  ThemeData? _navigationTheme;
  Color? _key;
}

class ThemeModel extends ChangeNotifier {
  ui.Image? image;
  final AnimationController controller;
  ThemeData? oldTheme;
  late ThemeData _theme;
  ThemeData get theme => _theme;
  final previewContainer = GlobalKey();
  late Offset switcherOffset;
  Timer? timer;

  double get animation => Curves.easeIn.transform(controller.value);

  ThemeModel({required this.controller});

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void changeTheme({
    required ThemeData theme,
    required GlobalKey key,
  }) async {
    if (controller.isAnimating) {
      return;
    }

    oldTheme = _theme;
    _theme = theme;
    switcherOffset = _getSwitcherCoordinates(key);
    await _saveScreenshot();

    await controller.forward(from: 0.0);
  }

  Future<void> _saveScreenshot() async {
    final boundary = previewContainer.currentContext!.findRenderObject() as RenderRepaintBoundary;
    image = await boundary.toImage(pixelRatio: ui.window.devicePixelRatio);
    log("NOTIFY");
    notifyListeners();
  }

  Offset _getSwitcherCoordinates(GlobalKey<State<StatefulWidget>> switcherGlobalKey) {
    final renderObject = switcherGlobalKey.currentContext!.findRenderObject()! as RenderBox;
    final size = renderObject.size;
    return renderObject.localToGlobal(Offset.zero).translate(size.width / 2, size.height / 2);
  }
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

  ThemeData get appTheme => _appThemeB ?? _model._theme;
  ThemeData get navigationTheme => _navigationTheme ?? _model._theme;
  Color get key => _key ?? Colors.blue;

  late ThemeModel _model;
  ThemeModel get model => _model;

  void setState(MobileRoute route) {
    if (!_pages.keys.contains(route)) {
      _pages[route] = ThemePageState();
    }
  }

  void restoreState(MobileRoute route) {
    _currentRoute = route;
  }

  void newModel(ThemeModel value) {
    _model = value;
    setTheme(defaultTheme);
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

  void setTheme(ThemeData theme, {GlobalKey? key}) {
    // _appThemeA = theme;
    if (key != null) {
      _model.changeTheme(
        key: key,
        theme: theme,
      );
    } else {
      _model._theme = theme;
    }
  }

  void setThemeKey(Color color, {GlobalKey? key}) {
    _key = color;
    setTheme(coloredTheme(color), key: key);
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
