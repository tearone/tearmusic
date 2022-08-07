import 'package:flutter/widgets.dart';

class Images {
  final List<InternalImage> _internal;

  Images({required List<InternalImage> images}) : _internal = images {
    _internal.sort((a, b) => (a.height * a.width).compareTo(b.height * b.width));
    assert(_internal.isNotEmpty);
  }

  factory Images.fromJson(List<Map> json) {
    return Images(
      images: json.map((e) => InternalImage.fromJson(e)).toList(),
    );
  }

  String forSize(Size size) => _internal
      .firstWhere(
        (e) => e.width > size.width || e.height > size.height,
        orElse: () => _internal.last,
      )
      .url;

  String get maxSize => _internal.last.url;
  String get minSize => _internal.first.url;
}

class InternalImage {
  final String url;
  final int width;
  final int height;

  InternalImage({
    required this.url,
    required this.width,
    required this.height,
  });

  factory InternalImage.fromJson(Map json) {
    return InternalImage(
      url: json["url"],
      width: json["width"],
      height: json["height"],
    );
  }
}
