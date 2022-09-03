import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tearmusic/models/music/artist.dart';
import 'package:tearmusic/providers/theme_provider.dart';
import 'package:tearmusic/ui/mobile/common/cached_image.dart';
import 'package:tearmusic/ui/mobile/common/views/artist_view/artist_view.dart';

class SearchArtistTile extends StatelessWidget {
  const SearchArtistTile(this.artist, {Key? key}) : super(key: key);

  final MusicArtist artist;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      visualDensity: VisualDensity.compact,
      leading: artist.images != null
          ? SizedBox(
              width: 42,
              height: 42,
              child: CachedImage(artist.images!, borderRadius: 45.0),
            )
          : Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.surfaceVariant,
              ),
              child: Center(
                child: Icon(
                  Icons.person,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
      title: Text(artist.name),
      subtitle: artist.genres.isNotEmpty ? Text(artist.genres.first) : null,
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
        ArtistView.view(artist, context: context).then((_) => context.read<ThemeProvider>().resetTheme());
      },
    );
  }
}
