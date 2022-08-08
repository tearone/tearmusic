import 'package:flutter/material.dart';
import 'package:tearmusic/models/music/album.dart';
import 'package:tearmusic/ui/mobile/common/cached_image.dart';

class SearchAlbum extends StatelessWidget {
  const SearchAlbum(this.album, {Key? key}) : super(key: key);

  final MusicAlbum album;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      visualDensity: VisualDensity.compact,
      leading: SizedBox(
        width: 42,
        height: 42,
        child: CachedImage(album.images),
      ),
      title: Text(album.name),
      subtitle:
          Text("${album.artists.map((e) => e.name).join(", ")} • ${album.albumType == AlbumType.single ? "Single" : "${album.trackCount} songs"}"),
      onTap: () {},
    );
  }
}
