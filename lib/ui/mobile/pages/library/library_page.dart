import 'package:animations/animations.dart';
import 'package:automatic_animated_list/automatic_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tearmusic/models/batch.dart';
import 'package:tearmusic/models/library.dart';
import 'package:tearmusic/models/music/album.dart';
import 'package:tearmusic/models/music/artist.dart';
import 'package:tearmusic/models/music/playlist.dart';
import 'package:tearmusic/models/music/track.dart';
import 'package:tearmusic/providers/music_info_provider.dart';
import 'package:tearmusic/providers/theme_provider.dart';
import 'package:tearmusic/providers/user_provider.dart';
import 'package:tearmusic/ui/mobile/common/profile_button.dart';
import 'package:tearmusic/ui/mobile/common/tiles/artist_album_tile.dart';
import 'package:tearmusic/ui/mobile/common/tiles/artist_artist_tile.dart';
import 'package:tearmusic/ui/mobile/common/tiles/search_playlist_tile.dart';
import 'package:tearmusic/ui/mobile/common/tiles/track_tile.dart';
import 'package:tearmusic/ui/mobile/common/wallpaper.dart';

import 'package:tearmusic/ui/mobile/pages/library/album_loading_tile.dart';
import 'package:tearmusic/ui/mobile/pages/library/artist_loading_tile.dart';
import 'package:tearmusic/ui/mobile/pages/library/playlist_loading_tile.dart';
import 'package:tearmusic/ui/mobile/pages/library/track_loading_tile.dart';
import 'package:tearmusic/ui/mobile/screens/library/liked_playlists.dart';
import 'package:tearmusic/ui/mobile/screens/library/liked_songs.dart';
import 'package:tearmusic/ui/mobile/screens/library/recently_played.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({Key? key}) : super(key: key);

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  @override
  Widget build(BuildContext context) {
    return Wallpaper(
      child: SafeArea(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 24.0, bottom: 8.0).add(const EdgeInsets.symmetric(horizontal: 24.0)),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Text(
                        "Your Library",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 20.0,
                          color: Theme.of(context).colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                  ),
                  const ProfileButton(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Card(
                elevation: 5.0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 8.0),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              "Recently played",
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                PageRouteBuilder(
                                  pageBuilder: (context, primaryAnimation, secondaryAnimation) {
                                    return FadeThroughTransition(
                                      fillColor: Theme.of(context).colorScheme.background,
                                      animation: primaryAnimation,
                                      secondaryAnimation: secondaryAnimation,
                                      child: const RecentlyPlayedScreen(),
                                    );
                                  },
                                  transitionDuration: const Duration(milliseconds: 500),
                                  reverseTransitionDuration: const Duration(milliseconds: 500),
                                ),
                              );
                            },
                            child: const Text("Show All"),
                          )
                        ],
                      ),
                    ),
                    Selector<UserProvider, List<UserTrackHistory>>(
                      selector: (_, user) => user.library?.track_history ?? [],
                      builder: ((context, value, child) {
                        if (value.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.only(top: 6.0, bottom: 24.0),
                            child: Center(
                              child: Text("Start listening to view recently played"),
                            ),
                          );
                        }

                        return FutureBuilder(
                          future: context.read<MusicInfoProvider>().libraryBatch(LibraryType.track_history, limit: 3),
                          builder: ((context, snapshot) {
                            if (!snapshot.hasData) {
                              return const TrackLoadingTile();
                            }

                            return AutomaticAnimatedList(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
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
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Card(
                elevation: 4.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 8.0),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              "Liked Playlists",
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                PageRouteBuilder(
                                  pageBuilder: (context, primaryAnimation, secondaryAnimation) {
                                    return FadeThroughTransition(
                                      fillColor: Theme.of(context).colorScheme.background,
                                      animation: primaryAnimation,
                                      secondaryAnimation: secondaryAnimation,
                                      child: const LikedPlaylistsScreen(),
                                    );
                                  },
                                  transitionDuration: const Duration(milliseconds: 500),
                                  reverseTransitionDuration: const Duration(milliseconds: 500),
                                ),
                              );
                            },
                            child: const Text("Show All"),
                          )
                        ],
                      ),
                    ),
                    Selector<UserProvider, List<String>>(
                      selector: (_, user) => user.library?.liked_playlists ?? [],
                      builder: ((context, value, child) {
                        if (value.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.only(top: 6.0, bottom: 24.0),
                            child: Center(
                              child: Text("You have no liked playlists"),
                            ),
                          );
                        }

                        return FutureBuilder(
                          future: context.read<MusicInfoProvider>().libraryBatch(LibraryType.liked_playlists, limit: 3),
                          builder: ((context, snapshot) {
                            if (!snapshot.hasData) {
                              return const PlaylistLoadingTile();
                            }

                            return AutomaticAnimatedList(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              items: snapshot.data!.playlists,
                              keyingFunction: (item) => Key(item.id),
                              itemBuilder: (BuildContext context, MusicPlaylist item, Animation<double> animation) {
                                return FadeTransition(
                                  key: Key(item.id),
                                  opacity: animation,
                                  child: SizeTransition(
                                    sizeFactor: CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeOut,
                                      reverseCurve: Curves.easeIn,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 12.0),
                                      child: SearchPlaylistTile(
                                        item,
                                      ),
                                    ),
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
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Card(
                elevation: 4.0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 8.0),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              "Liked Songs",
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                PageRouteBuilder(
                                  pageBuilder: (context, primaryAnimation, secondaryAnimation) {
                                    return FadeThroughTransition(
                                      fillColor: Theme.of(context).colorScheme.background,
                                      animation: primaryAnimation,
                                      secondaryAnimation: secondaryAnimation,
                                      child: const LikedSongsScreen(),
                                    );
                                  },
                                  transitionDuration: const Duration(milliseconds: 500),
                                  reverseTransitionDuration: const Duration(milliseconds: 500),
                                ),
                              );
                            },
                            child: const Text("Show All"),
                          )
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
                          future: context.read<MusicInfoProvider>().libraryBatch(LibraryType.liked_tracks, limit: 3),
                          builder: ((context, snapshot) {
                            if (!snapshot.hasData) {
                              return const TrackLoadingTile();
                            }

                            return AutomaticAnimatedList(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
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
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 12.0, bottom: 12.0, left: 28.0, right: 8.0),
                    child: Text(
                      "Liked Artists",
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0),
                    ),
                  ),
                  Selector<UserProvider, List<String>>(
                    selector: (_, user) => user.library?.liked_artists ?? [],
                    builder: ((context, value, child) {
                      if (value.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 6.0, bottom: 24.0),
                          child: Center(
                            child: Text("You have no liked artist"),
                          ),
                        );
                      }

                      return FutureBuilder(
                        future: context.read<MusicInfoProvider>().libraryBatch(LibraryType.liked_artists, limit: 3),
                        builder: ((context, snapshot) {
                          if (!snapshot.hasData) {
                            return const SizedBox(height: 150, child: ArtistLoadingTile());
                          }

                          return SizedBox(
                            height: 150,
                            child: AutomaticAnimatedList(
                              scrollDirection: Axis.horizontal,
                              items: snapshot.data!.artists,
                              keyingFunction: (item) => Key(item.id),
                              itemBuilder: (BuildContext context, MusicArtist item, Animation<double> animation) {
                                List<Widget> resRow = [];

                                resRow.add(Padding(
                                  padding: const EdgeInsets.only(right: 12.0),
                                  child: ArtistArtistTile(
                                    item,
                                    then: () => context.read<ThemeProvider>().resetTheme(),
                                  ),
                                ));

                                if (snapshot.data!.artists.first == item) {
                                  resRow = [const SizedBox(width: 24), ...resRow];
                                } else if (snapshot.data!.artists.last == item) {
                                  resRow = [...resRow, const SizedBox(width: 24)];
                                }

                                return FadeTransition(
                                  key: Key(item.id),
                                  opacity: animation,
                                  child: SizeTransition(
                                    sizeFactor: CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeOut,
                                      reverseCurve: Curves.easeIn,
                                    ),
                                    child: Row(
                                      children: resRow,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        }),
                      );
                    }),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 6.0, bottom: 16.0, left: 28.0, right: 8.0),
                    child: Text(
                      "Liked Albums",
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0),
                    ),
                  ),
                  Selector<UserProvider, List<String>>(
                    selector: (_, user) => user.library?.liked_albums ?? [],
                    builder: ((context, value, child) {
                      if (value.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 6.0, bottom: 24.0),
                          child: Center(
                            child: Text("You have no liked albums"),
                          ),
                        );
                      }

                      return FutureBuilder(
                        future: context.read<MusicInfoProvider>().libraryBatch(LibraryType.liked_albums, limit: 5),
                        builder: ((context, snapshot) {
                          if (!snapshot.hasData) {
                            return const SizedBox(height: 200, child: AlbumLoadingTile());
                          }

                          return SizedBox(
                            height: 200,
                            child: AutomaticAnimatedList(
                              scrollDirection: Axis.horizontal,
                              items: snapshot.data!.albums,
                              keyingFunction: (item) => Key(item.id),
                              itemBuilder: (BuildContext context, MusicAlbum item, Animation<double> animation) {
                                List<Widget> resRow = [];

                                resRow.add(Padding(
                                  padding: const EdgeInsets.only(right: 12.0),
                                  child: ArtistAlbumTile.small(
                                    item,
                                    then: () => context.read<ThemeProvider>().resetTheme(),
                                  ),
                                ));

                                if (snapshot.data!.albums.first == item) {
                                  resRow = [const SizedBox(width: 26), ...resRow];
                                } else if (snapshot.data!.albums.last == item) {
                                  resRow = [...resRow, const SizedBox(width: 26)];
                                }

                                return Align(
                                  alignment: Alignment.topCenter,
                                  child: FadeTransition(
                                    key: Key(item.id),
                                    opacity: animation,
                                    child: SizeTransition(
                                      sizeFactor: CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.easeOut,
                                        reverseCurve: Curves.easeIn,
                                      ),
                                      child: Row(
                                        children: resRow,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        }),
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 200,
            ),
          ],
        ),
      ),
    );
  }
}
