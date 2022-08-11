import 'dart:typed_data';

import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:tearmusic/models/music/images.dart';
import 'package:tearmusic/ui/mobile/common/cached_image.dart';
import 'package:tearmusic/ui/mobile/common/player/image_placeholder.dart';
import 'package:tearmusic/utils.dart';

class TrackImage extends StatelessWidget {
  const TrackImage({
    Key? key,
    this.images,
    required this.bottomOffset,
    required this.maxOffset,
    required this.screenSize,
    required this.cp,
    required this.p,
    this.width = 82.0,
    this.bytes,
    this.large = false,
  }) : super(key: key);

  final Images? images;
  final bool large;

  final double width;

  final double bottomOffset;
  final double maxOffset;
  final Size screenSize;
  final double cp;
  final double p;
  final Uint8List? bytes;

  @override
  Widget build(BuildContext context) {
    final radius = vp(a: 18.0, b: 32.0, c: cp);
    final borderRadius = SmoothBorderRadius(cornerRadius: radius, cornerSmoothing: 1.0);
    final size = vp(a: width, b: screenSize.width - 84.0, c: cp);

    return Transform.translate(
      offset: Offset(0, bottomOffset + (-maxOffset / 2.15 * p.clamp(0, 2))),
      child: Padding(
        padding: EdgeInsets.all(12.0 * (1 - cp)).add(EdgeInsets.only(left: 42.0 * cp)),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: SizedBox(
            height: size,
            width: size,
            child: Padding(
              padding: EdgeInsets.all(12.0 * (1 - cp)),
              child: Container(
                decoration: ShapeDecoration(
                  shape: SmoothRectangleBorder(borderRadius: borderRadius),
                  shadows: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.25 * cp),
                      blurRadius: 24.0,
                      offset: const Offset(0.0, 4.0),
                    ),
                  ],
                ),
                child: images != null
                    ? CachedImage(
                        images!,
                        borderRadius: radius,
                        setTheme: true,
                      )
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
