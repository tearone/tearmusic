import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tearmusic/models/music/lyrics.dart';
import 'package:tearmusic/providers/current_music_provider.dart';

Widget Function(BuildContext, int) richSyncListBuilder(List<LyricsLine> richSync) {
  return (context, index) {
    final currentMusic = context.read<CurrentMusicProvider>();

    final richSyncLine = richSync[index];
    double progress([Duration? o]) => (richSyncLine.start + (o ?? Duration.zero)).inMilliseconds / currentMusic.player.duration!.inMilliseconds;
    double progressEnd() => richSyncLine.end.inMilliseconds / currentMusic.player.duration!.inMilliseconds;

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
                currentMusic.seek(richSyncLine.start);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                decoration: BoxDecoration(
                  color: value > progress() && value < progressEnd() ? Theme.of(context).colorScheme.secondary.withOpacity(.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children: richSyncLine.segments
                      .asMap()
                      .map((i, e) {
                        // if (actives[index][i] != (progress(e.offset) > animation.value)) {
                        //   actives[index][i] = progress(e.offset) > animation.value;
                        //   if (e.text.replaceAll(" ", "") != "") HapticFeedback.lightImpact();
                        // }

                        return MapEntry(
                            i,
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 200),
                              style: TextStyle(
                                color: value > progress(e.offset)
                                    ? value < progressEnd()
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
                                    color: Theme.of(context).colorScheme.secondary.withOpacity(value > progressEnd() ? .15 : 0),
                                  ),
                                ],
                              ),
                              child: Text(
                                e.text,
                                textAlign: TextAlign.center,
                              ),
                            ));
                      })
                      .values
                      .toList(),
                ),
              ),
            ),
          );
        });
  };
}
