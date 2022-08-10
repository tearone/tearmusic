import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tearmusic/models/music/track.dart';
import 'package:tearmusic/providers/current_music_provider.dart';
import 'package:tearmusic/ui/mobile/common/cached_image.dart';
import 'package:tearmusic/ui/common/format.dart';
import 'package:tearmusic/ui/mobile/common/player/lyrics_view.dart';

class TrackTile extends StatelessWidget {
  const TrackTile(this.track, {Key? key, this.leadingTrackNumber = false, this.trailingDuration = false}) : super(key: key);

  final MusicTrack track;
  final bool leadingTrackNumber;
  final bool trailingDuration;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leadingTrackNumber
          ? SizedBox(
              width: 42,
              height: 42,
              child: Center(
                child: Text(
                  track.trackNumber.toString(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 16.0,
                  ),
                ),
              ),
            )
          : SizedBox(
              width: 42,
              height: 42,
              child: track.album != null && track.album!.images != null ? CachedImage(track.album!.images!) : null,
            ),
      title: Text(
        track.name,
        maxLines: 2,
        softWrap: true,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Row(
        children: [
          if (track.explicit)
            Container(
              margin: const EdgeInsets.only(right: 6.0),
              height: 14,
              width: 14,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2.0),
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
              child: Center(
                child: Text(
                  "E",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    fontSize: 12.0,
                    height: -0.05,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          Expanded(
            child: Text(
              track.artistsLabel,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      trailing: trailingDuration ? Text(track.duration.shortFormat()) : null,
      visualDensity: VisualDensity.compact,
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
        context.read<CurrentMusicProvider>().playTrack(track);
      },
    );
  }
}
