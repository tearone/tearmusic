import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';
import 'package:provider/provider.dart';
import 'package:tearmusic/providers/current_music_provider.dart';
import 'package:tearmusic/providers/theme_provider.dart';
import 'package:tearmusic/providers/user_provider.dart';
import 'package:tearmusic/providers/will_pop_provider.dart';
import 'package:tearmusic/ui/mobile/common/views/artist_view/artist_view.dart';
import 'package:tearmusic/utils.dart';

class TrackInfo extends StatelessWidget {
  const TrackInfo({
    Key? key,
    required this.title,
    required this.artist,
    required this.cp,
    required this.p,
    required this.screenSize,
    required this.bottomOffset,
    required this.maxOffset,
  }) : super(key: key);

  final String title;
  final String artist;

  final double cp;
  final double p;
  final Size screenSize;
  final double bottomOffset;
  final double maxOffset;

  @override
  Widget build(BuildContext context) {
    final double opacity = (inverseAboveOne(p) * 10 - 9).clamp(0, 1);

    return Transform.translate(
      offset: Offset(0, bottomOffset + (-maxOffset / 3.6 * p.clamp(0, 2))),
      child: Padding(
        padding: EdgeInsets.all(12.0 * (1 - cp)).add(EdgeInsets.symmetric(horizontal: 24.0 * cp)),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0).add(EdgeInsets.only(bottom: rangeProgress(a: 0, b: screenSize.width / 9, c: cp))),
            child: SizedBox(
              height: rangeProgress(a: 58.0, b: 82, c: cp),
              child: Row(
                children: [
                  SizedBox(width: 82.0 * (1 - cp)), // Image placeholder
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 42.0),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12.0),
                              onTap: cp == 1
                                  ? () {
                                      final currentMusic = context.read<CurrentMusicProvider>();
                                      if (currentMusic.playing != null) {
                                        context.read<WillPopProvider>().popper!();
                                        final tp = context.read<ThemeProvider>();
                                        ArtistView.view(currentMusic.playing!.artists[0], context: context).then((_) => tp.resetTheme());
                                      }
                                    }
                                  : null,
                              child: PageTransitionSwitcher(
                                transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
                                  return SharedAxisTransition(
                                    fillColor: Colors.transparent,
                                    animation: primaryAnimation,
                                    secondaryAnimation: secondaryAnimation,
                                    transitionType: SharedAxisTransitionType.horizontal,
                                    child: child,
                                  );
                                },
                                layoutBuilder: (entries) => Stack(children: entries),
                                child: Column(
                                  key: Key(title),
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      maxLines: 2,
                                      style: TextStyle(
                                        fontSize: rangeProgress(a: 18.0, b: 24.0, c: p),
                                        color: Colors.white.withOpacity(.9),
                                        fontWeight: FontWeight.w600,
                                        height: 1,
                                      ),
                                    ),
                                    Text(
                                      artist,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: rangeProgress(a: 15.0, b: 17.0, c: p),
                                        color: Colors.white.withOpacity(.5),
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Opacity(
                          opacity: opacity,
                          child: Transform.translate(
                            offset: Offset(-100 * (1.0 - cp), 0.0),
                            child: FutureBuilder(
                              future: context.read<UserProvider>().getLibrary(),
                              builder: (context, snapshot) {
                                final currentMusic = context.read<CurrentMusicProvider>();

                                return LikeButton(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  bubblesColor: BubblesColor(
                                    dotPrimaryColor: Theme.of(context).colorScheme.primary,
                                    dotSecondaryColor: Theme.of(context).colorScheme.primaryContainer,
                                  ),
                                  circleColor: CircleColor(
                                    start: Theme.of(context).colorScheme.tertiary,
                                    end: Theme.of(context).colorScheme.tertiary,
                                  ),
                                  isLiked: snapshot.hasData && currentMusic.playing != null
                                      ? snapshot.data!.liked_tracks.contains(currentMusic.playing!.id)
                                      : false,
                                  onTap: (isLiked) async {
                                    // context.read<CurrentMusicProvider>().setRating(Rating.newHeartRating(!isLiked));
                                    return !isLiked;
                                  },
                                  likeBuilder: (value) => value
                                      ? Icon(
                                          CupertinoIcons.heart_fill,
                                          color: Theme.of(context).colorScheme.primary,
                                          size: 32.0,
                                        )
                                      : Icon(
                                          CupertinoIcons.heart,
                                          color: Theme.of(context).colorScheme.onSecondaryContainer,
                                          size: 32.0,
                                        ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
