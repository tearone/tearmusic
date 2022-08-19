import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tearmusic/models/music/track.dart';
import 'package:tearmusic/providers/theme_provider.dart';
import 'package:tearmusic/ui/mobile/common/cached_image.dart';

class TrackTilePreview extends StatelessWidget {
  const TrackTilePreview(this.track, {Key? key, required this.animation}) : super(key: key);

  final MusicTrack track;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => Opacity(
        opacity: animation.value,
        child: Material(
          type: MaterialType.transparency,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: SizedBox(
                  height: 200.0,
                  width: 200.0,
                  child: (track.album != null && track.album!.images != null) ? CachedImage(track.album!.images!, borderRadius: 12.0) : null,
                ),
              ),
              Text(
                track.name,
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.w600,
                  color: context.read<ThemeProvider>().appTheme.colorScheme.onSecondaryContainer,
                ),
              ),
              Text(
                track.artistsLabel,
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w500,
                  color: context.read<ThemeProvider>().appTheme.colorScheme.secondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
