import 'package:flutter/material.dart';
import 'package:tearmusic/ui/mobile/common/player/queue_tile.dart';

class QueueView extends StatelessWidget {
  const QueueView({Key? key, this.controller, this.scrollable = true}) : super(key: key);

  final ScrollController? controller;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 70),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(38.0), topRight: Radius.circular(38.0)),
          child: ListView.builder(
            controller: controller,
            physics: scrollable ? const AlwaysScrollableScrollPhysics() : const NeverScrollableScrollPhysics(),
            itemCount: 50,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(left: 24.0, top: 16.0, bottom: 12.0),
                  child: Text(
                    "Queue",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                      fontSize: 24.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }
              index = index - 1;
              return const QueueTile();
            },
          ),
        ),
      ),
    );
  }
}
