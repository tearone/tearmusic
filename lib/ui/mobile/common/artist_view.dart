import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tearmusic/models/music/artist.dart';

class ArtistView extends StatelessWidget {
  const ArtistView(this.artist, {Key? key}) : super(key: key);

  final MusicArtist artist;

  static Future<void> view(MusicArtist value, {required BuildContext context}) => Navigator.of(context).push(
        CupertinoPageRoute(
          builder: (context) => ArtistView(value),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
