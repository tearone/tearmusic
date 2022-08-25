import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tearmusic/models/music/lyrics.dart';
import 'package:tearmusic/providers/current_music_provider.dart';

Widget Function(BuildContext, int) subtitleListBuilder(List<TimedSegment> subtitle) {
  return (context, index) {
    final currentMusic = context.read<CurrentMusicProvider>();

    final subtitleLine = subtitle[index];
    final subtitleNext = subtitle[(index + 1).clamp(0, subtitle.length - 1)];
    final progress = subtitleLine.offset.inMilliseconds / currentMusic.player.duration!.inMilliseconds;
    final progressEnd = (subtitleNext.offset.inMilliseconds - 200) / currentMusic.player.duration!.inMilliseconds;

    // if (actives[index][0] != (animation.value > progress)) {
    //   actives[index][0] = animation.value > progress;
    //   if (subtitle.text.replaceAll(" ", "") != "") HapticFeedback.lightImpact();
    // }

    String text = subtitleLine.text;
    if (text.trim() == "") {
      text = "🎶";
    }

    return StreamBuilder<Duration>(
      stream: currentMusic.player.positionStream,
      builder: (context, snapshot) {
        final value = snapshot.hasData && currentMusic.player.duration != null
            ? snapshot.data!.inMilliseconds / currentMusic.player.duration!.inMilliseconds
            : 0.0;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(12.0),
            onTap: () {
              currentMusic.seek(subtitleLine.offset);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
              decoration: BoxDecoration(
                color: value > progress && value < progressEnd ? Theme.of(context).colorScheme.secondary.withOpacity(.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  color: value > progress
                      ? value < progressEnd
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.secondary
                      : Theme.of(context).colorScheme.secondary.withOpacity(.3),
                  fontFamily: Theme.of(context).textTheme.bodyText2!.fontFamily,
                  fontWeight: FontWeight.bold,
                  fontSize: 22.0,
                  shadows: [
                    Shadow(
                      offset: const Offset(5.0, 6.0),
                      blurRadius: 0.0,
                      color: Theme.of(context).colorScheme.secondary.withOpacity(value > progressEnd ? .15 : 0),
                    ),
                  ],
                ),
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        );
      },
    );
  };
}
