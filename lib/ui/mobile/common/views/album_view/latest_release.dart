import 'package:flutter/material.dart';
import 'package:tearmusic/models/music/album.dart';
import 'package:tearmusic/ui/mobile/common/views/album_view/album_view.dart';
import 'package:tearmusic/ui/mobile/common/cached_image.dart';

class LatestRelease extends StatelessWidget {
  const LatestRelease(this.album, {Key? key, this.then}) : super(key: key);

  final MusicAlbum album;
  final void Function()? then;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: InkWell(
        onTap: () {
          AlbumView.view(album, context: context).then((_) => then != null ? then!() : null);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Latest Release".toUpperCase(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary.withOpacity(.65),
                          fontWeight: FontWeight.w600,
                          fontSize: 13.0,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          album.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        "${album.releaseDate.year} • ${album.albumType.title}",
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 64,
                height: 64,
                child: CachedImage(album.images!),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
