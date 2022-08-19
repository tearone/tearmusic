import 'package:animated_background/animated_background.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tearmusic/providers/current_music_provider.dart';

class Wallpaper extends StatefulWidget {
  const Wallpaper({Key? key, this.child}) : super(key: key);

  final Widget? child;

  @override
  State<Wallpaper> createState() => _WallpaperState();
}

class _WallpaperState extends State<Wallpaper> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      initialData: false,
      stream: context.read<CurrentMusicProvider>().player.playingStream,
      builder: (context, value) => Container(
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
        child: AnimatedBackground(
          vsync: this,
          behaviour: RandomParticleBehaviour(
            options: ParticleOptions(
              baseColor: Theme.of(context).colorScheme.tertiary,
              spawnMaxRadius: 4,
              spawnMinRadius: 2,
              spawnMaxSpeed: 20,
              spawnMinSpeed: 10,
              maxOpacity: value.data ?? false ? .1 : 0,
              minOpacity: 0,
              particleCount: 200,
            ),
          ),
          child: widget.child ?? const SizedBox(),
        ),
      ),
    );
  }
}
