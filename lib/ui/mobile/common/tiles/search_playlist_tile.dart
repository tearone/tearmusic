import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tearmusic/models/music/playlist.dart';
import 'package:tearmusic/providers/theme_provider.dart';
import 'package:tearmusic/ui/mobile/common/cached_image.dart';
import 'package:tearmusic/ui/mobile/common/views/playlist_view.dart';

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
        child: playlist.images != null ? CachedImage(playlist.images!) : null,
      ),
      title: Text(playlist.name),
      subtitle: Text("${playlist.owner} • ${playlist.trackCount} songs"),
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
        PlaylistView.view(playlist, context: context).then((_) => context.read<ThemeProvider>().resetTheme());
      },
    );
  }
}
