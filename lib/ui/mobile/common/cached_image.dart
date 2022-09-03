import 'dart:math';
import 'dart:typed_data';

import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tearmusic/models/music/images.dart';
import 'package:http/http.dart' as http;

class CachedImage extends StatelessWidget {
  const CachedImage(this.images, {Key? key, this.borderRadius = 4.0, this.setTheme = false, this.size}) : super(key: key);

  final Images images;
  final double borderRadius;
  final bool setTheme;
  final Size? size;

  Future<Uint8List> getImage(Size boxSize) async {
    final uri = images.forSize(size ?? boxSize);

    final box = await Hive.openBox("cached_images");
    Uint8List? bytes = box.get(uri);

    if (bytes == null) {
      final res = await http.get(Uri.parse(uri));
      bytes = res.bodyBytes;
      box.put(uri, bytes);
    }

    return bytes;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: PageTransitionSwitcher(
            transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
              return FadeThroughTransition(
                fillColor: Colors.transparent,
                animation: primaryAnimation,
                secondaryAnimation: secondaryAnimation,
                child: child,
              );
            },
            child: CachedNetworkImage(
              imageUrl: images.forSize(size ?? (Size(constraints.maxWidth, constraints.maxHeight))),
              placeholder: (context, url) => SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                child: Card(
                  elevation: 0,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  child: Icon(
                    CupertinoIcons.music_note,
                    size: sqrt(constraints.maxWidth * constraints.maxHeight) / 2,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
              fadeInDuration: const Duration(milliseconds: 50),
              fadeOutDuration: const Duration(milliseconds: 50),
              placeholderFadeInDuration: const Duration(milliseconds: 50),
            ),
          ),
        ),
      );
    });
  }
}
