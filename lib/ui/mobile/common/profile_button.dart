import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tearmusic/providers/user_provider.dart';
import 'package:tearmusic/ui/mobile/screens/settings_screen.dart';

class ProfileButton extends StatelessWidget {
  const ProfileButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final avatar = context.select<UserProvider, String>((user) => user.avatar);

    onTap() {
      Navigator.of(context, rootNavigator: true).push(
        CupertinoPageRoute(
          builder: (context) => const SettingsScreen(),
        ),
      );
    }

    return ClipOval(
      child: SizedBox(
        width: 36.0,
        height: 36.0,
        child: Stack(
          children: [
            if (avatar != "") Image.network(avatar),
            Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: onTap,
                customBorder: const CircleBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
