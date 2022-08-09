import 'package:flutter/material.dart';
import 'package:tearmusic/models/music/track.dart';
import 'package:tearmusic/ui/mobile/common/track_tile.dart';

class ArtistTrackTile extends StatelessWidget {
  const ArtistTrackTile(this.track, {Key? key}) : super(key: key);

  final MusicTrack track;

  @override
  Widget build(BuildContext context) {
    return TrackTile(track);
  }
}
