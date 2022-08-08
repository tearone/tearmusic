import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tearmusic/models/music/artist.dart';
import 'package:tearmusic/ui/common/image_color.dart';
import 'package:tearmusic/ui/mobile/common/cached_image.dart';

class ArtistView extends StatelessWidget {
  const ArtistView(this.artist, {Key? key}) : super(key: key);

  final MusicArtist artist;

  static Future<void> view(MusicArtist value, {required BuildContext context}) => Navigator.of(context).push(
        CupertinoPageRoute(
          builder: (context) => ArtistView(value),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final image = CachedImage(artist.images!);
    const double imageSize = 300;

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

        return FutureBuilder(
          // future: context.read<MusicInfoProvider>().albumTracks(widget.album),
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
                          artist.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        centerTitle: true,
                        expandedTitleScale: 2,
                        background: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            image,
                            Text("${artist.followers} followers"),
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
                          ],
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
