import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tearmusic/models/music/lyrics.dart';
import 'package:tearmusic/models/music/track.dart';
import 'package:tearmusic/providers/music_info_provider.dart';

class LyricsView extends StatelessWidget {
  const LyricsView(this.track, {Key? key}) : super(key: key);

  final MusicTrack track;

  static Future<void> view(MusicTrack value, {required BuildContext context}) => Navigator.of(context).push(
        CupertinoPageRoute(
          builder: (context) => LyricsView(value),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<MusicLyrics>(
        future: context.read<MusicInfoProvider>().lyrics(track),
        builder: (context, snapshot) {
          return Text(snapshot.data?.fullText ?? "");
        },
      ),
    );
  }
}
