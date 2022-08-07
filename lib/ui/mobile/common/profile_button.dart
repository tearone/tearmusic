import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tearmusic/providers/user_provider.dart';

class ProfileButton extends StatelessWidget {
  const ProfileButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final avatar = context.select<UserProvider, String>((user) => user.avatar);

    return ClipOval(
      child: SizedBox(
        width: 36.0,
        height: 36.0,
        child: avatar != "" ? Image.network(avatar) : null,
      ),
    );
  }
}
