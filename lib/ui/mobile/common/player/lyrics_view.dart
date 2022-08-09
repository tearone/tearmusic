import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:tearmusic/models/music/lyrics.dart';
import 'package:tearmusic/models/music/track.dart';
import 'package:tearmusic/providers/music_info_provider.dart';

class LyricsView extends StatefulWidget {
  const LyricsView(this.track, {Key? key}) : super(key: key);

  final MusicTrack track;

  static Future<void> view(MusicTrack value, {required BuildContext context}) => Navigator.of(context).push(
        CupertinoPageRoute(
          builder: (context) => LyricsView(value),
        ),
      );

  @override
  State<LyricsView> createState() => _LyricsViewState();
}

class _LyricsViewState extends State<LyricsView> with SingleTickerProviderStateMixin {
  late AnimationController animation;

  @override
  void initState() {
    super.initState();

    animation = AnimationController(
      vsync: this,
      duration: widget.track.duration,
    );
    animation.forward();
  }

  @override
  void dispose() {
    animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<MusicLyrics>(
          future: context.read<MusicInfoProvider>().lyrics(widget.track),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 200.0),
                child: Center(
                  child: LoadingAnimationWidget.staggeredDotsWave(
                    color: Theme.of(context).colorScheme.secondary.withOpacity(.2),
                    size: 64.0,
                  ),
                ),
              );
            }

            return ListView(
              children: [
                Text(snapshot.data!.lyricsType.name),
                if (snapshot.data!.lyricsType == LyricsType.fullText)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      snapshot.data!.fullText!,
                      style: const TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (snapshot.data!.lyricsType == LyricsType.subtitle)
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: snapshot.data!.subtitle!.length,
                    itemBuilder: (context, index) {
                      final subtitle = snapshot.data!.subtitle![index];
                      final progress = subtitle.offset.inMilliseconds / widget.track.duration.inMilliseconds;

                      return AnimatedBuilder(
                          animation: animation,
                          builder: (context, child) {
                            return Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                snapshot.data!.subtitle![index].text,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(animation.value > progress ? 1.0 : 0.5),
                                  fontSize: 22.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          });
                    },
                  ),
                const SizedBox(height: 200),
              ],
            );
          },
        ),
      ),
    );
  }
}
