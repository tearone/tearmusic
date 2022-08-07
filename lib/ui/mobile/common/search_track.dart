import 'package:flutter/material.dart';
import 'package:tearmusic/models/music/track.dart';

class SearchTrack extends StatelessWidget {
  const SearchTrack(this.track, {Key? key}) : super(key: key);

  final MusicTrack track;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: SizedBox(
        width: 42,
        height: 42,
        child: Image.network(track.album.images.forSize(const Size(42, 42))),
      ),
      title: Text(track.name),
      subtitle: Text(track.artists.map((e) => e.name).join(", ")),
      visualDensity: VisualDensity.compact,
      onTap: () {},
    );
  }
}
