import 'package:flutter/material.dart';
import 'package:tearmusic/models/music/artist.dart';
import 'package:tearmusic/ui/mobile/common/cached_image.dart';
import 'package:tearmusic/ui/mobile/common/views/artist_view/artist_view.dart';

class ArtistArtistTile extends StatelessWidget {
  const ArtistArtistTile(this.artist, {Key? key, this.then}) : super(key: key);

  final MusicArtist artist;
  final void Function()? then;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ArtistView.view(artist, context: context).then((_) => then != null ? then!() : null);
      },
      child: SizedBox(
        width: 100,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: ClipOval(
                child: Stack(
                  children: [
                    CachedImage(artist.images!),
                    Material(
                      type: MaterialType.transparency,
                      child: InkWell(
                        onTap: () {
                          ArtistView.view(artist, context: context).then((_) => then != null ? then!() : null);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Text(
                artist.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
