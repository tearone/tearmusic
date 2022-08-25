import 'dart:ui';

import 'package:flutter/material.dart';

class Knob extends StatelessWidget {
  const Knob({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        height: 64,
        width: double.infinity,
        alignment: Alignment.topCenter,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(.1),
              Colors.black.withOpacity(0),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SizedBox(
            height: 6.0,
            width: 52.0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(45.0),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 24.0,
                  sigmaY: 24.0,
                ),
                child: Container(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(.25),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
