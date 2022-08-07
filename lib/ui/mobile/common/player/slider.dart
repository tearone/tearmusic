import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WaveformSlider extends StatefulWidget {
  const WaveformSlider({Key? key}) : super(key: key);

  @override
  State<WaveformSlider> createState() => _WaveformSliderState();
}

class _WaveformSliderState extends State<WaveformSlider> {
  static const int tickerCount = 50;
  double progress = 0.0;
  late List<int> waveform;
  late List<bool> actives;

  @override
  void initState() {
    super.initState();

    actives = [];
    waveform = [];
    for (int i = 0; i < tickerCount; i++) {
      actives.add(i == 0);
      waveform.add(Random().nextInt(30) + 10);
    }
  }

  void setProgress() {
    progress = progress.clamp(0.0, 1.0);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tickers = [];

    for (int i = 0; i < tickerCount; i++) {
      final bool active = tickerCount * progress >= i;

      if (active != actives[i]) {
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

    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTapUp: (details) {
            progress = details.localPosition.dx / constraints.maxWidth;
            setProgress();
          },
          onHorizontalDragStart: (details) {},
          onHorizontalDragUpdate: (details) {
            progress = details.localPosition.dx / constraints.maxWidth;
            setProgress();
          },
          onHorizontalDragEnd: (details) {},
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
  }
}
