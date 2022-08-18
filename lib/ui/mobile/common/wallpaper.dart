import 'package:flutter/material.dart';

class Wallpaper extends StatelessWidget {
  const Wallpaper({Key? key, this.child}) : super(key: key);

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0.95, -0.95),
          radius: 1.0,
          colors: [
            Theme.of(context).colorScheme.onSecondary.withOpacity(.4),
            Theme.of(context).colorScheme.onSecondary.withOpacity(.2),
          ],
        ),
      ),
      child: child,
    );
  }
}
