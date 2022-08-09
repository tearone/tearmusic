import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:tearmusic/providers/user_provider.dart';

class SettingsAlertDialog {
  void showCustomDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (c) => Dialog(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            color: Theme.of(context).colorScheme.background,
          ),
          height: 250.0,
          width: 300.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 16.0),
                child: Icon(Ionicons.warning, size: 45, color: Color.fromARGB(255, 242, 193, 88)),
              ),
              const Text(
                "Are you sure?",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 24.0),
              ),
              const Text(
                "all yo stuff will be deleted.",
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18.0, color: Color.fromARGB(255, 206, 206, 206)),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: TextButton.icon(
                          icon: const Icon(Ionicons.checkmark),
                          label: const Text("Yes!", style: TextStyle(fontWeight: FontWeight.w800)),
                          style: ButtonStyle(
                            padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0)),
                            backgroundColor: MaterialStateProperty.all(Color.fromARGB(255, 242, 88, 88).withOpacity(.25)),
                            foregroundColor: MaterialStateProperty.all(Color.fromARGB(255, 242, 88, 88)),
                          ),
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true).pop('dialog');
                            Provider.of<UserProvider>(context, listen: false).logoutCallback();
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: TextButton.icon(
                          icon: const Icon(Ionicons.close),
                          label: const Text("Nahh", style: TextStyle(fontWeight: FontWeight.w800)),
                          style: ButtonStyle(
                            padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0)),
                            backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primary.withOpacity(.25)),
                            foregroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primary),
                          ),
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true).pop('dialog');
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
