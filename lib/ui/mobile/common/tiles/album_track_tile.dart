import 'package:flutter/material.dart';
import 'package:tearmusic/models/music/track.dart';
import 'package:tearmusic/ui/mobile/common/tiles/track_tile.dart';

class AlbumTrackTile extends StatelessWidget {
  const AlbumTrackTile(this.track, {Key? key}) : super(key: key);

  final MusicTrack track;

  @override
  Widget build(BuildContext context) {
    return TrackTile(track, leadingTrackNumber: true, trailingDuration: true);
  }
}
