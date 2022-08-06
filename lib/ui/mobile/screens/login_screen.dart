import 'dart:async';
import 'dart:developer';

import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:tearmusic/providers/user_provider.dart';
import 'package:tearmusic/ui/mobile/navigator.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';

const discordLoginUrl = "https://api.tear.one/oauth/discord/redirect";

enum LoginState { none, progress, success, failed }

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  var _state = LoginState.none;
  late AnimationController animation;
  late StreamSubscription linkSub;

  @override
  void initState() {
    linkSub = uriLinkStream.listen((event) {
      if (event != null && event.queryParameters["access_token"] != null) {
        linkSub.cancel();
        Provider.of<UserProvider>(context, listen: false)
            .loginCallback(event.queryParameters["access_token"], event.queryParameters["refresh_token"])
            .then((_) => setState(() => _state = LoginState.success));
      } else {
        setState(() => _state = LoginState.failed);
      }
    }, onError: (err) {
      log("[ERROR] UriLinkStream: $err");
      setState(() => _state = LoginState.failed);
    });

    animation = AnimationController(vsync: this, duration: const Duration(seconds: 2));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget loginStateWidget;

    switch (_state) {
      case LoginState.progress:
        loginStateWidget = Scaffold(
          body: Center(
            child: Lottie.network("https://assets10.lottiefiles.com/packages/lf20_rwq6ciql.json"),
          ),
        );
        break;
      case LoginState.success:
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          Future.delayed(const Duration(seconds: 1)).then((_) => animation.forward());
        });
        loginStateWidget = Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 400,
                  child: Lottie.network("https://assets2.lottiefiles.com/packages/lf20_wkebwzpz.json", controller: animation),
                ),
                AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) => Opacity(opacity: (animation.value * 2 - 1).clamp(0, 1), child: child),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Welcome back, ${context.read<UserProvider>().username}!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withOpacity(.7),
                            fontWeight: FontWeight.w600,
                            fontSize: 24.0,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 42.0),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_forward),
                            iconSize: 32.0,
                            padding: const EdgeInsets.all(12.0),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.secondaryContainer),
                              foregroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.onSecondaryContainer),
                            ),
                            onPressed: () {
                              context.read<UserProvider>().loggedIn = true;
                              Navigator.of(context).pushReplacement(CupertinoPageRoute(builder: (_) => const NavigationScreen()));
                            },
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
        break;
      case LoginState.failed:
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          Future.delayed(const Duration(seconds: 1)).then((_) => animation.forward());
        });
        loginStateWidget = Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 150,
                  child: Lottie.network("https://assets10.lottiefiles.com/temp/lf20_yYJhpG.json", controller: animation),
                ),
                AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) => Opacity(opacity: (animation.value * 2 - 1).clamp(0, 1), child: child),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: Text(
                      "Login failed. Please try again later!",
                      style: TextStyle(
                        color: Colors.white.withOpacity(.5),
                        fontWeight: FontWeight.w500,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        break;
      default:
        loginStateWidget = Scaffold(
          body: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 100,
                      width: 100,
                      child: Image.asset("assets/logo.png"),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32.0),
                      child: Text(
                        "Welcome to Tear Music!",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24.0,
                        ),
                      ),
                    ),
                    Card(
                      margin: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
                      elevation: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Please log in to continue...",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(.7),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 12.0),
                                child: TextButton.icon(
                                  icon: const Icon(Ionicons.logo_discord),
                                  label: const Text("Login with Discord", style: TextStyle(fontWeight: FontWeight.w600)),
                                  style: ButtonStyle(
                                    padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0)),
                                    backgroundColor: MaterialStateProperty.all(const Color(0xff5865F2)),
                                    foregroundColor: MaterialStateProperty.all(Colors.white),
                                  ),
                                  onPressed: () {
                                    setState(() => _state = LoginState.progress);
                                    Future.delayed(const Duration(seconds: 1)).then((_) {
                                      launchUrl(Uri.parse(discordLoginUrl), mode: LaunchMode.externalApplication);
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
    }

    return PageTransitionSwitcher(
      duration: const Duration(seconds: 1),
      transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
        return SharedAxisTransition(
          transitionType: SharedAxisTransitionType.horizontal,
          animation: primaryAnimation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );
      },
      child: loginStateWidget,
    );
  }
}
