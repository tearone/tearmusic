import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tearmusic/models/music/playlist.dart';
import 'package:tearmusic/ui/mobile/common/cached_image.dart';
import 'package:tearmusic/ui/mobile/common/playlist_view.dart';

class SearchPlaylistTile extends StatelessWidget {
  const SearchPlaylistTile(this.playlist, {Key? key}) : super(key: key);

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
      subtitle: Text("${playlist.owner} • ${playlist.trackCount} songs"),
      onTap: () {
        PlaylistView.view(playlist, context: context);
      },
    );
  }
}
