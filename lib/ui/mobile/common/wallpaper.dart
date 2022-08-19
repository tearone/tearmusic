import 'package:animated_background/animated_background.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tearmusic/models/segmented.dart';
import 'package:tearmusic/providers/current_music_provider.dart';

class Wallpaper extends StatefulWidget {
  const Wallpaper({Key? key, this.child, this.particleOpacity = .1, this.gradient = true}) : super(key: key);

  final Widget? child;
  final double particleOpacity;
  final bool gradient;

  @override
  State<Wallpaper> createState() => _WallpaperState();
}

class _WallpaperState extends State<Wallpaper> with TickerProviderStateMixin {
  static const double maxSpeed = 100.0;
  static const double minBpm = 50.0;
  static const double maxBpm = 200.0;

  @override
  Widget build(BuildContext context) {
    final currentMusic = context.read<CurrentMusicProvider>();
    final tempo = context.select<CurrentMusicProvider, List<TempoSegment>?>((p) => p.tma?.playbackHead?.tempo);

    return MultiProvider(
      providers: [
        StreamProvider(create: (_) => currentMusic.player.positionStream.distinct(), initialData: currentMusic.player.position),
        StreamProvider(create: (_) => currentMusic.player.playingStream.distinct(), initialData: currentMusic.player.playing),
      ],
      builder: (context, child) => Consumer2<Duration, bool>(
        builder: (context, pos, playing, child) {
          final bpm = tempo?.firstWhere((e) => e.start > pos, orElse: () => tempo.last).bpm.clamp(minBpm, maxBpm);
          double speed;

          if (bpm != null) {
            speed = Curves.easeInOutCubic.transform(((bpm - minBpm) / (maxBpm - minBpm)).clamp(0.0, 1.0)) * maxSpeed;
          } else {
            speed = 3;
          }

          final background = AnimatedBackground(
            vsync: this,
            behaviour: RandomParticleBehaviour(
              options: ParticleOptions(
                baseColor: Theme.of(context).colorScheme.tertiary,
                spawnMaxRadius: 4,
                spawnMinRadius: 2,
                spawnMaxSpeed: speed,
                spawnMinSpeed: (speed - 10).clamp(0.0, maxSpeed),
                maxOpacity: widget.particleOpacity,
                minOpacity: 0,
                particleCount: 50,
              ),
            ),
            child: const SizedBox(),
          );

          return Stack(
            children: [
              if (widget.gradient)
                Container(
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
                ),
              AnimatedOpacity(
                duration: const Duration(seconds: 1),
                opacity: playing ? 1 : 0,
                child: background,
              ),
              if (widget.child != null) widget.child!,
            ],
          );
        },
      ),
    );
  }
}
