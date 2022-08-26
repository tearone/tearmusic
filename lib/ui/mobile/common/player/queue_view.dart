import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tearmusic/models/music/track.dart';
import 'package:tearmusic/providers/music_info_provider.dart';
import 'package:tearmusic/providers/user_provider.dart';
import 'package:tearmusic/ui/mobile/common/player/queue_tile.dart';
import 'package:tearmusic/ui/mobile/common/tiles/track_tile.dart';

class QueueView extends StatelessWidget {
  const QueueView({
    Key? key,
    this.controller,
    this.scrollable = true,
    required this.normalQueue,
    required this.primaryQueue,
  }) : super(key: key);

  final ScrollController? controller;
  final bool scrollable;
  final List<MusicTrack> normalQueue;
  final List<MusicTrack> primaryQueue;

  @override
  Widget build(BuildContext context) {
    final fullQueue = (primaryQueue + normalQueue);

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 70),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(38.0), topRight: Radius.circular(38.0)),
          child: ListView.builder(
            controller: controller,
            physics: scrollable ? const AlwaysScrollableScrollPhysics() : const NeverScrollableScrollPhysics(),
            itemCount: fullQueue.length + 1,
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
              return TrackTile(fullQueue[index]);
            },
          ),
          /*child: ListView.builder(
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
          ),*/
        ),
      ),
    );
  }
}
