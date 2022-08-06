import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                                launchUrl(Uri.parse("https://api.tear.one/oauth/discord/redirect"), mode: LaunchMode.externalApplication);
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
}
