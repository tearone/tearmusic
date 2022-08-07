import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';
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
      offset: Offset(0, bottomOffset + (-maxOffset / 3.8 * p.clamp(0, 2))),
      child: Padding(
        padding: EdgeInsets.all(12.0 * (1 - cp)).add(EdgeInsets.symmetric(horizontal: 24.0 * cp)),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: SizedBox(
            height: vp(a: 82.0, b: screenSize.width / 2, c: cp),
            child: Row(
              children: [
                SizedBox(width: 82.0 * (1 - cp)), // Image placeholder
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: vp(a: 18.0, b: 24.0, c: p),
                                color: Colors.white.withOpacity(.9),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              artist,
                              style: TextStyle(
                                fontSize: vp(a: 15.0, b: 17.0, c: p),
                                color: Colors.white.withOpacity(.5),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Opacity(
                        opacity: opacity,
                        child: Transform.translate(
                          offset: Offset(-100 * (1.0 - cp), 0.0),
                          child: LikeButton(
                            bubblesColor: BubblesColor(
                              dotPrimaryColor: Theme.of(context).colorScheme.primary,
                              dotSecondaryColor: Theme.of(context).colorScheme.primaryContainer,
                            ),
                            circleColor: CircleColor(
                              start: Theme.of(context).colorScheme.tertiary,
                              end: Theme.of(context).colorScheme.tertiary,
                            ),
                            likeBuilder: (value) => value
                                ? Icon(
                                    Icons.favorite,
                                    color: Theme.of(context).colorScheme.primary,
                                    size: 30.0,
                                  )
                                : Icon(
                                    Icons.favorite_border_outlined,
                                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                                    size: 30.0,
                                  ),
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
    );
  }
}
