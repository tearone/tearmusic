import 'dart:async';

import 'package:automatic_animated_list/automatic_animated_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
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
import 'package:tearmusic/ui/mobile/common/views/content_list_view.dart';
import 'package:tearmusic/ui/mobile/common/wallpaper.dart';

import 'package:tearmusic/ui/mobile/pages/library/album_loading_tile.dart';
import 'package:tearmusic/ui/mobile/pages/library/artist_loading_tile.dart';
import 'package:tearmusic/ui/mobile/pages/library/playlist_loading_tile.dart';
import 'package:tearmusic/ui/mobile/pages/library/track_loading_tile.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({Key? key}) : super(key: key);

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  final _scrollController = ScrollController();
  bool viewScrolled = false;
  bool viewScrolledTitle = false;
  bool viewScrolledShadow = false;
  Timer viewScrolledAgent = Timer(Duration.zero, () {});

  List<BatchTrackHistory>? _trackHistory;
  bool _trackHistoryNeedsRefresh = true;
  Future<List<BatchTrackHistory>> readTrackHistory() async {
    if (_trackHistoryNeedsRefresh) {
      final items = await context.read<MusicInfoProvider>().libraryBatch(LibraryType.track_history, limit: 3);
      _trackHistory = items.track_history;
      _trackHistoryNeedsRefresh = false;
    }
    return _trackHistory ?? [];
  }

  List<MusicTrack>? _likedSongs;
  bool _likedSongsNeedsRefresh = true;
  Future<List<MusicTrack>> readLikedTracks() async {
    if (_likedSongsNeedsRefresh) {
      final items = await context.read<MusicInfoProvider>().libraryBatch(LibraryType.liked_tracks, limit: 3);
      _likedSongs = items.tracks;
      _likedSongsNeedsRefresh = false;
    }
    return _likedSongs ?? [];
  }

  List<MusicPlaylist>? _likedPlaylists;
  bool _likedPlaylistsNeedsRefresh = true;
  Future<List<MusicPlaylist>> readLikedPlaylists() async {
    if (_likedPlaylistsNeedsRefresh) {
      final items = await context.read<MusicInfoProvider>().libraryBatch(LibraryType.liked_playlists, limit: 3);
      _likedPlaylists = items.playlists;
      _likedPlaylistsNeedsRefresh = false;
    }
    return _likedPlaylists ?? [];
  }

  List<MusicArtist>? _likedArtists;
  bool _likedArtistsNeedsRefresh = true;
  Future<List<MusicArtist>> readLikedArtists() async {
    if (_likedArtistsNeedsRefresh) {
      final items = await context.read<MusicInfoProvider>().libraryBatch(LibraryType.liked_artists, limit: 3);
      _likedArtists = items.artists;
      _likedArtistsNeedsRefresh = false;
    }
    return _likedArtists ?? [];
  }

  List<MusicAlbum>? _likedAlbums;
  bool _likedAlbumsNeedsRefresh = true;
  Future<List<MusicAlbum>> readLikedAlbums() async {
    if (_likedAlbumsNeedsRefresh) {
      final items = await context.read<MusicInfoProvider>().libraryBatch(LibraryType.liked_albums, limit: 5);
      _likedAlbums = items.albums;
      _likedAlbumsNeedsRefresh = false;
    }
    return _likedAlbums ?? [];
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(appBarBackground);
  }

  @override
  void dispose() {
    _scrollController.removeListener(appBarBackground);
    super.dispose();
  }

  void appBarBackground() {
    if (_scrollController.positions.isEmpty) return;
    final value = _scrollController.position.pixels > 0;
    if (viewScrolled != value) {
      viewScrolled = value;
      if (value) viewScrolledTitle = value;
      viewScrolledShadow = value;
      setState(() {});
      if (viewScrolledAgent.isActive) viewScrolledAgent.cancel();
      viewScrolledAgent = Timer(const Duration(milliseconds: 100), () => mounted ? setState(() => viewScrolledTitle = value) : null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wallpaper(
      child: CupertinoScrollbar(
        controller: _scrollController,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              pinned: true,
              snap: false,
              floating: false,
              centerTitle: false,
              backgroundColor: viewScrolledTitle
                  ? ElevationOverlay.applySurfaceTint(Theme.of(context).colorScheme.surface, Theme.of(context).colorScheme.surfaceTint, 2.0)
                  : Colors.transparent,
              surfaceTintColor: Colors.transparent,
              shadowColor: viewScrolledShadow ? Colors.black : Colors.transparent,
              forceElevated: viewScrolledTitle,
              elevation: 0,
              title: const Text(
                "Your Library",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              actions: const [
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(right: 14.0),
                    child: ProfileButton(),
                  ),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Card(
                  elevation: 2.0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 12.0, right: 8.0),
                        child: Row(
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(right: 8.0),
                              child: Icon(CupertinoIcons.memories, size: 20.0),
                            ),
                            const Expanded(
                              child: Text(
                                "Recently played",
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(CupertinoPageRoute(
                                  builder: (context) => ContentListView<BatchTrackHistory>(
                                    builder: (builder) => Selector<UserProvider, List<UserTrackHistory>>(
                                      selector: (_, p) => p.library?.track_history ?? [],
                                      builder: builder,
                                    ),
                                    itemBuilder: (context, item) => TrackTile(item.track),
                                    retriever: () async {
                                      final items = await context.read<MusicInfoProvider>().libraryBatch(LibraryType.track_history, limit: 50);
                                      return items.track_history;
                                    },
                                    loadingWidget: const TrackLoadingTile(itemCount: 8),
                                    title: const Text(
                                      "Recently Played",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ));
                              },
                              child: const Text("Show All"),
                            )
                          ],
                        ),
                      ),
                      Selector<UserProvider, List<UserTrackHistory>>(
                        selector: (_, user) => user.library?.track_history ?? [],
                        shouldRebuild: (previous, next) {
                          final value = !listEquals(previous, next);
                          if (value) {
                            _trackHistoryNeedsRefresh = true;
                          }
                          return value;
                        },
                        builder: ((context, value, child) {
                          if (value.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.only(top: 6.0, bottom: 24.0),
                              child: Center(
                                child: Text("Start listening to view recently played"),
                              ),
                            );
                          }

                          return FutureBuilder<List<BatchTrackHistory>>(
                            future: readTrackHistory(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const TrackLoadingTile();
                              }

                              return AutomaticAnimatedList(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                items: snapshot.data!,
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
                            },
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Card(
                  elevation: 2.0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 12.0, right: 8.0),
                        child: Row(
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(right: 8.0),
                              child: Icon(CupertinoIcons.music_note_2, size: 20.0),
                            ),
                            const Expanded(
                              child: Text(
                                "Liked Songs",
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(CupertinoPageRoute(
                                  builder: (context) => ContentListView<MusicTrack>(
                                    builder: (builder) => Selector<UserProvider, List<String>>(
                                      selector: (_, p) => p.library?.liked_tracks ?? [],
                                      builder: builder,
                                    ),
                                    itemBuilder: (context, item) => TrackTile(item),
                                    retriever: () async {
                                      final items = await context.read<MusicInfoProvider>().libraryBatch(LibraryType.liked_tracks, limit: 50);
                                      return items.tracks;
                                    },
                                    loadingWidget: const TrackLoadingTile(itemCount: 8),
                                    title: const Text(
                                      "Liked Songs",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
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
                      Selector<UserProvider, List<String>>(
                        selector: (_, user) => user.library?.liked_tracks ?? [],
                        shouldRebuild: (previous, next) {
                          final value = !listEquals(previous, next);
                          if (value) {
                            _likedSongsNeedsRefresh = true;
                          }
                          return value;
                        },
                        builder: ((context, value, child) {
                          if (value.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.only(top: 6.0, bottom: 24.0),
                              child: Center(
                                child: Text("You have no liked songs"),
                              ),
                            );
                          }

                          return FutureBuilder<List<MusicTrack>>(
                            future: readLikedTracks(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const TrackLoadingTile();
                              }

                              return AutomaticAnimatedList(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                items: snapshot.data!,
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
                            },
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Card(
                  elevation: 2.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 12.0, right: 8.0),
                        child: Row(
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(right: 8.0),
                              child: Icon(CupertinoIcons.music_note_list, size: 20.0),
                            ),
                            const Expanded(
                              child: Text(
                                "Liked Playlists",
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(CupertinoPageRoute(
                                  builder: (context) => ContentListView<MusicPlaylist>(
                                    itemBuilder: (context, item) => SearchPlaylistTile(item),
                                    retriever: () async {
                                      final items = await context.read<MusicInfoProvider>().libraryBatch(LibraryType.liked_playlists, limit: 50);
                                      return items.playlists;
                                    },
                                    loadingWidget: const PlaylistLoadingTile(itemCount: 8),
                                    title: const Text(
                                      "Liked Playlists",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ));
                              },
                              child: const Text("Show All"),
                            )
                          ],
                        ),
                      ),
                      Selector<UserProvider, List<String>>(
                        selector: (_, user) => user.library?.liked_playlists ?? [],
                        shouldRebuild: (previous, next) {
                          final value = !listEquals(previous, next);
                          if (value) {
                            _likedPlaylistsNeedsRefresh = true;
                          }
                          return value;
                        },
                        builder: ((context, value, child) {
                          if (value.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.only(top: 6.0, bottom: 24.0),
                              child: Center(
                                child: Text("You have no liked playlists"),
                              ),
                            );
                          }

                          return FutureBuilder<List<MusicPlaylist>>(
                            future: readLikedPlaylists(),
                            builder: ((context, snapshot) {
                              if (!snapshot.hasData) {
                                return const PlaylistLoadingTile();
                              }

                              return AutomaticAnimatedList(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                items: snapshot.data!,
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
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0, bottom: 12.0, left: 28.0, right: 8.0),
                      child: Row(
                        children: const [
                          Padding(
                            padding: EdgeInsets.only(right: 8.0),
                            child: Icon(CupertinoIcons.person, size: 20.0),
                          ),
                          Text(
                            "Followed Artists",
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0),
                          ),
                        ],
                      ),
                    ),
                    Selector<UserProvider, List<String>>(
                      selector: (_, user) => user.library?.liked_artists ?? [],
                      shouldRebuild: (previous, next) {
                        final value = !listEquals(previous, next);
                        if (value) {
                          _likedArtistsNeedsRefresh = true;
                        }
                        return value;
                      },
                      builder: ((context, value, child) {
                        if (value.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.only(top: 6.0, bottom: 24.0),
                            child: Center(
                              child: Text("You have no followed artists"),
                            ),
                          );
                        }

                        return FutureBuilder<List<MusicArtist>>(
                          future: readLikedArtists(),
                          builder: ((context, snapshot) {
                            if (!snapshot.hasData) {
                              return const SizedBox(height: 150, child: ArtistLoadingTile());
                            }

                            return SizedBox(
                              height: 150,
                              child: AutomaticAnimatedList(
                                scrollDirection: Axis.horizontal,
                                items: snapshot.data!,
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

                                  if (snapshot.data!.first == item) {
                                    resRow = [const SizedBox(width: 24), ...resRow];
                                  } else if (snapshot.data!.last == item) {
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
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 6.0, bottom: 16.0, left: 28.0, right: 8.0),
                      child: Row(
                        children: const [
                          Padding(
                            padding: EdgeInsets.only(right: 8.0),
                            child: Icon(CupertinoIcons.music_albums, size: 20.0),
                          ),
                          Text(
                            "Liked Albums",
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0),
                          ),
                        ],
                      ),
                    ),
                    Selector<UserProvider, List<String>>(
                      selector: (_, user) => user.library?.liked_albums ?? [],
                      shouldRebuild: (previous, next) {
                        final value = !listEquals(previous, next);
                        if (value) {
                          _likedAlbumsNeedsRefresh = true;
                        }
                        return value;
                      },
                      builder: ((context, value, child) {
                        if (value.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.only(top: 6.0, bottom: 24.0),
                            child: Center(
                              child: Text("You have no liked albums"),
                            ),
                          );
                        }

                        return FutureBuilder<List<MusicAlbum>>(
                          future: readLikedAlbums(),
                          builder: ((context, snapshot) {
                            if (!snapshot.hasData) {
                              return const SizedBox(height: 200, child: AlbumLoadingTile());
                            }

                            return SizedBox(
                              height: 200,
                              child: AutomaticAnimatedList(
                                scrollDirection: Axis.horizontal,
                                items: snapshot.data!,
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

                                  if (snapshot.data!.first == item) {
                                    resRow = [const SizedBox(width: 26), ...resRow];
                                  } else if (snapshot.data!.last == item) {
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
            ),
            const SliverToBoxAdapter(
              child: SafeArea(
                top: false,
                child: SizedBox(
                  height: 100,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
