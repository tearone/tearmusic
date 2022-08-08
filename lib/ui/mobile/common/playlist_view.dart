import 'dart:typed_data';

import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:tearmusic/models/music/playlist.dart';
import 'package:tearmusic/providers/music_info_provider.dart';
import 'package:tearmusic/ui/common/image_color.dart';
import 'package:tearmusic/ui/mobile/common/cached_image.dart';
import 'package:tearmusic/ui/mobile/common/playlist_track_tile.dart';
import 'package:tearmusic/ui/common/format.dart';

class PlaylistView extends StatefulWidget {
  const PlaylistView(this.playlist, {Key? key}) : super(key: key);

  final MusicPlaylist playlist;

  static Future<void> view(MusicPlaylist value, {required BuildContext context}) => Navigator.of(context).push(
        CupertinoPageRoute(
          builder: (context) => PlaylistView(value),
        ),
      );

  @override
  State<PlaylistView> createState() => _PlaylistViewState();
}

class _PlaylistViewState extends State<PlaylistView> {
  late ScrollController _scrollController;

  bool showTitle = false;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.offset > 300.0) {
        if (!showTitle) setState(() => showTitle = true);
      } else {
        if (showTitle) setState(() => showTitle = false);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final image = CachedImage(widget.playlist.images);
    const double imageSize = 250;

    return FutureBuilder<Uint8List>(
      future: image.getImage(const Size.square(imageSize)),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }

        final colors = generateColorPalette(snapshot.data!);
        final theme = ThemeData(
          useMaterial3: true,
          colorSchemeSeed: colors[1],
          brightness: Brightness.dark,
          fontFamily: "Montserrat",
        );

        return FutureBuilder<PlaylistDetails>(
          future: context.read<MusicInfoProvider>().playlistTracks(widget.playlist),
          builder: (context, snapshot) {
            return Theme(
              data: theme,
              child: Scaffold(
                body: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    SliverAppBar(
                      pinned: true,
                      snap: false,
                      floating: false,
                      centerTitle: false,
                      title: AnimatedOpacity(
                        opacity: showTitle ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          widget.playlist.name,
                          style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
                        ),
                      ),
                      backgroundColor: theme.scaffoldBackgroundColor,
                      leading: const BackButton(),
                      actions: [
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.more_vert),
                        )
                      ],
                      expandedHeight: 300,
                      flexibleSpace: FlexibleSpaceBar(
                        background: SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 42.0),
                            child: Center(
                              child: SizedBox(
                                width: imageSize,
                                height: imageSize,
                                child: ClipSmoothRect(
                                  radius: SmoothBorderRadius(cornerRadius: 32.0, cornerSmoothing: 1.0),
                                  child: image,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 18.0, left: 24.0, right: 12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.playlist.name,
                                    maxLines: 2,
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 26.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 4.0),
                                    child: Text(
                                      widget.playlist.owner,
                                      maxLines: 1,
                                      softWrap: false,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: theme.colorScheme.secondary.withOpacity(.7),
                                        fontSize: 16.0,
                                      ),
                                    ),
                                  ),
                                  if (snapshot.hasData)
                                    Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(right: 8.0),
                                          child: Chip(
                                            elevation: 1,
                                            backgroundColor: theme.colorScheme.primary.withOpacity(.2),
                                            labelPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                                            avatar: Icon(Icons.favorite, color: theme.colorScheme.primary, size: 18.0),
                                            label: Text(
                                              "${snapshot.data!.followers} likes",
                                              style: TextStyle(
                                                fontSize: 14.0,
                                                color: theme.colorScheme.primary,
                                                height: -0.05,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Chip(
                                          elevation: 1,
                                          backgroundColor: theme.colorScheme.primary.withOpacity(.2),
                                          labelPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                                          avatar: Icon(Icons.schedule, color: theme.colorScheme.primary, size: 18.0),
                                          label: Text(
                                            snapshot.data!.tracks.fold(Duration.zero, (Duration a, b) => b.duration + a).format(),
                                            style: TextStyle(
                                              fontSize: 14.0,
                                              color: theme.colorScheme.primary,
                                              height: -0.05,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                Theme(
                                  data: theme.copyWith(
                                    floatingActionButtonTheme: FloatingActionButtonThemeData(
                                      sizeConstraints: BoxConstraints.tight(const Size.square(72.0)),
                                      iconSize: 46.0,
                                    ),
                                  ),
                                  child: FloatingActionButton(
                                    child: const Icon(Icons.play_arrow),
                                    onPressed: () {},
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      onPressed: () {},
                                      icon: Icon(
                                        Icons.cloud_download_outlined,
                                        color: theme.colorScheme.onSecondaryContainer,
                                        size: 26.0,
                                      ),
                                    ),
                                    LikeButton(
                                      bubblesColor: BubblesColor(
                                        dotPrimaryColor: theme.colorScheme.primary,
                                        dotSecondaryColor: theme.colorScheme.primaryContainer,
                                      ),
                                      circleColor: CircleColor(
                                        start: theme.colorScheme.tertiary,
                                        end: theme.colorScheme.tertiary,
                                      ),
                                      likeBuilder: (value) => value
                                          ? Icon(
                                              Icons.favorite,
                                              color: theme.colorScheme.primary,
                                              size: 26.0,
                                            )
                                          : Icon(
                                              Icons.favorite_border_outlined,
                                              color: theme.colorScheme.onSecondaryContainer,
                                              size: 26.0,
                                            ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          if (!snapshot.hasData) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 32.0),
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: LoadingAnimationWidget.staggeredDotsWave(
                                  color: theme.colorScheme.secondary.withOpacity(.2),
                                  size: 64.0,
                                ),
                              ),
                            );
                          }

                          if (index == snapshot.data!.tracks.length) {
                            return const SizedBox(height: 200);
                          }

                          return PlaylistTrackTile(snapshot.data!.tracks[index]);
                        },
                        childCount: snapshot.hasData ? snapshot.data!.tracks.length + 1 : 1,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
