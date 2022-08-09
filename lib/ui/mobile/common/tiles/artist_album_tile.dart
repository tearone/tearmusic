import 'package:flutter/material.dart';
import 'package:tearmusic/models/music/album.dart';
import 'package:tearmusic/ui/mobile/common/cached_image.dart';
import 'package:tearmusic/ui/mobile/common/views/album_view/album_view.dart';

class ArtistAlbumTile extends StatelessWidget {
  const ArtistAlbumTile(this.album, {Key? key, this.then, this.size = 130}) : super(key: key);

  const ArtistAlbumTile.small(this.album, {Key? key, this.then, this.size = 110}) : super(key: key);

  final MusicAlbum album;
  final void Function()? then;

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      child: GestureDetector(
        onTap: () {
          AlbumView.view(album, context: context).then((_) => then != null ? then!() : null);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: Stack(
                children: [
                  CachedImage(album.images!),
                  Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      onTap: () {
                        AlbumView.view(album, context: context).then((_) => then != null ? then!() : null);
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                album.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: size / 10 + 1),
              ),
            ),
            Text(
              "${album.shortTitle} • ${album.releaseDate.year}",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary.withOpacity(.8),
                fontSize: size / 10 + 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
