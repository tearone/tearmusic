import 'dart:typed_data';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tearmusic/models/music/images.dart';
import 'package:http/http.dart' as http;

class CachedImage extends StatelessWidget {
  const CachedImage(this.images, {Key? key, this.borderRadius = 4.0}) : super(key: key);

  final Images images;
  final double borderRadius;

  Future<Uint8List> getImage(Size size) async {
    final uri = images.forSize(size);

    final box = await Hive.openBox("cached_images");
    Uint8List? bytes = box.get(uri);

    if (bytes == null) {
      final res = await http.get(Uri.parse(uri));
      bytes = res.bodyBytes;
    }

    box.put(uri, bytes);

    return bytes;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return FutureBuilder<Uint8List>(
        future: getImage(Size(constraints.maxWidth, constraints.maxHeight)),
        builder: (context, snapshot) {
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
                child: snapshot.hasData
                    ? Image.memory(
                        snapshot.data!,
                        width: constraints.maxWidth,
                        height: constraints.maxHeight,
                        fit: BoxFit.cover,
                      )
                    : SizedBox(
                        width: constraints.maxWidth,
                        height: constraints.maxHeight,
                        child: Card(
                          elevation: 0,
                          margin: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
                          color: Theme.of(context).colorScheme.surfaceVariant,
                          child: Icon(
                            Icons.music_note,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ),
              ),
            ),
          );
        },
      );
    });
  }
}
