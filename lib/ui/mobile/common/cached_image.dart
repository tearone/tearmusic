import 'dart:math';
import 'dart:typed_data';

import 'package:animations/animations.dart';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tearmusic/models/music/images.dart';
import 'package:http/http.dart' as http;

class CachedImage extends StatefulWidget {
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
  State<CachedImage> createState() => _CachedImageState();
}

class _CachedImageState extends State<CachedImage> {
  final _memo = AsyncMemoizer<Uint8List>();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return FutureBuilder<Uint8List>(
        future: _memo.runOnce(() => widget.getImage(Size(constraints.maxWidth, constraints.maxHeight))),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.done:
              return ClipRRect(
                borderRadius: BorderRadius.circular(widget.borderRadius),
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
                    child: snapshot.hasData
                        ? Transform.scale(
                            scale: 1.05,
                            child: Image.memory(
                              snapshot.data!,
                              width: constraints.maxWidth,
                              height: constraints.maxHeight,
                              fit: BoxFit.cover,
                            ),
                          )
                        : SizedBox(
                            width: constraints.maxWidth,
                            height: constraints.maxHeight,
                            child: Card(
                              elevation: 0,
                              margin: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(widget.borderRadius)),
                              color: Theme.of(context).colorScheme.secondaryContainer,
                              child: Icon(
                                Icons.music_note,
                                size: sqrt(constraints.maxWidth * constraints.maxHeight) / 2,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ),
                  ),
                ),
              );
            default:
              return SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
              );
          }
        },
      );
    });
  }
}
