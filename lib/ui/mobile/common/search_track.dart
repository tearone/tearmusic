import 'package:flutter/material.dart';
import 'package:tearmusic/models/music/track.dart';
import 'package:tearmusic/ui/mobile/common/cached_image.dart';

class SearchTrack extends StatelessWidget {
  const SearchTrack(this.track, {Key? key}) : super(key: key);

  final MusicTrack track;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: SizedBox(
        width: 42,
        height: 42,
        child: CachedImage(track.album.images),
      ),
      title: Text(
        track.name,
        maxLines: 2,
        softWrap: true,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        track.artists.map((e) => e.name).join(", "),
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
      ),
      visualDensity: VisualDensity.compact,
      onTap: () {},
    );
  }
}
