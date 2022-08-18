import 'package:flutter/material.dart';

class LyricsFullText extends StatelessWidget {
  const LyricsFullText(this.fullText, {Key? key}) : super(key: key);

  final String fullText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        fullText,
        style: const TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
