import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class TrackLoadingTile extends StatelessWidget {
  TrackLoadingTile({Key? key, this.itemCount = 3}) : super(key: key);

  int itemCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 24.0, bottom: 8.0, top: 2.0),
      child: Shimmer.fromColors(
        baseColor: Colors.white.withOpacity(.05),
        highlightColor: Colors.white.withOpacity(.25),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: itemCount,
          itemBuilder: (_, __) => Padding(
            padding: const EdgeInsets.only(top: 12.0, bottom: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42.0,
                  height: 42.0,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.0),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: Random().nextInt(125) + 100,
                      height: 18.0,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 2.5),
                    ),
                    Container(
                      width: Random().nextInt(75) + 75,
                      height: 18.0,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
