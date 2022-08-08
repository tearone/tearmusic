import 'dart:async';
import 'dart:math';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:tearmusic/models/music/search_results.dart';
import 'package:tearmusic/providers/music_info_provider.dart';
import 'package:tearmusic/ui/mobile/common/filter_bar.dart';
import 'package:tearmusic/ui/mobile/common/search_album_tile.dart';
import 'package:tearmusic/ui/mobile/common/search_artist_tile.dart';
import 'package:tearmusic/ui/mobile/common/search_playlist_tile.dart';
import 'package:tearmusic/ui/mobile/common/search_track_tile.dart';
import 'package:tearmusic/ui/mobile/pages/search/top_result_container.dart';

enum SearchResult { prepare, empty, loading, done }

// Part of the filter code is stolen from https://github.com/filc/naplo

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with SingleTickerProviderStateMixin {
  final _searchInputController = TextEditingController();
  final _searchInputFocus = FocusNode();
  late TabController _tabController;
  late PageController _pageController;

  List<String> listOrder = ['A', 'B', 'C', 'D', 'E'];

  SearchResults? results;
  SearchResult result = SearchResult.prepare;

  late Timer searchAfterTyping;
  String lastTerm = "";
  final Duration searchAfterDuration = const Duration(milliseconds: 350);

  @override
  void initState() {
    super.initState();

    searchAfterTyping = Timer(const Duration(), () => {});

    _tabController = TabController(length: 5, vsync: this);
    _pageController = PageController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchInputFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void onHandlerChanged(value) {
    if (value == "") {
      setState(() => result = SearchResult.prepare);
      lastTerm = value;
      return;
    }
    if (lastTerm == value) return;
    lastTerm = value;

    setState(() {
      result = SearchResult.loading;
    });

    if (searchAfterTyping.isActive) setState(() => searchAfterTyping.cancel());
    setState(() => searchAfterTyping = Timer(searchAfterDuration, () => searchResults(value)));
  }

  Future<void> searchResults(String value) async {
    results = await context.read<MusicInfoProvider>().search(value);
    if (lastTerm != value) results = null;
    setState(() {
      if (results == null) {
        result = SearchResult.prepare;
      } else if (results?.isEmpty ?? true) {
        result = SearchResult.empty;
      } else {
        result = SearchResult.done;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 24.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 24.0, right: 24.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0, left: 12.0),
                      child: Icon(Icons.search, color: Theme.of(context).colorScheme.secondary),
                    ),
                    Expanded(
                      child: TextField(
                        focusNode: _searchInputFocus,
                        autocorrect: false,
                        autofocus: false,
                        onChanged: onHandlerChanged,
                        onSubmitted: (value) => onHandlerChanged(value),
                        controller: _searchInputController,
                        textInputAction: TextInputAction.search,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                        decoration: const InputDecoration(
                          hintText: "Search...",
                          hintStyle: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
                          border: UnderlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _searchInputController.text = "";
                        _searchInputFocus.requestFocus();
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: FilterBar(
                items: const [
                  Tab(text: "Top"),
                  Tab(text: "Songs"),
                  Tab(text: "Playlists"),
                  Tab(text: "Albums"),
                  Tab(text: "Artists"),
                ],
                controller: _tabController,
                onTap: (index) {
                  if (_pageController.positions.isEmpty) return;

                  int selectedPage = _pageController.page!.round();

                  if (index == selectedPage) return;
                  if (_pageController.page?.roundToDouble() != _pageController.page) {
                    _pageController.animateToPage(index, curve: Curves.easeIn, duration: kTabScrollDuration);
                    return;
                  }

                  // swap current page with target page
                  setState(() {
                    _pageController.jumpToPage(index);
                    String currentList = listOrder[selectedPage];
                    listOrder[selectedPage] = listOrder[index];
                    listOrder[index] = currentList;
                  });
                },
              ),
            ),
            Expanded(
              child: PageTransitionSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
                  return SharedAxisTransition(
                    fillColor: Colors.transparent,
                    animation: primaryAnimation,
                    secondaryAnimation: secondaryAnimation,
                    transitionType: SharedAxisTransitionType.vertical,
                    child: child,
                  );
                },
                child: () {
                  switch (result) {
                    case SearchResult.prepare:
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 200.0),
                        child: Center(
                          child: Transform.rotate(
                            angle: pi / 14.0,
                            child: Icon(
                              Icons.music_note,
                              size: 82.0,
                              color: Theme.of(context).colorScheme.secondaryContainer,
                            ),
                          ),
                        ),
                      );
                    case SearchResult.empty:
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 200.0),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                "🫥",
                                style: TextStyle(fontSize: 64.0),
                              ),
                              Text(
                                "No results...",
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    case SearchResult.loading:
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 200.0),
                        child: Center(
                          child: LoadingAnimationWidget.staggeredDotsWave(
                            color: Theme.of(context).colorScheme.secondary.withOpacity(.2),
                            size: 64.0,
                          ),
                        ),
                      );
                    case SearchResult.done:
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _pageController.jumpToPage(_tabController.index);
                      });
                      return NotificationListener<ScrollNotification>(
                        onNotification: (notification) {
                          // from flutter source
                          if (notification is ScrollUpdateNotification && !_tabController.indexIsChanging) {
                            if ((_pageController.page! - _tabController.index).abs() > 1.0) {
                              _tabController.index = _pageController.page!.floor();
                            }
                            _tabController.offset = (_pageController.page! - _tabController.index).clamp(-1.0, 1.0);
                          } else if (notification is ScrollEndNotification) {
                            _tabController.index = _pageController.page!.round();
                            if (!_tabController.indexIsChanging) {
                              _tabController.offset = (_pageController.page! - _tabController.index).clamp(-1.0, 1.0);
                            }
                          }
                          return false;
                        },
                        child: PageView.custom(
                          controller: _pageController,
                          childrenDelegate: SliverChildBuilderDelegate(
                            (BuildContext context, int pageIndex) {
                              if (pageIndex == 0) {
                                return ListView.builder(
                                  itemCount: 5,
                                  itemBuilder: (context, index) {
                                    if (index == 4) {
                                      return const SizedBox(height: 200);
                                    }

                                    const topShowCount = 3;

                                    switch (index) {
                                      case 0:
                                        return TopResultContainer(
                                          kind: "Songs",
                                          results: results!.tracks
                                              .sublist(0, min(results!.tracks.length, topShowCount))
                                              .map((e) => SearchTrackTile(e))
                                              .toList(),
                                          index: 1,
                                          pageController: _pageController,
                                          tabController: _tabController,
                                        );

                                      case 1:
                                        return TopResultContainer(
                                          kind: "Playlists",
                                          results: results!.playlists
                                              .sublist(0, min(results!.playlists.length, topShowCount))
                                              .map((e) => SearchPlaylistTile(e))
                                              .toList(),
                                          index: 2,
                                          pageController: _pageController,
                                          tabController: _tabController,
                                        );

                                      case 2:
                                        return TopResultContainer(
                                          kind: "Albums",
                                          results: results!.albums
                                              .sublist(0, min(results!.albums.length, topShowCount))
                                              .map((e) => SearchAlbumTile(e))
                                              .toList(),
                                          index: 3,
                                          pageController: _pageController,
                                          tabController: _tabController,
                                        );

                                      case 3:
                                        return TopResultContainer(
                                          kind: "Artists",
                                          results: results!.artists
                                              .sublist(0, min(results!.artists.length, topShowCount))
                                              .map((e) => SearchArtistTile(e))
                                              .toList(),
                                          index: 4,
                                          pageController: _pageController,
                                          tabController: _tabController,
                                        );
                                    }

                                    return const SizedBox();
                                  },
                                );
                              } else {
                                switch (pageIndex) {
                                  case 1:
                                    return ListView.builder(
                                      itemCount: (results?.tracks.length ?? 0) + 1,
                                      itemBuilder: (context, index) {
                                        if (index == results!.tracks.length) {
                                          return const SizedBox(height: 200);
                                        }

                                        return SearchTrackTile(results!.tracks[index]);
                                      },
                                    );
                                  case 2:
                                    return ListView.builder(
                                      itemCount: (results?.playlists.length ?? 0) + 1,
                                      itemBuilder: (context, index) {
                                        if (index == results!.playlists.length) {
                                          return const SizedBox(height: 200);
                                        }

                                        return SearchPlaylistTile(results!.playlists[index]);
                                      },
                                    );
                                  case 3:
                                    return ListView.builder(
                                      itemCount: (results?.albums.length ?? 0) + 1,
                                      itemBuilder: (context, index) {
                                        if (index == results!.albums.length) {
                                          return const SizedBox(height: 200);
                                        }

                                        return SearchAlbumTile(results!.albums[index]);
                                      },
                                    );
                                  case 4:
                                    return ListView.builder(
                                      itemCount: (results?.artists.length ?? 0) + 1,
                                      itemBuilder: (context, index) {
                                        if (index == results!.artists.length) {
                                          return const SizedBox(height: 200);
                                        }

                                        return SearchArtistTile(results!.artists[index]);
                                      },
                                    );
                                }
                              }

                              return null;
                            },
                            childCount: 5,
                            findChildIndexCallback: (Key key) {
                              final ValueKey<String> valueKey = key as ValueKey<String>;
                              final String data = valueKey.value;
                              return listOrder.indexOf(data);
                            },
                          ),
                          physics: const PageScrollPhysics().applyTo(const BouncingScrollPhysics()),
                        ),
                      );
                  }
                }(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
