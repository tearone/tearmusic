import 'dart:async';
import 'dart:developer' as dev;
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tearmusic/models/music/images.dart';
import 'package:http/http.dart' as http;
import 'package:tearmusic/ui/mobile/common/player/waveform_slider.dart';

class CachedImage extends StatefulWidget {
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
  State<CachedImage> createState() => _CachedImageState();
}

class _CachedImageState extends State<CachedImage> {
  Box? box;

  void initBox() async {
    box = await Hive.openBox("cached_images");
  }

  @override
  void initState() {
    super.initState();
    if (widget.cacheHighest) initBox();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return FutureBuilder<Uint8List?>(
          future: widget.getImage(widget.size ?? (Size(constraints.maxWidth, constraints.maxHeight)), initBox: box).then((value) {
            return value;
          }),
          builder: (context, snapshot) {
            Uint8List? highestImageBytes = box?.get(
                widget.images?.forSize(Size((widget.images?.maxSize.width ?? 400).toDouble(), (widget.images?.maxSize.height ?? 400).toDouble())));

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
                      ? widget.cacheHighest
                          ? Stack(
                              children: [
                                if (constraints.biggest.height < (widget.images?.minSize.height ?? 0) + 5)
                                  Image.memory(
                                    snapshot.data!,
                                    fit: BoxFit.cover,
                                    width: constraints.maxWidth,
                                    height: constraints.maxHeight,
                                  ),
                                if (highestImageBytes != null && constraints.biggest.height > (widget.images?.minSize.height ?? 0))
                                  Image.memory(
                                    highestImageBytes,
                                    fit: BoxFit.cover,
                                    width: constraints.maxWidth,
                                    height: constraints.maxHeight,
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
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(widget.borderRadius)),
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
            );
          });
    });
  }
}
