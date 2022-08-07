import 'package:flutter/material.dart';
import 'package:tearmusic/models/music/playlist.dart';

class SearchPlaylist extends StatelessWidget {
  const SearchPlaylist(this.playlist, {Key? key}) : super(key: key);

  final MusicPlaylist playlist;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      visualDensity: VisualDensity.compact,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(2.0),
        child: SizedBox(
          width: 42,
          height: 42,
          child: Image.network(
            playlist.images.forSize(const Size(42, 42)),
            width: 42,
            height: 42,
            fit: BoxFit.contain,
          ),
        ),
      ),
      title: Text(playlist.name),
      subtitle: Text("${playlist.owner} • ${playlist.trackCount} tracks"),
      onTap: () {},
    );
  }
}
