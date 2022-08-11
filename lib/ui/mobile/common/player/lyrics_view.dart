import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:tearmusic/models/music/lyrics.dart';
import 'package:tearmusic/models/music/track.dart';
import 'package:tearmusic/providers/current_music_provider.dart';
import 'package:tearmusic/providers/music_info_provider.dart';

class LyricsView extends StatefulWidget {
  const LyricsView(this.track, {Key? key}) : super(key: key);

  final MusicTrack track;

  static Future<void> view(MusicTrack value, {required BuildContext context}) => Navigator.of(context, rootNavigator: true).push(
        CupertinoPageRoute(builder: (context) => LyricsView(value), fullscreenDialog: true),
      );

  @override
  State<LyricsView> createState() => _LyricsViewState();
}

class _LyricsViewState extends State<LyricsView> with SingleTickerProviderStateMixin {
  late AnimationController animation;
  List<GlobalKey> keys = [];

  @override
  void initState() {
    super.initState();

    final currentMusic = context.read<CurrentMusicProvider>();

    animation = AnimationController(
      vsync: this,
      duration: widget.track.duration,
    );

    animation.animateTo(currentMusic.player.position.inMilliseconds / widget.track.duration.inMilliseconds, duration: Duration.zero);
    if (currentMusic.player.playing) animation.forward();
  }

  @override
  void dispose() {
    animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<MusicLyrics>(
        future: context.read<MusicInfoProvider>().lyrics(widget.track),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                color: Theme.of(context).colorScheme.secondary.withOpacity(.2),
                size: 64.0,
              ),
            );
          }

          if (keys.isEmpty) keys = List.generate(snapshot.data!.richSync?.length ?? snapshot.data!.subtitle?.length ?? 0, (index) => GlobalKey());

          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: SizedBox(height: 200 + MediaQuery.of(context).padding.top),
                  ),
                  if (snapshot.data!.lyricsType == LyricsType.unavailable)
                    SliverToBoxAdapter(
                      child: Center(
                        child: Column(
                          children: [
                            const Text(
                              "🫤",
                              style: TextStyle(
                                fontSize: 64.0,
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(top: 12.0),
                              child: Text(
                                "Sorry, no lyrics...",
                                style: TextStyle(
                                  fontSize: 32.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 100.0),
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back),
                                iconSize: 32.0,
                                padding: const EdgeInsets.all(12.0),
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.secondaryContainer),
                                  foregroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.onSecondaryContainer),
                                ),
                                onPressed: () {
                                  Navigator.of(context, rootNavigator: true).pop();
                                },
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(top: 12.0),
                              child: Text("Back"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (snapshot.data!.lyricsType == LyricsType.fullText)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          snapshot.data!.fullText!,
                          style: const TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  if (snapshot.data!.lyricsType == LyricsType.subtitle)
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        childCount: snapshot.data!.subtitle!.length,
                        (context, index) {
                          final subtitle = snapshot.data!.subtitle![index];
                          final subtitleNext = snapshot.data!.subtitle![(index + 1).clamp(0, snapshot.data!.subtitle!.length - 1)];
                          final progress = subtitle.offset.inMilliseconds / widget.track.duration.inMilliseconds;
                          final progressEnd = (subtitleNext.offset.inMilliseconds - 200) / widget.track.duration.inMilliseconds;

                          return AnimatedBuilder(
                              animation: animation,
                              builder: (context, child) {
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  if (animation.value > progress && animation.value < progressEnd) {
                                    final key = keys[(index + 2).clamp(0, keys.length - 1)].currentContext;
                                    if (key != null) {
                                      Scrollable.ensureVisible(
                                        key,
                                        duration: const Duration(milliseconds: 500),
                                        alignment: 0.5,
                                      );
                                    }
                                  }
                                });

                                return AnimatedContainer(
                                  key: keys[index],
                                  duration: const Duration(milliseconds: 500),
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                                  margin: const EdgeInsets.symmetric(horizontal: 12.0),
                                  decoration: BoxDecoration(
                                    color: animation.value > progress && animation.value < progressEnd
                                        ? Theme.of(context).colorScheme.secondary.withOpacity(.1)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 200),
                                    style: TextStyle(
                                      color: animation.value > progress
                                          ? animation.value < progressEnd
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
                                          color: Theme.of(context).colorScheme.secondary.withOpacity(animation.value > progressEnd ? .15 : 0),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      snapshot.data!.subtitle![index].text,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                );
                              });
                        },
                      ),
                    ),
                  if (snapshot.data!.lyricsType == LyricsType.richsync)
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        childCount: snapshot.data!.richSync!.length,
                        (context, index) {
                          final richSync = snapshot.data!.richSync![index];
                          double progress([Duration? o]) =>
                              (richSync.start + (o ?? Duration.zero)).inMilliseconds / widget.track.duration.inMilliseconds;
                          double progressEnd() => richSync.end.inMilliseconds / widget.track.duration.inMilliseconds;

                          return AnimatedBuilder(
                              animation: animation,
                              builder: (context, child) {
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  if (animation.value > progress() && animation.value < progressEnd()) {
                                    Scrollable.ensureVisible(
                                      keys[(index + 2).clamp(0, keys.length - 1)].currentContext!,
                                      duration: const Duration(milliseconds: 500),
                                      alignment: 0.5,
                                    );
                                  }
                                });

                                return AnimatedContainer(
                                  key: keys[index],
                                  duration: const Duration(milliseconds: 500),
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                                  margin: const EdgeInsets.symmetric(horizontal: 12.0),
                                  decoration: BoxDecoration(
                                    color: animation.value > progress() && animation.value < progressEnd()
                                        ? Theme.of(context).colorScheme.secondary.withOpacity(.1)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Wrap(
                                    alignment: WrapAlignment.center,
                                    children: richSync.segments.map((e) {
                                      return AnimatedDefaultTextStyle(
                                        duration: const Duration(milliseconds: 200),
                                        style: TextStyle(
                                          color: animation.value > progress(e.offset)
                                              ? animation.value < progressEnd()
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
                                              color: Theme.of(context).colorScheme.secondary.withOpacity(animation.value > progressEnd() ? .15 : 0),
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          e.text,
                                          textAlign: TextAlign.center,
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                );
                              });
                        },
                      ),
                    ),
                  SliverToBoxAdapter(
                    child: SizedBox(height: 200 + MediaQuery.of(context).padding.bottom),
                  ),
                ],
              ),
              if (snapshot.data!.lyricsType != LyricsType.unavailable)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0, .3, .6, 1],
                          colors: [
                            Theme.of(context).scaffoldBackgroundColor.withOpacity(.7),
                            Theme.of(context).scaffoldBackgroundColor.withOpacity(0),
                            Theme.of(context).scaffoldBackgroundColor.withOpacity(0),
                            Theme.of(context).scaffoldBackgroundColor.withOpacity(.8),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              if (snapshot.data!.lyricsType != LyricsType.unavailable)
                const SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: BackButton(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
