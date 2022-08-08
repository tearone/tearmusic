import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:tearmusic/models/music/album.dart';
import 'package:tearmusic/models/music/artist.dart';
import 'package:tearmusic/providers/music_info_provider.dart';
import 'package:tearmusic/providers/theme_provider.dart';
import 'package:tearmusic/ui/common/image_color.dart';
import 'package:tearmusic/ui/mobile/common/cached_image.dart';
import 'package:tearmusic/ui/mobile/common/latest_release.dart';

class ArtistView extends StatefulWidget {
  const ArtistView(this.artist, {Key? key}) : super(key: key);

  final MusicArtist artist;

  static Future<void> view(MusicArtist value, {required BuildContext context}) => Navigator.of(context).push(
        CupertinoPageRoute(
          builder: (context) => ArtistView(value),
        ),
      );

  @override
  State<ArtistView> createState() => _ArtistViewState();
}

class _ArtistViewState extends State<ArtistView> {
  Future<ArtistDetails> artistDetails(MusicInfoProvider musicInfo) async {
    final res = await Future.wait([
      musicInfo.artistAlbums(widget.artist),
      musicInfo.artistTracks(widget.artist),
      musicInfo.artistRelated(widget.artist),
    ]);

    List<MusicAlbum> albums = List.castFrom(res[0]);
    albums.sort((a, b) => b.releaseDate.compareTo(a.releaseDate));

    return ArtistDetails(
      tracks: res[1].cast(),
      albums: albums.where((e) => e.artists.first == widget.artist).toList(),
      appearsOn: albums.where((e) => e.artists.first != widget.artist).toList(),
      related: res[2].cast(),
    );
  }

  Future<ThemeData> getTheme(CachedImage image) async {
    final bytes = await image.getImage(const Size.square(350));

    final colors = generateColorPalette(bytes);
    return ThemeProvider.coloredTheme(colors[1]);
  }

  late CachedImage image;
  final theme = Completer<ThemeData>();

  @override
  void initState() {
    super.initState();

    image = CachedImage(widget.artist.images!);

    getTheme(image).then((value) {
      if (mounted) context.read<ThemeProvider>().tempNavTheme(value);
      theme.complete(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ThemeData>(
      future: theme.future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox();
        }

        final theme = snapshot.data!;
        final musicInfo = context.read<MusicInfoProvider>();

        return FutureBuilder<ArtistDetails>(
          future: artistDetails(musicInfo),
          builder: (context, snapshot) {
            return Theme(
              data: theme,
              child: Scaffold(
                body: CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      pinned: true,
                      snap: false,
                      floating: false,
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
                        title: Text(
                          widget.artist.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        centerTitle: true,
                        expandedTitleScale: 2,
                        background: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            image,
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    stops: const [0.5, 1],
                                    colors: [
                                      theme.scaffoldBackgroundColor.withOpacity(0),
                                      theme.scaffoldBackgroundColor,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Text("${NumberFormat.compact().format(widget.artist.followers)} followers"),
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
                    if (snapshot.hasData)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0).add(const EdgeInsets.only(top: 8.0)),
                          child: LatestRelease(
                            snapshot.data!.albums.first,
                            then: () {
                              context.read<ThemeProvider>().tempNavTheme(theme);
                            },
                          ),
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
