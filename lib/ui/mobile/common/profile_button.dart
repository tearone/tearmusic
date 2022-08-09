import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tearmusic/providers/user_provider.dart';
import 'package:tearmusic/ui/mobile/screens/settings_screen.dart';

class ProfileButton extends StatelessWidget {
  const ProfileButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final avatar = context.select<UserProvider, String>((user) => user.avatar);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, primaryAnimation, secondaryAnimation) {
              return FadeThroughTransition(
                fillColor: Colors.transparent,
                animation: primaryAnimation,
                secondaryAnimation: secondaryAnimation,
                child: const SettingsScreen(),
              );
            },
            transitionDuration: const Duration(milliseconds: 500),
            reverseTransitionDuration: const Duration(milliseconds: 500),
          ),
        );
      },
      child: ClipOval(
        child: SizedBox(
          width: 36.0,
          height: 36.0,
          child: avatar != "" ? Image.network(avatar) : null,
        ),
      ),
    );
  }
}
