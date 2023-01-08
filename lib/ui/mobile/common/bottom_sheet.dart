import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const BoxShadow _kDefaultBoxShadow = BoxShadow(blurRadius: 10, color: Colors.black12, spreadRadius: 5);
const double _kPreviousPageVisibleOffset = 10;

class BottomSheetContainer extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final Radius topRadius;
  final BoxShadow? shadow;

  static const Radius _kDefaultTopRadius = Radius.circular(12);

  const BottomSheetContainer({
    Key? key,
    required this.child,
    this.backgroundColor,
    this.topRadius = _kDefaultTopRadius,
    this.shadow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final topSafeAreaPadding = MediaQuery.of(context).padding.top;
    final topPadding = _kPreviousPageVisibleOffset + topSafeAreaPadding;

    final shadowOrDefault = shadow ?? _kDefaultBoxShadow;
    final backgroundOrDefault = backgroundColor ?? CupertinoTheme.of(context).scaffoldBackgroundColor;
    return Padding(
      padding: EdgeInsets.only(top: topPadding),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: topRadius),
        child: Container(
          decoration: BoxDecoration(color: backgroundOrDefault, boxShadow: [shadowOrDefault]),
          width: double.infinity,
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true, //Remove top Safe Area
            child: child,
          ),
        ),
      ),
    );
  }
}
