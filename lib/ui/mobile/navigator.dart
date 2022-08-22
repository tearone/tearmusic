import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tearmusic/providers/current_music_provider.dart';
import 'package:tearmusic/providers/navigator_provider.dart';
import 'package:tearmusic/providers/theme_provider.dart';
import 'package:tearmusic/providers/user_provider.dart';
import 'package:tearmusic/providers/will_pop_provider.dart';
import 'package:tearmusic/ui/mobile/common/player/player.dart';
import 'package:tearmusic/ui/mobile/common/wallpaper.dart';
import 'package:tearmusic/ui/mobile/pages/home/home_page.dart';
import 'package:tearmusic/ui/mobile/pages/library/library_page.dart';
import 'package:tearmusic/ui/mobile/pages/search/search_page.dart';
import 'package:tearmusic/ui/mobile/screens/login_screen.dart';

enum MobileRoute { home, search, library }

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({Key? key}) : super(key: key);

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  MobileRoute _selected = MobileRoute.home;
  late AnimationController animation;

  late Widget homePage;
  late Widget searchPage;
  late Widget libraryPage;
  final _homeNavigatorState = GlobalKey<NavigatorState>();
  final _searchNavigatorState = GlobalKey<NavigatorState>();
  final _libraryNavigatorState = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    animation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      upperBound: 2.1,
      lowerBound: -0.1,
      value: 0.0,
    );

    homePage = const HomePage();
    searchPage = const SearchPage();
    libraryPage = const LibraryPage();

    context.read<NavigatorProvider>().restoreState(_selected, notify: false);
    context.read<ThemeProvider>().restoreState(_selected);

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    animation.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      log("App resumed");
      setSystemChrome();
    } else if (state == AppLifecycleState.paused) {
      log("App paused");
    }
  }

  void setSystemChrome() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.dark,
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarContrastEnforced: false,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
      systemStatusBarContrastEnforced: false,
    ));
  }

  double? bottom;

  @override
  Widget build(BuildContext context) {
    setSystemChrome();
    final loggedIn = context.select<UserProvider, bool>((user) => user.loggedIn);

    if (!loggedIn) {
      return const LoginScreen();
    }

    context.read<NavigatorProvider>().setScaffoldState(ScaffoldMessenger.of(context));

    bottom ??= MediaQuery.of(context).padding.bottom;

    return Consumer<WillPopProvider>(
      builder: (context, value, child) {
        return WillPopScope(
          onWillPop: () async {
            final popperResult = (value.popper != null ? value.popper!() : true);
            final state = [
              _homeNavigatorState,
              _searchNavigatorState,
              _libraryNavigatorState,
            ][_selected.index];
            final navResult = (state.currentState?.canPop() ?? false);
            if (popperResult && navResult) {
              context.read<NavigatorProvider>().pop();
            }
            return false;
          },
          child: child!,
        );
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Material(
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              IndexedStack(
                index: _selected.index,
                children: [
                  Navigator(
                    key: _homeNavigatorState,
                    onGenerateRoute: (_) {
                      return PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) {
                          context.read<NavigatorProvider>().setState(MobileRoute.home, Navigator.of(context));
                          context.read<ThemeProvider>().setState(MobileRoute.home);
                          return homePage;
                        },
                      );
                    },
                  ),
                  Navigator(
                    key: _searchNavigatorState,
                    onGenerateRoute: (_) {
                      return PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) {
                          context.read<NavigatorProvider>().setState(MobileRoute.search, Navigator.of(context));
                          context.read<ThemeProvider>().setState(MobileRoute.search);
                          return searchPage;
                        },
                      );
                    },
                  ),
                  Navigator(
                    key: _libraryNavigatorState,
                    onGenerateRoute: (_) {
                      return PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) {
                          context.read<NavigatorProvider>().setState(MobileRoute.library, Navigator.of(context));
                          context.read<ThemeProvider>().setState(MobileRoute.library);
                          return libraryPage;
                        },
                      );
                    },
                  ),
                ],
              ),

              AnimatedTheme(
                data: context.select<ThemeProvider, ThemeData>((e) => e.navigationTheme),
                child: AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, (animation.value * 120).clamp(0, 120)),
                      child: child,
                    );
                  },
                  child: MediaQuery(
                    data: MediaQueryData(padding: EdgeInsets.only(bottom: bottom ?? 0)),
                    child: NavigationBar(
                      selectedIndex: _selected.index,
                      onDestinationSelected: (value) {
                        if (value == _selected.index) return;
                        setState(() => _selected = MobileRoute.values[value]);
                        // _navigatorState.currentState?.pushNamedAndRemoveUntil(MobileRoutes.values[value].name, (route) => false);
                        context.read<NavigatorProvider>().restoreState(_selected, notify: true);
                        context.read<ThemeProvider>().restoreState(_selected);
                      },
                      destinations: const [
                        NavigationDestination(
                          label: "Home",
                          icon: Icon(Icons.home_outlined),
                          selectedIcon: Icon(Icons.home_filled),
                        ),
                        NavigationDestination(
                          label: "Search",
                          icon: Icon(Icons.search_outlined),
                        ),
                        NavigationDestination(
                          label: "Library",
                          icon: Icon(Icons.library_music_outlined),
                          selectedIcon: Icon(Icons.library_music),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              /// Opacity
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    if (animation.value > 0.01) {
                      return Container(
                        color: Colors.black.withOpacity((animation.value * 1.2).clamp(0, 1)),
                        child: Container(
                          color: Theme.of(context).colorScheme.onSecondary.withOpacity((animation.value * 3 - 2).clamp(0, .45)),
                        ),
                      );
                    } else {
                      return const SizedBox();
                    }
                  },
                ),
              ),

              /// Player Wallpaper
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    if (animation.value > 0.01) {
                      return Opacity(
                        opacity: animation.value.clamp(0.0, 1.0),
                        child: const Wallpaper(gradient: false, particleOpacity: .3),
                      );
                    } else {
                      return const SizedBox();
                    }
                  },
                ),
              ),

              /// Miniplayer
              Selector<CurrentMusicProvider, bool>(
                selector: (_, p) => p.playing != null,
                builder: (context, value, child) {
                  if (!value) return const SizedBox();
                  return AnimatedOpacity(
                    duration: const Duration(milliseconds: 500),
                    opacity: value ? 1 : 0,
                    child: child,
                  );
                },
                child: Player(animation: animation),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
