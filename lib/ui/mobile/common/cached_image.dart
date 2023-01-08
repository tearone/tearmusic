import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tearmusic/models/music/images.dart';
import 'package:http/http.dart' as http;

class CachedImage extends StatelessWidget {
  const CachedImage(this.images, {Key? key, this.borderRadius = 4.0, this.setTheme = false, this.size, this.cacheHighest = false}) : super(key: key);

  final Images? images;
  final double borderRadius;
  final bool setTheme;
  final Size? size;
  final bool cacheHighest;

  Future<Uint8List?> getImage(Size boxSize, {Box? initBox}) async {
    if (images == null) return null;
    final uri = images!.forSize(size ?? boxSize);

    final box = initBox ?? await Hive.openBox("cached_images");
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
    Stopwatch watch = Stopwatch()..start();

    return LayoutBuilder(builder: (context, constraints) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: FutureBuilder<Uint8List?>(
              future: getImage(size ?? (Size(constraints.maxWidth, constraints.maxHeight))),
              builder: (context, snapshot) {
                return Stack(
                  children: [
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 250),
                      opacity: snapshot.hasData ? 1 : 0,
                      child: PageTransitionSwitcher(
                        transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
                          return FadeThroughTransition(
                            fillColor: Colors.transparent,
                            animation: primaryAnimation,
                            secondaryAnimation: secondaryAnimation,
                            child: child,
                          );
                        },
                        child: snapshot.hasData
                            ? cacheHighest
                                ? Stack(
                                    children: [
                                      if (constraints.biggest.height < (images?.minSize.height ?? 0) + 5)
                                        Image.memory(
                                          snapshot.data!,
                                          fit: BoxFit.cover,
                                          width: constraints.maxWidth,
                                          height: constraints.maxHeight,
                                        ),
                                      if (cacheHighest && constraints.biggest.height > (images?.minSize.height ?? 0))
                                        FutureBuilder<Uint8List?>(
                                          future:
                                              getImage(Size((images?.maxSize.width ?? 400).toDouble(), (images?.maxSize.height ?? 400).toDouble())),
                                          builder: (context, snapshot) {
                                            if (snapshot.data == null) return const SizedBox();

                                            return Image.memory(
                                              snapshot.data!,
                                              fit: BoxFit.cover,
                                              width: constraints.maxWidth,
                                              height: constraints.maxHeight,
                                            );
                                          },
                                        ),
                                    ],
                                  )
                                : Image.memory(
                                    snapshot.data!,
                                    fit: BoxFit.cover,
                                    width: constraints.maxWidth,
                                    height: constraints.maxHeight,
                                  )
                            : SizedBox(
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
                      ),
                    ),
                    if (snapshot.data != null && watch.elapsed.inMilliseconds < 250)
                      Image.memory(
                        snapshot.data!,
                        fit: BoxFit.cover,
                        width: constraints.maxWidth,
                        height: constraints.maxHeight,
                      ),
                  ],
                );
              }),
        ),
      );
    });
  }
}
