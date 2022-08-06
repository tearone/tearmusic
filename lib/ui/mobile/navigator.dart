import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tearmusic/providers/user_provider.dart';
import 'package:tearmusic/ui/mobile/pages/home/home_page.dart';
import 'package:tearmusic/ui/mobile/pages/library/library_page.dart';
import 'package:tearmusic/ui/mobile/pages/search/search_page.dart';
import 'package:tearmusic/ui/mobile/screens/login_screen.dart';

enum MobileRoutes { home, search, library }

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({Key? key}) : super(key: key);

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  final _navigatorState = GlobalKey<NavigatorState>();

  MobileRoutes _selected = MobileRoutes.home;

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
          animation: primaryAnimation,
          secondaryAnimation: secondaryAnimation,
          child: builder(context),
        );
      },
      transitionDuration: const Duration(milliseconds: 500),
      reverseTransitionDuration: const Duration(milliseconds: 500),
    );
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
      child: Scaffold(
        body: SafeArea(
          child: Navigator(
            key: _navigatorState,
            initialRoute: MobileRoutes.home.name,
            onGenerateRoute: (route) => _handleRoute(route),
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selected.index,
          onDestinationSelected: (value) {
            setState(() => _selected = MobileRoutes.values[value]);
            _navigatorState.currentState?.pushReplacementNamed(MobileRoutes.values[value].name);
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
    );
  }
}
