import 'package:flutter/material.dart';
import 'package:tearmusic/models/music/album.dart';
import 'package:tearmusic/ui/mobile/common/album_view.dart';
import 'package:tearmusic/ui/mobile/common/cached_image.dart';

class SearchAlbumTile extends StatelessWidget {
  const SearchAlbumTile(this.album, {Key? key}) : super(key: key);

  final MusicAlbum album;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      visualDensity: VisualDensity.compact,
      leading: SizedBox(
        width: 42,
        height: 42,
        child: CachedImage(album.images!),
      ),
      title: Text(album.name),
      subtitle:
          Text("${album.artists.map((e) => e.name).join(", ")} • ${album.albumType == AlbumType.single ? "Single" : "${album.trackCount} songs"}"),
      onTap: () {
        AlbumView.view(album, context: context);
      },
    );
  }
}
