import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:tearmusic/models/music/album.dart';
import 'package:tearmusic/models/music/artist.dart';
import 'package:tearmusic/models/music/track.dart';
import 'package:tearmusic/providers/music_info_provider.dart';
import 'package:tearmusic/providers/navigator_provider.dart';
import 'package:tearmusic/providers/theme_provider.dart';
import 'package:tearmusic/ui/common/image_color.dart';
import 'package:tearmusic/ui/mobile/common/knob.dart';
import 'package:tearmusic/ui/mobile/common/tiles/artist_album_tile.dart';
import 'package:tearmusic/ui/mobile/common/tiles/artist_artist_tile.dart';
import 'package:tearmusic/ui/mobile/common/tiles/artist_track_tile.dart';
import 'package:tearmusic/ui/mobile/common/cached_image.dart';
import 'package:tearmusic/ui/mobile/common/view_menu_button.dart';
import 'package:tearmusic/ui/mobile/common/views/album_view/latest_release.dart';
import 'package:tearmusic/ui/mobile/common/views/artist_view/artist_header_button.dart';
import 'package:tearmusic/ui/mobile/common/views/content_list_view.dart';
import 'package:tearmusic/ui/mobile/pages/library/track_loading_tile.dart';

class ArtistView extends StatefulWidget {
  const ArtistView(this.artist, {Key? key}) : super(key: key);

  final MusicArtist artist;

  static Future<void> view(MusicArtist value, {required BuildContext context}) {
    final nav = context.read<NavigatorProvider>();
    final theme = context.read<ThemeProvider>();
    return nav.pushModal(builder: (context) => ArtistView(value), uri: value.uri).then((value) {
      theme.resetTheme();
      return value;
    });
  }

  @override
  State<ArtistView> createState() => _ArtistViewState();
}

class _ArtistViewState extends State<ArtistView> {
  Future<ArtistDetails> artistDetails(MusicInfoProvider musicInfo) async {
    final details = await musicInfo.artistDetails(widget.artist);
    if (image == null) {
      image = CachedImage(details.artist.images!);
      getTheme(image!).then((value) {
        if (mounted) context.read<ThemeProvider>().tempNavTheme(value);
        theme.complete(value);
      });
    }
    return details;
  }

  Future<ThemeData> getTheme(CachedImage image) async {
    final bytes = await image.getImage(const Size.square(350));

    final colors = generateColorPalette(bytes);
    return ThemeProvider.coloredTheme(colors[1]);
  }

  CachedImage? image;
  final theme = Completer<ThemeData>();

  @override
  void initState() {
    super.initState();

    if (widget.artist.images != null) {
      image = CachedImage(widget.artist.images!);
      getTheme(image!).then((value) {
        if (mounted) context.read<ThemeProvider>().tempNavTheme(value);
        theme.complete(value);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final musicInfo = context.read<MusicInfoProvider>();

    return FutureBuilder<List<Object>>(
      future: Future.wait([theme.future, artistDetails(musicInfo)]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            body: Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                color: Theme.of(context).colorScheme.secondary.withOpacity(.2),
                size: 64.0,
              ),
            ),
          );
        }

        final theme = snapshot.data![0] as ThemeData;
        final details = snapshot.data![1] as ArtistDetails;

        return Theme(
          data: theme,
          child: Stack(
            children: [
              Scaffold(
                body: CupertinoScrollbar(
                  controller: ModalScrollController.of(context),
                  child: CustomScrollView(
                    controller: ModalScrollController.of(context),
                    slivers: [
                      SliverAppBar(
                        pinned: true,
                        snap: false,
                        floating: false,
                        backgroundColor: theme.scaffoldBackgroundColor,
                        // leading: const TMBackButton(),
                        automaticallyImplyLeading: false,
                        expandedHeight: 300,
                        collapsedHeight: 82,
                        flexibleSpace: FlexibleSpaceBar(
                          title: Text(
                            widget.artist.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          centerTitle: true,
                          expandedTitleScale: 1.7,
                          background: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              if (image != null) image!,
                              Positioned.fill(
                                child: Transform.scale(
                                  scaleY: 1.001,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        stops: const [.5, 1],
                                        colors: [
                                          theme.scaffoldBackgroundColor.withOpacity(0),
                                          theme.scaffoldBackgroundColor,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                  "${NumberFormat.compact().format(widget.artist.followers > 0 ? widget.artist.followers : details.artist.followers)} followers"),
                            ],
                          ),
                        ),
                      ),
                      if (!snapshot.hasData)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 64.0),
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: LoadingAnimationWidget.staggeredDotsWave(
                                color: theme.colorScheme.secondary.withOpacity(.2),
                                size: 64.0,
                              ),
                            ),
                          ),
                        ),
                      // if (snapshot.hasData)
                      //   SliverToBoxAdapter(
                      //     child: Row(
                      //       children: [
                      //         ElevatedButton(
                      //           onPressed: () {},
                      //           child: Text("Follow"),
                      //         ),
                      //         ElevatedButton(
                      //           onPressed: () {},
                      //           child: Text("Shuffle"),
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      if (snapshot.hasData && details.albums.isNotEmpty)
                        SliverPadding(
                          padding: const EdgeInsets.only(top: 12.0, left: 16.0, right: 16.0),
                          sliver: SliverToBoxAdapter(
                            child: Row(
                              children: [
                                Expanded(
                                  child: ArtistHeaderButton(
                                    onPressed: () {},
                                    icon: const Icon(CupertinoIcons.heart),
                                    child: Text("Follow".toUpperCase()),
                                  ),
                                ),
                                const SizedBox(width: 12.0),
                                Expanded(
                                  child: ArtistHeaderButton(
                                    onPressed: () {},
                                    icon: const Icon(CupertinoIcons.shuffle),
                                    child: Text("Shuffle".toUpperCase()),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (snapshot.hasData && details.albums.isNotEmpty)
                        SliverPadding(
                          padding: const EdgeInsets.all(12.0),
                          sliver: SliverToBoxAdapter(
                            child: LatestRelease(
                              details.albums.first,
                              then: () {
                                context.read<ThemeProvider>().tempNavTheme(theme);
                              },
                            ),
                          ),
                        ),
                      if (snapshot.hasData && details.tracks.isNotEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Card(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0, left: 16.0, right: 8.0),
                                    child: Row(
                                      children: [
                                        const Expanded(
                                          child: Text(
                                            "Top Songs",
                                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).push(CupertinoPageRoute(
                                              builder: (context) => Theme(
                                                data: theme,
                                                child: ContentListView<MusicTrack>(
                                                  itemBuilder: (context, item) => ArtistTrackTile(item),
                                                  retriever: () async => details.tracks,
                                                  loadingWidget: const TrackLoadingTile(itemCount: 8),
                                                  title: Text(
                                                    "Top Songs by ${widget.artist.name}",
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ));
                                          },
                                          child: const Text("Show All"),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ...details.tracks.sublist(0, math.min(details.tracks.length, 5)).map((e) => ArtistTrackTile(e)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      if (snapshot.hasData && details.albums.any((e) => e.albumType != AlbumType.single))
                        SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 12.0, bottom: 8.0, left: 16.0, right: 8.0),
                                child: Text(
                                  "Albums",
                                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0),
                                ),
                              ),
                              SizedBox(
                                height: 200,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: [
                                    const SizedBox(width: 16.0),
                                    ...details.albums.where((e) => e.albumType != AlbumType.single).map((e) => Padding(
                                          padding: const EdgeInsets.only(right: 12.0),
                                          child: ArtistAlbumTile(e, then: () => context.read<ThemeProvider>().tempNavTheme(theme)),
                                        )),
                                    const SizedBox(width: 16.0),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (snapshot.hasData && details.albums.any((e) => e.albumType == AlbumType.single))
                        SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 12.0, bottom: 8.0, left: 16.0, right: 8.0),
                                child: Text(
                                  "Singles",
                                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0),
                                ),
                              ),
                              SizedBox(
                                height: 180,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: [
                                    const SizedBox(width: 16.0),
                                    ...details.albums.where((e) => e.albumType == AlbumType.single).map((e) => Padding(
                                          padding: const EdgeInsets.only(right: 12.0),
                                          child: ArtistAlbumTile.small(e, then: () => context.read<ThemeProvider>().tempNavTheme(theme)),
                                        )),
                                    const SizedBox(width: 16.0),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (snapshot.hasData && details.related.isNotEmpty)
                        SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 12.0, bottom: 8.0, left: 16.0, right: 8.0),
                                child: Text(
                                  "Similar Artists",
                                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0),
                                ),
                              ),
                              SizedBox(
                                height: 150,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: [
                                    const SizedBox(width: 16.0),
                                    ...details.related.map((e) => Padding(
                                          padding: const EdgeInsets.only(right: 12.0),
                                          child: ArtistArtistTile(e, then: () => context.read<ThemeProvider>().tempNavTheme(theme)),
                                        )),
                                    const SizedBox(width: 16.0),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (snapshot.hasData && details.appearsOn.isNotEmpty)
                        SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 12.0, bottom: 8.0, left: 16.0, right: 8.0),
                                child: Text(
                                  "Appears On",
                                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0),
                                ),
                              ),
                              SizedBox(
                                height: 180,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: [
                                    const SizedBox(width: 16.0),
                                    ...details.appearsOn.map((e) => Padding(
                                          padding: const EdgeInsets.only(right: 12.0),
                                          child: ArtistAlbumTile.small(e, then: () => context.read<ThemeProvider>().tempNavTheme(theme)),
                                        )),
                                    const SizedBox(width: 16.0),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 100),
                      ),
                    ],
                  ),
                ),
              ),
              const Knob(),
              Padding(
                padding: const EdgeInsets.only(top: 12.0, right: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: const [
                    ViewMenuButton(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
