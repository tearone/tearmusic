import 'package:flutter/material.dart';
import 'package:tearmusic/models/music/playlist.dart';
import 'package:tearmusic/ui/mobile/common/cached_image.dart';

class SearchPlaylist extends StatelessWidget {
  const SearchPlaylist(this.playlist, {Key? key}) : super(key: key);

  final MusicPlaylist playlist;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      visualDensity: VisualDensity.compact,
      leading: SizedBox(
        width: 42,
        height: 42,
        child: CachedImage(playlist.images),
      ),
      title: Text(playlist.name),
      subtitle: Text("${playlist.owner} • ${playlist.trackCount} tracks"),
      onTap: () {},
    );
  }
}
