// ignore_for_file: dead_code

import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tearmusic/providers/current_music_provider.dart';
import 'package:tearmusic/ui/mobile/common/player/lyrics_view.dart';
import 'package:tearmusic/ui/mobile/common/player/queue_view.dart';
import 'package:tearmusic/ui/mobile/common/player/slider.dart';
import 'package:tearmusic/ui/mobile/common/player/track_image.dart';
import 'package:tearmusic/ui/mobile/common/player/track_info.dart';
import 'package:tearmusic/ui/common/format.dart';
import 'package:tearmusic/utils.dart';

enum PlayerState { mini, expanded, queue }

class Player extends StatefulWidget {
  const Player({Key? key, required this.animation}) : super(key: key);

  final AnimationController animation;

  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> with SingleTickerProviderStateMixin {
  double offset = 0.0;
  double prevOffset = 0.0;
  late Size screenSize;
  late double topInset;
  late double bottomInset;
  late double maxOffset;
  final velocity = VelocityTracker.withKind(PointerDeviceKind.touch);
  static const Cubic bouncingCurve = Cubic(0.175, 0.885, 0.32, 1.125);

  static const headRoom = 50.0;
  static const actuationOffset = 100.0; // min distance to snap
  static const deadSpace = 100.0; // Distance from bottom to ignore swipes

  /// Horizontal track switching
  double sOffset = 0.0;
  double sPrevOffset = 0.0;
  double stParallax = 1.0;
  double siParallax = 1.15;
  static const sActuationMulti = 1.5;
  late double sMaxOffset;
  late AnimationController sAnim;

  late ScrollController scrollController;
  bool queueScrollable = false;
  bool bounceUp = false;
  bool bounceDown = false;

  @override
  void initState() {
    super.initState();
    final media = MediaQueryData.fromWindow(window);
    topInset = media.padding.top;
    bottomInset = media.padding.bottom;
    screenSize = media.size;
    maxOffset = screenSize.height;
    sMaxOffset = screenSize.width;
    sAnim = AnimationController(
      vsync: this,
      lowerBound: -1,
      upperBound: 1,
      value: 0.0,
    );
    scrollController = ScrollController();
  }

  @override
  void dispose() {
    sAnim.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void verticalSnapping() {
    final distance = prevOffset - offset;
    final speed = velocity.getVelocity().pixelsPerSecond.dy;
    const threshold = 500.0;

    // speed threshold is an eyeballed value
    // used to actuate on fast flicks too

    if (prevOffset > maxOffset) {
      // Start from queue
      if (speed > threshold || distance > actuationOffset) {
        snapToExpanded();
      } else {
        snapToQueue();
      }
    } else if (prevOffset > maxOffset / 2) {
      // Start from top
      if (speed > threshold || distance > actuationOffset) {
        snapToMini();
      } else if (-speed > threshold || -distance > actuationOffset) {
        snapToQueue();
      } else {
        snapToExpanded();
      }
    } else {
      // Start from bottom
      if (-speed > threshold || -distance > actuationOffset) {
        snapToExpanded();
      } else {
        snapToMini();
      }
    }
  }

  void snapToExpanded() {
    offset = maxOffset;
    if (prevOffset < maxOffset) bounceUp = true;
    if (prevOffset > maxOffset) bounceDown = true;
    snap();
  }

  void snapToMini() {
    offset = 0;
    bounceDown = false;
    snap();
  }

  void snapToQueue() {
    offset = maxOffset * 2;
    bounceUp = false;
    snap();
  }

  void snap() {
    widget.animation
        .animateTo(
      offset / maxOffset,
      curve: bouncingCurve,
      duration: const Duration(milliseconds: 300),
    )
        .then((_) {
      bounceUp = false;
    });
    if ((prevOffset - offset).abs() > actuationOffset) HapticFeedback.lightImpact();
  }

  void snapToPrev() {
    sOffset = -sMaxOffset;
    sAnim
        .animateTo(
      -1.0,
      curve: bouncingCurve,
      duration: const Duration(milliseconds: 300),
    )
        .then((_) {
      sOffset = 0;
      sAnim.animateTo(0.0, duration: Duration.zero);
      // tracks.insert(0, tracks.removeLast());
    });
    if ((sPrevOffset - sOffset).abs() > actuationOffset) HapticFeedback.lightImpact();
  }

  void snapToCurrent() {
    sOffset = 0;
    sAnim.animateTo(
      0.0,
      curve: bouncingCurve,
      duration: const Duration(milliseconds: 300),
    );
    if ((sPrevOffset - sOffset).abs() > actuationOffset) HapticFeedback.lightImpact();
  }

  void snapToNext() {
    sOffset = sMaxOffset;
    sAnim
        .animateTo(
      1.0,
      curve: bouncingCurve,
      duration: const Duration(milliseconds: 300),
    )
        .then((_) {
      sOffset = 0;
      sAnim.animateTo(0.0, duration: Duration.zero);
      // tracks.add(tracks.removeAt(0));
    });
    if ((sPrevOffset - sOffset).abs() > actuationOffset) HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final currentMusic = context.watch<CurrentMusicProvider>();

    return WillPopScope(
      onWillPop: () async {
        if (offset > maxOffset) {
          snapToExpanded();
          return false;
        }
        if (offset > maxOffset / 2) {
          snapToMini();
          return false;
        }
        return true;
      },
      child: Listener(
        onPointerDown: (event) {
          if (event.position.dy > screenSize.height - deadSpace) return;

          velocity.addPosition(event.timeStamp, event.position);

          prevOffset = offset;

          bounceUp = false;
          bounceDown = false;
        },
        onPointerMove: (event) {
          if (event.position.dy > screenSize.height - deadSpace) return;

          velocity.addPosition(event.timeStamp, event.position);

          if (offset <= maxOffset) return;
          if (scrollController.positions.isNotEmpty && scrollController.positions.first.pixels > 0.0 && offset >= maxOffset * 2) return;

          offset -= event.delta.dy;
          offset = offset.clamp(-headRoom, maxOffset * 2);

          widget.animation.animateTo(offset / maxOffset, duration: Duration.zero);

          setState(() => queueScrollable = offset >= maxOffset * 2);
        },
        onPointerUp: (event) {
          if (offset <= maxOffset) return;
          if (scrollController.positions.isNotEmpty && scrollController.positions.first.pixels > 0.0 && offset >= maxOffset * 2) return;

          setState(() => queueScrollable = true);
          verticalSnapping();
        },
        child: GestureDetector(
          /// Tap
          onTap: () {
            if (widget.animation.value < (actuationOffset / maxOffset)) {
              snapToExpanded();
            }
          },

          /// Vertical
          onVerticalDragUpdate: (details) {
            if (details.globalPosition.dy > screenSize.height - deadSpace) return;
            if (offset > maxOffset) return;

            offset -= details.primaryDelta ?? 0;
            offset = offset.clamp(-headRoom, maxOffset * 2 + headRoom / 2);

            widget.animation.animateTo(offset / maxOffset, duration: Duration.zero);
          },
          onVerticalDragEnd: (_) => verticalSnapping(),

          /// Horizontal
          onHorizontalDragStart: (details) {
            return;
            if (offset > maxOffset) return;

            sPrevOffset = sOffset;
          },
          onHorizontalDragUpdate: (details) {
            return;
            if (offset > maxOffset) return;
            if (details.globalPosition.dy > screenSize.height - deadSpace) return;

            sOffset -= details.primaryDelta ?? 0.0;
            sOffset = sOffset.clamp(-sMaxOffset, sMaxOffset);

            sAnim.animateTo(sOffset / sMaxOffset, duration: Duration.zero);
          },
          onHorizontalDragEnd: (details) {
            return;
            if (offset > maxOffset) return;

            final distance = sPrevOffset - sOffset;
            final speed = velocity.getVelocity().pixelsPerSecond.dx;
            const threshold = 1000.0;

            // speed threshold is an eyeballed value
            // used to actuate on fast flicks too

            if (speed > threshold || distance > actuationOffset * sActuationMulti) {
              snapToPrev();
            } else if (-speed > threshold || -distance > actuationOffset * sActuationMulti) {
              snapToNext();
            } else {
              snapToCurrent();
            }
          },

          // Child
          child: AnimatedBuilder(
            animation: widget.animation,
            builder: (context, child) {
              final Color onSecondary = Theme.of(context).colorScheme.onSecondaryContainer;

              final double p = widget.animation.value;
              final double cp = p.clamp(0, 1);
              final double ip = 1 - p;
              final double icp = 1 - cp;

              final double rp = inverseAboveOne(p);
              final double rcp = rp.clamp(0, 1);
              // final double rip = 1 - rp;
              // final double ricp = 1 - rcp;

              final double qp = p.clamp(1.0, 3.0) - 1.0;
              final double qcp = qp.clamp(0.0, 1.0);

              // print(1.0 - (p.clamp(1, 3) - 1));

              final double bp = !bounceUp
                  ? !bounceDown
                      ? rp
                      : 1 - (p - 1)
                  : p;
              final double bcp = bp.clamp(0.0, 1.0);

              final BorderRadius borderRadius = BorderRadius.only(
                topLeft: Radius.circular(24.0 + 6.0 * p),
                topRight: Radius.circular(24.0 + 6.0 * p),
                bottomLeft: Radius.circular(24.0 * (1 - p * 10 + 9).clamp(0, 1)),
                bottomRight: Radius.circular(24.0 * (1 - p * 10 + 9).clamp(0, 1)),
              );
              final double bottomOffset = (-96 * icp + p.clamp(-1, 0) * -200);
              final double opacity = (bcp * 5 - 4).clamp(0, 1);
              final double fastOpacity = (bcp * 10 - 9).clamp(0, 1);
              double panelHeight = maxOffset / 1.6;
              if (p > 1.0) {
                panelHeight = vp(a: panelHeight, b: maxOffset / 1.6 - 100.0 - topInset, c: qcp);
              }

              final double queueOpacity = ((p.clamp(1.0, 3.0) - 1).clamp(0.0, 1.0) * 4 - 3).clamp(0, 1);
              final double queueOffset = qp;

              return Stack(
                children: [
                  /// Player Body
                  Container(
                    color: p > 0 ? Colors.transparent : null, // hit test only when expanded
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Transform.translate(
                        offset: Offset(0, bottomOffset),
                        child: Container(
                          color: Colors.transparent, // prevents scrolling gap
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12 * (1 - cp * 10 + 9).clamp(0, 1), vertical: 12 * icp),
                            child: Container(
                              height: vp(a: 82.0, b: panelHeight, c: p.clamp(0, 3)),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: borderRadius,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(.15 * cp),
                                    blurRadius: 32.0,
                                  )
                                ],
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  // color: Theme.of(context).colorScheme.onSecondary,
                                  borderRadius: borderRadius,
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Theme.of(context).colorScheme.onSecondary.withOpacity(vp(a: .77, b: .9, c: icp)),
                                      Theme.of(context).colorScheme.onSecondary.withOpacity(vp(a: .5, b: .9, c: icp)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  /// Top Row
                  //! A bug causes performance issues when pressing the icon buttons multiple times
                  if (rcp > 0.0)
                    Material(
                      type: MaterialType.transparency,
                      child: Opacity(
                        opacity: rcp,
                        child: Transform.translate(
                          offset: Offset(0, (1 - bp) * -100),
                          child: SafeArea(
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      snapToMini();
                                    },
                                    icon: Icon(Icons.expand_more, color: onSecondary),
                                    iconSize: 32.0,
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "Playing from",
                                        style: TextStyle(
                                          color: onSecondary.withOpacity(.8),
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        currentMusic.playing?.album?.name ?? "?",
                                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20.0, color: onSecondary.withOpacity(.9)),
                                      ),
                                    ],
                                  ),
                                  IconButton(
                                    onPressed: () {},
                                    icon: Icon(Icons.more_vert, color: onSecondary),
                                    iconSize: 26.0,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  /// Slider
                  if (fastOpacity > 0.0)
                    Opacity(
                      opacity: fastOpacity,
                      child: Transform.translate(
                        offset: Offset(0, bottomOffset + (-maxOffset / 4.4 * p)),
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(
                                height: 65.0,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                                  child: WaveformSlider(),
                                ),
                              ),
                              StreamBuilder(
                                stream: currentMusic.player.positionStream,
                                builder: (context, snapshot) => Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(currentMusic.player.position.shortFormat(), style: TextStyle(color: onSecondary)),
                                      Text(currentMusic.player.duration?.shortFormat() ?? "??:??", style: TextStyle(color: onSecondary)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Align(
                  //   alignment: Alignment.topLeft,
                  //   child: SafeArea(
                  //     child: Container(
                  //       color: Colors.red,
                  //       height: 100.0,
                  //       width: double.infinity,
                  //     ),
                  //   ),
                  // ),

                  /// Controls
                  //! A bug causes performance issues when pressing the icon buttons multiple times
                  Material(
                    type: MaterialType.transparency,
                    child: Transform.translate(
                      offset: Offset(
                          0,
                          bottomOffset +
                              (-maxOffset / 7.5 * bp) +
                              ((-maxOffset + topInset + 80.0) *
                                  (!bounceUp
                                      ? !bounceDown
                                          ? qp
                                          : (1 - bp)
                                      : 0.0))),
                      child: Padding(
                        padding: EdgeInsets.all(12.0 * icp),
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: Stack(
                            alignment: Alignment.centerRight,
                            children: [
                              if (fastOpacity > 0.0)
                                Opacity(
                                  opacity: fastOpacity,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 24.0 * (16 * (!bounceDown ? icp : 0.0) + 1)),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        IconButton(
                                          iconSize: 28.0,
                                          icon: Icon(Icons.shuffle, color: onSecondary),
                                          onPressed: () {},
                                        ),
                                        IconButton(
                                          iconSize: 28.0,
                                          icon: Icon(Icons.repeat, color: onSecondary),
                                          onPressed: () {},
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              if (fastOpacity > 0.0)
                                Opacity(
                                  opacity: fastOpacity,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 84.0 * (2 * (!bounceDown ? icp : 0.0) + 1)),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        IconButton(
                                          iconSize: 40.0,
                                          icon: Icon(Icons.skip_previous, color: onSecondary),
                                          onPressed: snapToPrev,
                                        ),
                                        IconButton(
                                          iconSize: 40.0,
                                          icon: Icon(Icons.skip_next, color: onSecondary),
                                          onPressed: snapToNext,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              Padding(
                                padding: EdgeInsets.all(12.0 * icp).add(EdgeInsets.only(
                                    right: !bounceDown
                                        ? !bounceUp
                                            ? screenSize.width * rcp / 2 - 80 * rcp / 2 + (qp * 24.0)
                                            : screenSize.width * cp / 2 - 80 * cp / 2
                                        : screenSize.width * bcp / 2 - 80 * bcp / 2 + (qp * 24.0))),
                                child: Theme(
                                  data: Theme.of(context).copyWith(
                                    floatingActionButtonTheme: FloatingActionButtonThemeData(
                                      sizeConstraints: BoxConstraints.tight(Size.square(vp(a: 60.0, b: 80.0, c: rp))),
                                      iconSize: vp(a: 32.0, b: 46.0, c: rp),
                                    ),
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    child: MultiProvider(
                                      providers: [
                                        StreamProvider(create: (_) => currentMusic.player.positionStream, initialData: currentMusic.player.position),
                                        StreamProvider(create: (_) => currentMusic.player.playingStream, initialData: currentMusic.player.playing),
                                      ],
                                      builder: (context, snapshot) => Consumer2<bool, Duration>(
                                        builder: (context, value1, value2, child) => CustomPaint(
                                          painter: MiniplayerProgressPainter(currentMusic.progress * (1 - rcp)),
                                          child: FloatingActionButton(
                                            onPressed: () {
                                              if (currentMusic.player.playing) {
                                                currentMusic.player.pause();
                                              } else {
                                                currentMusic.player.play();
                                              }
                                            },
                                            elevation: 0,
                                            backgroundColor: Theme.of(context).colorScheme.surfaceTint.withOpacity(.3),
                                            child: Icon(value1 ? Icons.pause : Icons.play_arrow),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  /// Destination selector
                  if (opacity > 0.0)
                    Opacity(
                      opacity: opacity,
                      child: Transform.translate(
                        offset: Offset(0, -100 * ip),
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: SafeArea(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                              child: TextButton(
                                onPressed: () {},
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6.0),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.secondaryContainer,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(Icons.headphones, size: 18.0, color: onSecondary),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 14.0),
                                      child: Text('Headphones', style: TextStyle(color: onSecondary)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  /// Lyrics button
                  if (opacity > 0.0)
                    Material(
                      type: MaterialType.transparency,
                      child: Opacity(
                        opacity: opacity,
                        child: Transform.translate(
                          offset: Offset(-46, -100 * ip),
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: SafeArea(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                                child: IconButton(
                                  onPressed: () {
                                    final track = context.read<CurrentMusicProvider>().playing!;
                                    LyricsView.view(track, context: context);
                                  },
                                  icon: Icon(Icons.format_quote, size: 24.0, color: Theme.of(context).colorScheme.onSecondaryContainer),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  /// Queue button
                  if (opacity > 0.0)
                    Material(
                      type: MaterialType.transparency,
                      child: Opacity(
                        opacity: opacity,
                        child: Transform.translate(
                          offset: Offset(0, -100 * ip),
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: SafeArea(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                                child: IconButton(
                                  onPressed: () {},
                                  icon: Icon(Icons.queue_music, size: 24.0, color: Theme.of(context).colorScheme.onSecondaryContainer),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  /// Track Info
                  Material(
                    type: MaterialType.transparency,
                    child: AnimatedBuilder(
                      animation: sAnim,
                      builder: (context, child) {
                        return Stack(
                          children: [
                            // Opacity(
                            //   opacity: -sAnim.value.clamp(-1.0, 0.0),
                            //   child: Transform.translate(
                            //     offset: Offset(-sAnim.value * sMaxOffset / stParallax - sMaxOffset / stParallax, 0),
                            //     child: TrackInfo(
                            //         artist: tracks[0].artists.map((e) => e.name).join(", "),
                            //         title: tracks[0].name,
                            //         cp: cp,
                            //         p: p,
                            //         bottomOffset: bottomOffset,
                            //         maxOffset: maxOffset,
                            //         screenSize: screenSize),
                            //   ),
                            // ),
                            Opacity(
                              opacity: 1 - sAnim.value.abs(),
                              child: Transform.translate(
                                offset: Offset(
                                    -sAnim.value * sMaxOffset / stParallax + (12.0 * qp),
                                    (-maxOffset + topInset + 102.0) *
                                        (!bounceUp
                                            ? !bounceDown
                                                ? qp
                                                : (1 - bp)
                                            : 0.0)),
                                child: TrackInfo(
                                    artist: currentMusic.playing?.artists.map((e) => e.name).join(", ") ?? "?",
                                    title: currentMusic.playing?.name ?? "",
                                    p: bp,
                                    cp: bcp,
                                    bottomOffset: bottomOffset,
                                    maxOffset: maxOffset,
                                    screenSize: screenSize),
                              ),
                            ),
                            // Opacity(
                            //   opacity: sAnim.value.clamp(0.0, 1.0),
                            //   child: Transform.translate(
                            //     offset: Offset(-sAnim.value * sMaxOffset / stParallax + sMaxOffset / stParallax, 0),
                            //     child: TrackInfo(
                            //         artist: tracks[2].artists.map((e) => e.name).join(", "),
                            //         title: tracks[2].name,
                            //         cp: cp,
                            //         p: p,
                            //         bottomOffset: bottomOffset,
                            //         maxOffset: maxOffset,
                            //         screenSize: screenSize),
                            //   ),
                            // ),
                          ],
                        );
                      },
                    ),
                  ),

                  /// Track Image
                  AnimatedBuilder(
                    animation: sAnim,
                    builder: (context, child) {
                      return Stack(
                        children: [
                          // Opacity(
                          //   opacity: -sAnim.value.clamp(-1.0, 0.0),
                          //   child: Transform.translate(
                          //     offset: Offset(-sAnim.value * sMaxOffset / siParallax - sMaxOffset / siParallax, 0),
                          //     child: TrackImage(
                          //       image: tracks[0].album?.images!.maxSize,
                          //       large: true,
                          //       p: p,
                          //       cp: cp,
                          //       screenSize: screenSize,
                          //       bottomOffset: bottomOffset,
                          //       maxOffset: maxOffset,
                          //     ),
                          //   ),
                          // ),
                          Opacity(
                            opacity: 1 - sAnim.value.abs(),
                            child: Transform.translate(
                              offset: Offset(-sAnim.value * sMaxOffset / siParallax,
                                  !bounceUp ? (-maxOffset + topInset + 108.0) * (!bounceDown ? qp : (1 - bp)) : 0.0),
                              child: TrackImage(
                                images: currentMusic.playing?.album?.images,
                                p: bp,
                                cp: bcp,
                                width: vp(a: 82.0, b: 92.0, c: qp),
                                screenSize: screenSize,
                                bottomOffset: bottomOffset,
                                maxOffset: maxOffset,
                              ),
                            ),
                          ),
                          // Opacity(
                          //   opacity: sAnim.value.clamp(0.0, 1.0),
                          //   child: Transform.translate(
                          //     offset: Offset(-sAnim.value * sMaxOffset / siParallax + sMaxOffset / siParallax, 0),
                          //     child: TrackImage(
                          //       image: tracks[2].album?.images!.maxSize,
                          //       large: true,
                          //       p: p,
                          //       cp: cp,
                          //       screenSize: screenSize,
                          //       bottomOffset: bottomOffset,
                          //       maxOffset: maxOffset,
                          //     ),
                          //   ),
                          // ),
                        ],
                      );
                    },
                  ),

                  if (queueOpacity > 0.0)
                    Opacity(
                      opacity: queueOpacity,
                      child: Transform.translate(
                        offset: Offset(0, (1 - queueOffset) * maxOffset),
                        child: IgnorePointer(
                          ignoring: !queueScrollable,
                          child: QueueView(controller: scrollController),
                        ),
                      ),
                    ),

                  // Container(
                  //   color: Colors.red,
                  //   width: 100.0 * bp + 100,
                  //   height: 100.0 * bp + 100,
                  // ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class MiniplayerProgressPainter extends CustomPainter {
  MiniplayerProgressPainter(this.progress);

  final double progress;
  final strokeWidth = 4.0;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawDRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(16.0),
      ),
      RRect.fromRectAndRadius(
        Rect.fromLTWH(strokeWidth, strokeWidth, size.width - strokeWidth * 2, size.height - strokeWidth * 2),
        const Radius.circular(12.0),
      ),
      Paint()..color = Colors.white.withOpacity(.25),
    );
    canvas.saveLayer(Rect.fromLTWH(-10, -10, size.width + 20, size.height + 20), Paint());
    canvas.drawArc(
      Rect.fromLTWH(-10, -10, size.width + 20, size.height + 20),
      -1.570796,
      6.283185 * (1 - progress) * -1,
      true,
      Paint()..color = Colors.black,
    );
    canvas.drawDRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-10, -10, size.width + 20, size.height + 20),
        const Radius.circular(0.0),
      ),
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(16.0),
      ),
      Paint()..blendMode = BlendMode.clear,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
