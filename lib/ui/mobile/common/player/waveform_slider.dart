import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tearmusic/models/playback.dart';
import 'package:tearmusic/providers/current_music_provider.dart';
import 'dart:math' as math;

class WaveformSlider extends StatefulWidget {
  const WaveformSlider({Key? key}) : super(key: key);

  @override
  State<WaveformSlider> createState() => _WaveformSliderState();
}

class _WaveformSliderState extends State<WaveformSlider> {
  int get tickerCount => waveform.isNotEmpty ? waveform.length : 50;
  double progress = 0.0;
  late List<double> waveform;
  late List<double> cachedWaveform;
  late List<bool> actives;
  bool sliding = false;

  double whereCenter = 0.0;
  late Timer loadingTimer;

  @override
  void initState() {
    super.initState();

    waveform = [];
    cachedWaveform = [];

    loadingTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (waveform.isNotEmpty) return;

      setState(() {
        whereCenter += math.sin(whereCenter * whereCenter + 1);
        if (whereCenter > 6) whereCenter = 0;
      });
    });
  }

  void generateWaveform() {
    final currentMusic = context.read<CurrentMusicProvider>();

    progress = currentMusic.duration != null ? currentMusic.position.inMilliseconds / currentMusic.duration!.inMilliseconds : 0.0;

    waveform = [];
    cachedWaveform = [];
    actives = List.generate(tickerCount, (i) => tickerCount * progress >= i);

    // currentMusic.tma?.playback.future.then((value) {
    //   final List<double> effects = [];
    //   final List<double> chunks = [];
    //   final chunkLen = value.waveform.length / tickerCount;

    //   final double min = value.waveform.reduce((a, b) => math.min(a.toDouble(), b.toDouble())).toDouble();
    //   final double max = value.waveform.reduce((a, b) => math.max(a.toDouble(), b.toDouble())).toDouble();

    //   for (var sample in value.waveform) {
    //     chunks.add(sample);

    //     if (chunks.length >= chunkLen) {
    //       final double average = chunks.fold<double>(0, (a, b) => a + b) / chunks.length;
    //       effects.add(normalizeInRange(average, min, max, 3.0, 40.0));
    //       chunks.clear();
    //     }
    //   }

    //   waveform = List.castFrom(effects);
    //   cachedWaveform = value.waveform;
    // });
  }

  void setProgress() {
    progress = progress.clamp(0.0, 1.0);
    setState(() {});
  }

  @override
  void dispose() {
    loadingTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentMusic = context.read<CurrentMusicProvider>();

    return Selector<CurrentMusicProvider, Completer<Playback>?>(
        selector: (_, cmp) => cmp.tma?.playback,
        builder: (context, value, child) {
          if (!value!.isCompleted) {
            waveform.clear();
          } else {
            value.future.then((value) {
              // if (value.waveform != cachedWaveform) generateWaveform();
            });
          }

          return StreamBuilder(
            stream: currentMusic.positionStream,
            builder: (context, snapshot) {
              final List<Widget> tickers = [];

              for (int i = 0; i < tickerCount; i++) {
                final bool active = tickerCount * progress >= i;

                if (sliding && active != actives[i]) {
                  HapticFeedback.lightImpact();
                  actives[i] = active;
                }

                tickers.add(AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 3.0,
                  height: waveform.isEmpty
                      ? normalizeInRange(math.sin(whereCenter - i * 0.5), -1.0, 1.0, 7.5, 25.0)
                      : waveform[i].toDouble() * (active ? 1.0 : 0.9),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(active ? 1.0 : 0.3),
                    borderRadius: BorderRadius.circular(45.0),
                  ),
                ));
              }

              if (!sliding) progress = currentMusic.progress;

              return LayoutBuilder(
                builder: (context, constraints) {
                  return GestureDetector(
                    onTapUp: (details) {
                      progress = details.localPosition.dx / constraints.maxWidth;
                      setProgress();
                      currentMusic.seek(Duration(milliseconds: ((currentMusic.duration?.inMilliseconds ?? 0) * progress).round()));
                      sliding = false;
                    },
                    onHorizontalDragStart: (details) {
                      sliding = true;
                    },
                    onHorizontalDragUpdate: (details) {
                      progress = details.localPosition.dx / constraints.maxWidth;
                      setProgress();
                    },
                    onHorizontalDragEnd: (details) {
                      currentMusic.seek(Duration(milliseconds: ((currentMusic.duration?.inMilliseconds ?? 0) * progress).round()));
                      sliding = false;
                    },
                    child: Container(
                      color: Colors.transparent,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: tickers,
                      ),
                    ),
                  );
                },
              );
            },
          );
        });
  }
}

double normalizeInRange(double val, double min1, double max1, double min2, double max2) {
  return min2 + ((val - min1) * (max2 - min2)) / (max1 - min1);
}
