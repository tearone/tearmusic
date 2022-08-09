import 'package:flutter/widgets.dart';
import 'package:tearmusic/models/model.dart';

class Images {
  final List<InternalImage> _internal;

  Images({required List<InternalImage> images}) : _internal = images {
    _internal.sort((a, b) => (a.height * a.width).compareTo(b.height * b.width));
    assert(_internal.isNotEmpty);
  }

  factory Images.decode(List<Map> json) {
    return Images(
      images: json.map((e) => InternalImage.decode(e)).toList(),
    );
  }

  List<Map> encode() => _internal.map((e) => e.encode()).toList();

  String forSize(Size size) => _internal
      .firstWhere(
        (e) => e.width > size.width || e.height > size.height,
        orElse: () => _internal.last,
      )
      .url;

  String get maxSize => _internal.last.url;
  String get minSize => _internal.first.url;
}

class InternalImage extends Model {
  final String url;
  final int width;
  final int height;

  InternalImage({
    required Map json,
    required this.url,
    required this.width,
    required this.height,
  }) : super(id: "${width}_${height}_$url", json: json);

  factory InternalImage.decode(Map json) {
    return InternalImage(
      json: json,
      url: json["url"],
      width: json["width"] ?? 0,
      height: json["height"] ?? 0,
    );
  }

  Map encode() => json;
}
