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

class RecentlyPlayedScreen extends StatefulWidget {
  const RecentlyPlayedScreen({Key? key}) : super(key: key);

  @override
  State<RecentlyPlayedScreen> createState() => _RecentlyPlayedScreenState();
}

class _RecentlyPlayedScreenState extends State<RecentlyPlayedScreen> {
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
                      children: [
                        const Expanded(
                          child: Text(
                            "Recently played",
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Selector<UserProvider, List<UserTrackHistory>>(
                    selector: (_, user) => user.library?.track_history ?? [],
                    builder: ((context, value, child) {
                      print("[build] rebuild selector");

                      if (value.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 6.0, bottom: 24.0),
                          child: Center(
                            child: Text("Start listening to view recently played"),
                          ),
                        );
                      }

                      return FutureBuilder(
                        future: context.read<MusicInfoProvider>().libraryBatch(LibraryType.track_history, limit: 50),
                        builder: ((context, snapshot) {
                          if (!snapshot.hasData) {
                            return TrackLoadingTile(itemCount: 8,);
                          }

                          return AutomaticAnimatedList(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            items: snapshot.data!.track_history,
                            keyingFunction: (item) => Key(item.track.id),
                            itemBuilder: (BuildContext context, BatchTrackHistory item, Animation<double> animation) {
                              return FadeTransition(
                                key: Key(item.track.id),
                                opacity: animation,
                                child: SizeTransition(
                                  sizeFactor: CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeOut,
                                    reverseCurve: Curves.easeIn,
                                  ),
                                  child: TrackTile(item.track),
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
