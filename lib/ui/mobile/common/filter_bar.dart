import 'package:flutter/material.dart';

class FilterBar extends StatefulWidget implements PreferredSizeWidget {
  const FilterBar(
      {Key? key,
      required this.items,
      required this.controller,
      this.onTap,
      this.padding = const EdgeInsets.symmetric(horizontal: 24.0),
      this.disableFading = false,
      this.scrollable = true})
      : assert(items.length == controller.length),
        super(key: key);

  final List<Widget> items;
  final TabController controller;
  final EdgeInsetsGeometry padding;
  final Function(int)? onTap;
  @override
  final Size preferredSize = const Size.fromHeight(42.0);
  final bool disableFading;
  final bool scrollable;

  @override
  _FilterBarState createState() => _FilterBarState();
}

class _FilterBarState extends State<FilterBar> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final tabbar = TabBar(
      controller: widget.controller,
      isScrollable: widget.scrollable,
      physics: const BouncingScrollPhysics(),
      // Label
      labelStyle: Theme.of(context).textTheme.subtitle2!.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 15.0,
          ),
      labelPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      labelColor: Theme.of(context).colorScheme.secondary,
      unselectedLabelColor: Colors.white.withOpacity(0.65),
      // Indicator
      indicatorPadding: const EdgeInsets.symmetric(vertical: 8),
      indicator: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary.withOpacity(0.25),
        borderRadius: BorderRadius.circular(45.0),
      ),
      overlayColor: MaterialStateProperty.all(const Color(0x00000000)),
      // Tabs
      padding: EdgeInsets.zero,
      tabs: widget.items,
      onTap: widget.onTap,
    );

    return Container(
        width: MediaQuery.of(context).size.width,
        height: 48.0,
        padding: widget.padding,
        child: widget.disableFading
            ? tabbar
            : AnimatedBuilder(
                animation: widget.controller.animation!,
                builder: (ctx, child) {
                  // avoid fading over selected tab
                  return ShaderMask(
                      shaderCallback: (Rect bounds) {
                        final Color bg = Theme.of(context).scaffoldBackgroundColor;
                        final double index = widget.controller.animation!.value;
                        return LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [
                          index < 0.2 ? Colors.transparent : bg,
                          Colors.transparent,
                          Colors.transparent,
                          index > widget.controller.length - 1.2 ? Colors.transparent : bg
                        ], stops: const [
                          0,
                          0.1,
                          0.9,
                          1
                        ]).createShader(bounds);
                      },
                      blendMode: BlendMode.dstOut,
                      child: child);
                },
                child: tabbar));
  }
}
