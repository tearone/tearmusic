import 'dart:typed_data';

import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:tearmusic/ui/mobile/common/player/image_placeholder.dart';
import 'package:tearmusic/utils.dart';

class TrackImage extends StatelessWidget {
  const TrackImage({
    Key? key,
    this.image,
    required this.bottomOffset,
    required this.maxOffset,
    required this.screenSize,
    required this.cp,
    required this.p,
    this.width = 82.0,
    this.bytes,
    this.large = false,
  }) : super(key: key);

  factory TrackImage.fromBytes({
    required Size screenSize,
    required double bottomOffset,
    required double maxOffset,
    required double cp,
    required double p,
    required Uint8List bytes,
    double width = 82.0,
  }) {
    return TrackImage(
      bytes: bytes,
      bottomOffset: bottomOffset,
      maxOffset: maxOffset,
      screenSize: screenSize,
      cp: cp,
      p: p,
      width: width,
    );
  }

  final String? image;
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
    final borderRadius = SmoothBorderRadius(cornerRadius: vp(a: 18.0, b: 32.0, c: cp), cornerSmoothing: 1.0);

    return Transform.translate(
      offset: Offset(0, bottomOffset + (-maxOffset / 2.15 * p.clamp(0, 2))),
      child: Padding(
        padding: EdgeInsets.all(12.0 * (1 - cp)).add(EdgeInsets.only(left: 42.0 * cp)),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: SizedBox(
            height: vp(a: width, b: screenSize.width - 84.0, c: cp),
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
                child: ClipSmoothRect(
                  radius: borderRadius,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: bytes != null ? Image.memory(bytes!) : ImagePlaceholder(key: Key(image ?? "default"), large: large),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
