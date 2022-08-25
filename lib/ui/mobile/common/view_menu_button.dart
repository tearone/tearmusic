import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class ViewMenuButton extends StatelessWidget {
  const ViewMenuButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SizedBox(
        height: 34,
        width: 34,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 12.0,
            sigmaY: 12.0,
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              showMaterialModalBottomSheet(
                context: context,
                useRootNavigator: true,
                builder: (context) => Container(height: 300),
              );
            },
            icon: Container(
              padding: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary.withOpacity(.3),
                shape: BoxShape.circle,
              ),
              child: Icon(CupertinoIcons.ellipsis, color: Theme.of(context).colorScheme.secondary),
            ),
            iconSize: 26.0,
          ),
        ),
      ),
    );
  }
}
