import 'package:flutter/material.dart';

class LyricsUnavailalbe extends StatelessWidget {
  const LyricsUnavailalbe({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const Text(
            "🫤",
            style: TextStyle(
              fontSize: 64.0,
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 12.0),
            child: Text(
              "Sorry, no lyrics...",
              style: TextStyle(
                fontSize: 32.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 100.0),
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              iconSize: 32.0,
              padding: const EdgeInsets.all(12.0),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.secondaryContainer),
                foregroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.onSecondaryContainer),
              ),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 12.0),
            child: Text("Back"),
          ),
        ],
      ),
    );
  }
}
