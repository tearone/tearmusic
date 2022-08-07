import 'package:flutter/material.dart';
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
                          child: IconButton(
                            onPressed: () {},
                            iconSize: 30.0,
                            icon: Icon(Icons.favorite_border, color: Theme.of(context).colorScheme.onSecondaryContainer),
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
