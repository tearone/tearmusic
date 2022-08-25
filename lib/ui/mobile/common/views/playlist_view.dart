import 'dart:async';

import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:like_button/like_button.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:tearmusic/models/library.dart';
import 'package:tearmusic/models/music/playlist.dart';
import 'package:tearmusic/providers/music_info_provider.dart';
import 'package:tearmusic/providers/navigator_provider.dart';
import 'package:tearmusic/providers/theme_provider.dart';
import 'package:tearmusic/providers/user_provider.dart';
import 'package:tearmusic/ui/common/image_color.dart';
import 'package:tearmusic/ui/mobile/common/cached_image.dart';
import 'package:tearmusic/ui/mobile/common/tm_back_button.dart';
import 'package:tearmusic/ui/mobile/common/views/playlist_track_tile.dart';
import 'package:tearmusic/ui/common/format.dart';

class PlaylistView extends StatefulWidget {
  const PlaylistView(this.playlist, {Key? key}) : super(key: key);

  final MusicPlaylist playlist;

  static Future<void> view(MusicPlaylist value, {required BuildContext context}) => context.read<NavigatorProvider>().push(
        CupertinoPageRoute(
          builder: (context) => PlaylistView(value),
        ),
        uri: value.uri,
      );

  @override
  State<PlaylistView> createState() => _PlaylistViewState();
}

class _PlaylistViewState extends State<PlaylistView> {
  late ScrollController _scrollController;

  bool showTitle = false;

  Future<ThemeData> getTheme(CachedImage image) async {
    final bytes = await image.getImage(const Size.square(imageSize));

    final colors = generateColorPalette(bytes);
    return ThemeProvider.coloredTheme(colors[1]);
  }

  late CachedImage image;
  static const double imageSize = 250;

  final theme = Completer<ThemeData>();

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

    image = CachedImage(widget.playlist.images!);

    getTheme(image).then((value) {
      if (mounted) context.read<ThemeProvider>().tempNavTheme(value);
      theme.complete(value);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ThemeData>(
      future: theme.future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }

        final theme = snapshot.data!;

        return FutureBuilder<PlaylistDetails>(
          future: context.read<MusicInfoProvider>().playlistTracks(widget.playlist),
          builder: (context, snapshot) {
            return Theme(
              data: theme,
              child: Scaffold(
                body: CupertinoScrollbar(
                  thickness: 8.0,
                  radius: const Radius.circular(8.0),
                  controller: _scrollController,
                  child: CustomScrollView(
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
                        leading: const TMBackButton(),
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
                                              labelPadding: const EdgeInsets.only(left: 2.0, right: 4.0),
                                              avatar: Icon(Icons.favorite, color: theme.colorScheme.primary, size: 18.0),
                                              label: Text(
                                                "${NumberFormat.compact().format(snapshot.data!.followers)} likes",
                                                style: TextStyle(
                                                  fontSize: 14.0,
                                                  color: theme.colorScheme.primary,
                                                  fontWeight: FontWeight.w600,
                                                  wordSpacing: -1,
                                                  height: -0.05,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Chip(
                                            elevation: 1,
                                            backgroundColor: theme.colorScheme.primary.withOpacity(.2),
                                            labelPadding: const EdgeInsets.only(left: 2.0, right: 4.0),
                                            avatar: Icon(Icons.schedule, color: theme.colorScheme.primary, size: 18.0),
                                            label: Text(
                                              snapshot.data!.tracks.fold(Duration.zero, (Duration a, b) => b.duration + a).format(),
                                              style: TextStyle(
                                                fontSize: 14.0,
                                                color: theme.colorScheme.primary,
                                                fontWeight: FontWeight.w600,
                                                wordSpacing: -1,
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
                                          CupertinoIcons.cloud_download,
                                          color: theme.colorScheme.onSecondaryContainer,
                                          size: 26.0,
                                        ),
                                      ),
                                      FutureBuilder(
                                          future: context.read<UserProvider>().getLibrary(),
                                          builder: (context, snapshot) {
                                            return LikeButton(
                                              bubblesColor: BubblesColor(
                                                dotPrimaryColor: theme.colorScheme.primary,
                                                dotSecondaryColor: theme.colorScheme.primaryContainer,
                                              ),
                                              circleColor: CircleColor(
                                                start: theme.colorScheme.tertiary,
                                                end: theme.colorScheme.tertiary,
                                              ),
                                              isLiked: snapshot.hasData ? snapshot.data!.liked_playlists.contains(widget.playlist.id) : false,
                                              onTap: (isLiked) async {
                                                if (!isLiked) {
                                                  context.read<UserProvider>().putLibrary(widget.playlist, LibraryType.liked_playlists);
                                                } else {
                                                  context.read<UserProvider>().deleteLibrary(widget.playlist, LibraryType.liked_playlists);
                                                }

                                                return !isLiked;
                                              },
                                              likeBuilder: (value) => value
                                                  ? Icon(
                                                      CupertinoIcons.heart_fill,
                                                      color: Theme.of(context).colorScheme.primary,
                                                      size: 26.0,
                                                    )
                                                  : Icon(
                                                      CupertinoIcons.heart,
                                                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                                                      size: 26.0,
                                                    ),
                                            );
                                          }),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (!snapshot.hasData)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 32.0),
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: LoadingAnimationWidget.staggeredDotsWave(
                                color: theme.colorScheme.secondary.withOpacity(.2),
                                size: 64.0,
                              ),
                            ),
                          ),
                        ),
                      if (snapshot.hasData)
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (BuildContext context, int index) => PlaylistTrackTile(snapshot.data!.tracks[index]),
                            childCount: snapshot.data!.tracks.length,
                          ),
                        ),
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 100),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
