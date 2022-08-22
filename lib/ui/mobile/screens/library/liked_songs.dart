
import 'package:automatic_animated_list/automatic_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:tearmusic/models/batch.dart';
import 'package:tearmusic/models/library.dart';
import 'package:tearmusic/models/music/track.dart';
import 'package:tearmusic/providers/music_info_provider.dart';
import 'package:tearmusic/providers/user_provider.dart';
import 'package:tearmusic/ui/mobile/common/tiles/track_tile.dart';
import 'package:tearmusic/ui/mobile/common/wallpaper.dart';
import 'package:tearmusic/ui/mobile/pages/library/track_loading_tile.dart';

class LikedSongsScreen extends StatefulWidget {
  const LikedSongsScreen({Key? key}) : super(key: key);

  @override
  State<LikedSongsScreen> createState() => _LikedSongsScreenState();
}

class _LikedSongsScreenState extends State<LikedSongsScreen> {
  @override
  Widget build(BuildContext context) {
    return Wallpaper(
      child: SafeArea(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
                    child: Row(
                      children: const [
                        Expanded(
                          child: Text(
                            "Liked Songs",
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Selector<UserProvider, List<String>>(
                    selector: (_, user) => user.library?.liked_tracks ?? [],
                    builder: ((context, value, child) {
                      if (value.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 6.0, bottom: 24.0),
                          child: Center(
                            child: Text("You have no liked songs"),
                          ),
                        );
                      }

                      return FutureBuilder(
                        future: context.read<MusicInfoProvider>().libraryBatch(LibraryType.liked_tracks, limit: 50),
                        builder: ((context, snapshot) {
                          if (!snapshot.hasData) {
                            return TrackLoadingTile(itemCount: 8,);
                          }

                          return AutomaticAnimatedList(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            items: snapshot.data!.tracks,
                            keyingFunction: (item) => Key(item.id),
                            itemBuilder: (BuildContext context, MusicTrack item, Animation<double> animation) {
                              return FadeTransition(
                                key: Key(item.id),
                                opacity: animation,
                                child: SizeTransition(
                                  sizeFactor: CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeOut,
                                    reverseCurve: Curves.easeIn,
                                  ),
                                  child: TrackTile(item),
                                ),
                              );
                            },
                          );
                        }),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
