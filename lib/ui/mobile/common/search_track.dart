import 'package:flutter/material.dart';
import 'package:tearmusic/models/music/track.dart';

class SearchTrack extends StatelessWidget {
  const SearchTrack(this.track, {Key? key}) : super(key: key);

  final MusicTrack track;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(2.0),
        child: SizedBox(
          width: 42,
          height: 42,
          child: Image.network(
            track.album.images.forSize(const Size(42, 42)),
            width: 42,
            height: 42,
            fit: BoxFit.cover,
          ),
        ),
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
