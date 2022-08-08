import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tearmusic/providers/theme_provider.dart';
import 'package:tearmusic/providers/user_provider.dart';
import 'package:tearmusic/ui/mobile/common/player/player.dart';
import 'package:tearmusic/ui/mobile/pages/home/home_page.dart';
import 'package:tearmusic/ui/mobile/pages/library/library_page.dart';
import 'package:tearmusic/ui/mobile/pages/search/search_page.dart';
import 'package:tearmusic/ui/mobile/screens/login_screen.dart';
import 'package:http/http.dart' as http;

enum MobileRoutes { home, search, library }

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({Key? key}) : super(key: key);

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> with SingleTickerProviderStateMixin {
  final _navigatorState = GlobalKey<NavigatorState>();
  MobileRoutes _selected = MobileRoutes.home;
  late AnimationController animation;

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
  }

  Route _handleRoute(RouteSettings route) {
    if (route.name == MobileRoutes.home.name) {
      return _navigationRoute((context) => const HomePage());
    } else if (route.name == MobileRoutes.search.name) {
      return _navigationRoute((context) => const SearchPage());
    } else if (route.name == MobileRoutes.library.name) {
      return _navigationRoute((context) => const LibraryPage());
    } else {
      return _navigationRoute((context) => const HomePage());
    }
  }

  Route _navigationRoute(Widget Function(BuildContext) builder) {
    return PageRouteBuilder(
      pageBuilder: (context, primaryAnimation, secondaryAnimation) {
        return FadeThroughTransition(
          fillColor: Colors.transparent,
          animation: primaryAnimation,
          secondaryAnimation: secondaryAnimation,
          child: builder(context),
        );
      },
      transitionDuration: const Duration(milliseconds: 500),
      reverseTransitionDuration: const Duration(milliseconds: 500),
    );
  }

  Future<Uint8List> getImage() async {
    final res = await http.get(Uri.parse("https://random.imagecdn.app/500/500"));
    return res.bodyBytes;
  }

  @override
  Widget build(BuildContext context) {
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

    final loggedIn = context.select<UserProvider, bool>((user) => user.loggedIn);

    if (!loggedIn) {
      return const LoginScreen();
    }

    return WillPopScope(
      onWillPop: () async {
        if (_navigatorState.currentState?.canPop() ?? false) {
          _navigatorState.currentState?.pop();
        }
        return false;
      },
      child: FutureBuilder<Uint8List>(
        future: getImage(),
        builder: (context, snapshot) {
          return Material(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.95, -0.95),
                  radius: 1.0,
                  colors: [
                    Theme.of(context).colorScheme.onSecondary.withOpacity(.4),
                    Theme.of(context).colorScheme.onSecondary.withOpacity(.2),
                  ],
                ),
              ),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Navigator(
                    key: _navigatorState,
                    initialRoute: MobileRoutes.home.name,
                    onGenerateRoute: (route) => _handleRoute(route),
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
                      child: MediaQuery.removePadding(
                        context: context,
                        removeTop: true,
                        child: NavigationBar(
                          selectedIndex: _selected.index,
                          onDestinationSelected: (value) {
                            if (value == _selected.index) return;
                            setState(() => _selected = MobileRoutes.values[value]);
                            _navigatorState.currentState?.pushNamedAndRemoveUntil(MobileRoutes.values[value].name, (route) => false);
                            context.read<ThemeProvider>().resetTheme();
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

                  /// Miniplayer
                  if (snapshot.hasData) Player(animation: animation, mainImageBytes: snapshot.data!),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
