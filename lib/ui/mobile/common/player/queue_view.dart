import 'dart:developer';

import 'package:flutter/material.dart' hide ReorderableList;
import 'package:provider/provider.dart';
import 'package:tearmusic/models/music/track.dart';
import 'package:tearmusic/models/player_info.dart';
import 'package:tearmusic/providers/music_info_provider.dart';
import 'package:tearmusic/providers/user_provider.dart';
import 'package:tearmusic/ui/mobile/common/player/player.dart';
import 'package:tearmusic/ui/mobile/common/player/reorderable_list.dart';
import 'package:tearmusic/ui/mobile/common/tiles/track_tile.dart';

int moveFromIndex = -1;

class TrackData extends StatelessWidget {
  const TrackData({
    Key? key,
    required this.itemKey,
    this.track,
    this.item,
    this.canMove = true,
  }) : super(key: key);

  final bool canMove;
  final Widget? item;
  final MusicTrack? track;
  final Key itemKey;

  Widget _buildChild(BuildContext context, ReorderableItemState state) {
    BoxDecoration decoration;

    if (state == ReorderableItemState.dragProxy || state == ReorderableItemState.dragProxyFinished) {
      // slightly transparent background white dragging (just like on iOS)
      decoration = BoxDecoration(color: Theme.of(context).colorScheme.onSecondary.withOpacity(.95));
    } else {
      bool placeholder = state == ReorderableItemState.placeholder;
      decoration = BoxDecoration(color: placeholder ? null : Colors.transparent);
    }

    if (track == null) {
      return item!;
    }

    return Container(
      decoration: decoration,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Opacity(
          // hide content for placeholder
          opacity: state == ReorderableItemState.placeholder ? 0.0 : 1.0,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(child: TrackTile(track!)),
                // Triggers the reordering
                ReorderableListener(
                  canStart: () {
                    isMoving = true;
                    return true;
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(right: 18.0, left: 18.0),
                    child: Center(
                      child: Icon(Icons.reorder, color: Color(0xFF888888)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ReorderableItem(
        key: itemKey, //
        childBuilder: _buildChild);
  }
}

enum DraggingMode {
  iOS,
  android,
}

class QueueView extends StatefulWidget {
  const QueueView({
    Key? key,
    this.controller,
    required this.queueItems,
  }) : super(key: key);

  final ScrollController? controller;
  final List<TrackData> queueItems;

  @override
  State<QueueView> createState() => _QueueViewState();
}

class _QueueViewState extends State<QueueView> {
  List<MusicTrack> normalQueue = [];
  List<MusicTrack> primaryQueue = [];

  int lastVersion = 0;

  @override
  void initState() {
    super.initState();
    log("[Queue View] init");
    //buildQueue();
  }

  // Returns index of item with given key
  int _indexOfKey(Key key) {
    return widget.queueItems.indexWhere((TrackData t) => t.itemKey == key);
  }

  bool _reorderCallback(Key item, Key newPosition, BuildContext context) {
    int draggingIndex = _indexOfKey(item);
    int newPositionIndex = _indexOfKey(newPosition);

    if (moveFromIndex == -1) moveFromIndex = _indexOfKey(item);

    log("[Queue View] reorder callback: $draggingIndex - $newPositionIndex");

    final draggedItem = widget.queueItems[draggingIndex];

    if (!draggedItem.canMove) return false;

    setState(() {
      debugPrint("[Queue View] Reordering $item -> $newPosition");

      widget.queueItems.removeAt(draggingIndex);
      widget.queueItems.insert(newPositionIndex, draggedItem);
    });
    return true;
  }

  void _reorderDone(Key item) {
    isMoving = false;
    /*final draggedItem = fullQueue[_indexOfKey(item)];
    debugPrint("[Queue View] Reordering finished for ${draggedItem.track!.name}}");*/

    int moveToIndex = _indexOfKey(item);

    int realMoveFromIndex = moveFromIndex;
    int realMoveToIndex = moveToIndex;

    PlayerInfoReorderMoveType moveFrom = PlayerInfoReorderMoveType.normal;
    PlayerInfoReorderMoveType moveTo = PlayerInfoReorderMoveType.normal;

    moveFromIndex -= 1;
    moveToIndex -= 1;

    if (moveToIndex == -1) {
      moveTo = PlayerInfoReorderMoveType.primary;
      moveToIndex = 0;
    }

    if (primaryQueue.isNotEmpty) {
      if (moveFromIndex >= primaryQueue.length) {
        moveFromIndex -= primaryQueue.length + (moveFromIndex != primaryQueue.length ? 1 : 0);
      } else {
        moveFrom = PlayerInfoReorderMoveType.primary;
      }

      if (moveToIndex >= primaryQueue.length + (moveFrom == PlayerInfoReorderMoveType.normal ? 1 : 0) &&
          moveTo != PlayerInfoReorderMoveType.primary) {
        moveToIndex -= primaryQueue.length + (moveFrom == PlayerInfoReorderMoveType.normal ? 1 : 0);
      } else {
        moveTo = PlayerInfoReorderMoveType.primary;
      }
    }

    log("[Queue Reorder] ${moveFrom.name} $moveFromIndex ($realMoveFromIndex) --> ${moveTo.name} $moveToIndex ($realMoveToIndex)");

    context.read<UserProvider>().postReorder(moveFromIndex, moveToIndex, DateTime.now().millisecondsSinceEpoch, moveFrom: moveFrom, moveTo: moveTo);
    //buildQueue();
    //setState(() {});

    moveFromIndex = -1;
  }

  @override
  Widget build(BuildContext context) {
    //log("[Queue View] rebuild");

    //if (context.read<UserProvider>().playerInfo.version != lastVersion) buildQueue();

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 70),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(38.0), topRight: Radius.circular(38.0)),
          child: ReorderableList(
            onReorder: _reorderCallback,
            onReorderDone: _reorderDone,
            child: CustomScrollView(
              controller: widget.controller,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      return widget.queueItems[index];
                    },
                    childCount: widget.queueItems.length,
                  ),
                ),
                /*SliverPadding(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height),
                ),*/
              ],
            ),
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
