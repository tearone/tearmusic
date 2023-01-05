import 'dart:developer';

import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:tearmusic/models/music/track.dart';
import 'package:tearmusic/models/player_info.dart';
import 'package:tearmusic/providers/current_music_provider.dart';
import 'package:tearmusic/providers/music_info_provider.dart';
import 'package:tearmusic/providers/navigator_provider.dart';
import 'package:tearmusic/providers/theme_provider.dart';
import 'package:tearmusic/providers/user_provider.dart';
import 'package:tearmusic/ui/common/image_color.dart';
import 'package:tearmusic/ui/mobile/common/bottom_sheet.dart';
import 'package:tearmusic/ui/mobile/common/cached_image.dart';
import 'package:tearmusic/ui/common/format.dart';
import 'package:tearmusic/ui/mobile/common/menu_button.dart';
import 'package:tearmusic/ui/mobile/common/tiles/track_tile_preview.dart';
import 'package:tearmusic/ui/mobile/common/views/album_view.dart';
import 'package:tearmusic/ui/mobile/common/views/artist_view/artist_view.dart';
import 'package:tearmusic/ui/mobile/common/views/manual_match_view.dart';

class TrackTile extends StatelessWidget {
  const TrackTile(this.track, {Key? key, this.leadingTrackNumber = false, this.trailingDuration = false, this.onPressed, this.onLongPressed})
      : super(key: key);

  final MusicTrack track;
  final bool leadingTrackNumber;
  final bool trailingDuration;
  final Function()? onPressed;
  final Function()? onLongPressed;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(track.id),
      confirmDismiss: (direction) async {
        log("Item dismissed");
        context.read<UserProvider>().postAdd(track.id, DateTime.now().millisecondsSinceEpoch, whereTo: PlayerInfoPostType.primary);

        return false;
      },
      direction: DismissDirection.startToEnd,
      background: Container(
        color: Colors.green.withOpacity(.3),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Align(alignment: Alignment.centerLeft, child: Icon(Icons.queue_music)),
        ),
      ),
      movementDuration: const Duration(milliseconds: 50),
      dismissThresholds: const {DismissDirection.startToEnd: 0.45, DismissDirection.endToStart: 0.45},
      resizeDuration: const Duration(milliseconds: 50),
      child: Selector<CurrentMusicProvider, MusicTrack?>(
        selector: (_, p) => p.playing,
        builder: (context, value, child) {
          Widget leading;

          if (leadingTrackNumber) {
            leading = SizedBox(
              width: 42,
              height: 42,
              child: Center(
                child: PageTransitionSwitcher(
                  duration: const Duration(seconds: 1),
                  transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
                    return FadeThroughTransition(
                      fillColor: Colors.transparent,
                      animation: primaryAnimation,
                      secondaryAnimation: secondaryAnimation,
                      child: child,
                    );
                  },
                  child: track == value
                      ? Icon(
                          CupertinoIcons.play_fill,
                          key: const Key("playing"),
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : Text(
                          track.trackNumber.toString(),
                          key: const Key("track"),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 16.0,
                          ),
                        ),
                ),
              ),
            );
          } else {
            leading = SizedBox(
              width: 42,
              height: 42,
              child: Stack(
                children: [
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 500),
                    opacity: track == value ? 1 : 0,
                    child: Container(
                      decoration: BoxDecoration(boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.secondary.withOpacity(.2),
                          blurRadius: 6.0,
                        ),
                      ]),
                    ),
                  ),
                  if (track.album != null && track.album!.images != null) CachedImage(track.album!.images!, size: const Size(64, 64)),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 500),
                    opacity: track == value ? 1 : 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(.5),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Center(
                        child: Icon(
                          CupertinoIcons.play_fill,
                          color: Theme.of(context).colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            );
          }

          return Material(
            type: MaterialType.transparency,
            child: ListTile(
              leading: leading,
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
              onTap: onPressed ??
                  () {
                    FocusScope.of(context).requestFocus(FocusNode());
                    final currentMusic = context.read<CurrentMusicProvider>();
                    if (track.album?.images != null) {
                      CachedImage(track.album!.images!).getImage(const Size(64, 64)).then((value) {
                        if (value != null) {
                          final colors = generateColorPalette(value);
                          final theme = context.read<ThemeProvider>();
                          if (theme.key != colors[1]) theme.setThemeKey(colors[1]);
                        }
                        if (currentMusic.playing != null) {
                          context
                              .read<UserProvider>()
                              .postAdd(currentMusic.playing!.id, DateTime.now().millisecondsSinceEpoch, whereTo: PlayerInfoPostType.history);
                        }
                        currentMusic.playTrack(track);
                      });
                    }
                  },
              onLongPress: onLongPressed ??
                  () {
                    showMaterialModalBottomSheet(
                      context: context,
                      animationCurve: Curves.fastLinearToSlowEaseIn,
                      duration: const Duration(milliseconds: 300),
                      useRootNavigator: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => BottomSheetContainer(
                        topRadius: const Radius.circular(16.0),
                        child: SafeArea(
                          top: false,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: TrackTilePreview(track),
                                ),
                                MenuButton(
                                  icon: const Icon(CupertinoIcons.person),
                                  child: const Text("View Artist"),
                                  onPressed: () {
                                    ArtistView.view(track.artists.first, context: context);
                                    Navigator.of(context, rootNavigator: true).pop();
                                  },
                                ),
                                if (track.album != null)
                                  MenuButton(
                                    icon: const Icon(CupertinoIcons.music_albums),
                                    child: const Text("View Album"),
                                    onPressed: () {
                                      AlbumView.view(track.album!, context: context);
                                      Navigator.of(context, rootNavigator: true).pop();
                                    },
                                  ),
                                MenuButton(
                                  icon: const Icon(CupertinoIcons.trash),
                                  child: const Text("Purge Cache"),
                                  onPressed: () {
                                    Navigator.of(context, rootNavigator: true).pop();
                                    context.read<MusicInfoProvider>().purgeCache(track);
                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                      context.read<NavigatorProvider>().showSnackBar(const SnackBar(content: Text("Track cache deleted")));
                                    });
                                  },
                                ),
                                MenuButton(
                                  icon: const Icon(CupertinoIcons.search),
                                  child: const Text("Manual Match"),
                                  onPressed: () {
                                    ManualMatchView.view(track, context: context);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
            ),
          );
        },
      ),
    );
  }
}
