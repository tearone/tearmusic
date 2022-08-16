import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tearmusic/providers/current_music_provider.dart';

class WaveformSlider extends StatefulWidget {
  const WaveformSlider({Key? key}) : super(key: key);

  @override
  State<WaveformSlider> createState() => _WaveformSliderState();
}

class _WaveformSliderState extends State<WaveformSlider> {
  static const int tickerCount = 50;
  double progress = 0.0;
  late List<double> waveform;
  late List<bool> actives;
  bool sliding = false;

  @override
  void initState() {
    super.initState();

    final currentMusic = context.read<CurrentMusicProvider>();

    actives = [];
    waveform = [];

    currentMusic.tma!.playback.future.then((value) {
      for (int i = 0; i < tickerCount; i++) {
        actives.add(i == 0);
        waveform.add(value.waveform[(value.waveform.length / tickerCount * i).floor()]);
      }
    });
  }

  void setProgress() {
    progress = progress.clamp(0.0, 1.0);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final currentMusic = context.read<CurrentMusicProvider>();

    return StreamBuilder(
      stream: currentMusic.player.positionStream,
      builder: (context, snapshot) {
        final List<Widget> tickers = [];

        for (int i = 0; i < tickerCount; i++) {
          final bool active = tickerCount * progress >= i;

          if (sliding && active != actives[i]) {
            HapticFeedback.lightImpact();
            actives[i] = active;
          }

          tickers.add(AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: 3.0,
            height: waveform[i].toDouble() * (active ? 1.0 : 0.8),
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
                currentMusic.player.seek(Duration(milliseconds: ((currentMusic.player.duration?.inMilliseconds ?? 0) * progress).round()));
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
                currentMusic.player.seek(Duration(milliseconds: ((currentMusic.player.duration?.inMilliseconds ?? 0) * progress).round()));
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
  }
}
