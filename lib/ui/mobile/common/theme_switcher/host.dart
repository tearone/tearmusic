import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tearmusic/providers/theme_provider.dart';
import 'package:tearmusic/ui/mobile/common/theme_switcher/circle_clipper.dart';
import 'package:tearmusic/ui/mobile/common/theme_switcher/theme_splash.dart';

// Parts of the theme switcher code were stolen from https://github.com/kherel/animated_theme_switcher

class ThemeSwitcherHost extends StatefulWidget {
  const ThemeSwitcherHost({Key? key, required this.builder}) : super(key: key);

  final Widget Function(BuildContext) builder;

  @override
  State<ThemeSwitcherHost> createState() => _ThemeSwitcherHostState();
}

class _ThemeSwitcherHostState extends State<ThemeSwitcherHost> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final _globalKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    context.read<ThemeProvider>().newModel(ThemeModel(controller: _controller));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => context.read<ThemeProvider>().model,
      builder: (context, _) {
        log("CHANGE BUILD");
        final model = context.watch<ThemeModel>();
        Widget child;
        if (model.oldTheme == null || model.oldTheme == model.theme) {
          child = _getPage(model.theme, context);
        } else {
          late final Widget firstWidget, animWidget;
          firstWidget = RawImage(image: model.image);
          animWidget = _getPage(model.theme, context);
          child = Stack(
            children: [
              SizedBox(
                key: const ValueKey('ThemeSwitchingFirst'),
                child: firstWidget,
              ),
              AnimatedBuilder(
                key: const ValueKey('ThemeSwitchingSecond'),
                animation: model.controller,
                child: animWidget,
                builder: (context, child) {
                  return ClipPath(
                    clipper: ThemeSwitcherCircleClipper(
                      offset: model.switcherOffset,
                      sizeRate: model.animation,
                    ),
                    child: child,
                  );
                },
              ),
              IgnorePointer(
                child: AnimatedBuilder(
                  key: const ValueKey('ThemeSwitchingSplash'),
                  animation: model.controller,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: ThemeSplash(
                        offset: model.switcherOffset,
                        sizeRate: model.animation,
                      ),
                      child: const SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }
        return RepaintBoundary(
          key: model.previewContainer,
          child: child,
        );
      },
    );
  }

  Widget _getPage(ThemeData brandTheme, BuildContext context) {
    return Theme(
      key: _globalKey,
      data: brandTheme,
      child: widget.builder(context),
    );
  }
}
