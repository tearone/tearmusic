import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:tearmusic/models/manual_match.dart';
import 'package:tearmusic/models/music/track.dart';
import 'package:tearmusic/providers/current_music_provider.dart';
import 'package:tearmusic/providers/music_info_provider.dart';
import 'package:tearmusic/ui/mobile/common/tiles/manual_match_tile.dart';

class ManualMatchView extends StatefulWidget {
  const ManualMatchView(this.track, {Key? key}) : super(key: key);

  final MusicTrack track;

  static view(MusicTrack track, {required BuildContext context}) =>
      Navigator.of(context, rootNavigator: true).push(CupertinoDialogRoute(context: context, builder: (context) => ManualMatchView(track)));

  @override
  State<ManualMatchView> createState() => _ManualMatchViewState();
}

class _ManualMatchViewState extends State<ManualMatchView> {
  String? selected;

  @override
  void initState() {
    super.initState();
    context.read<CurrentMusicProvider>().pause();
  }

  Future<List<ManualMatch>> getMatches() async {
    return await context.read<MusicInfoProvider>().manualMatches(widget.track);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        "Wrong song?",
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      content: FutureBuilder<List<ManualMatch>>(
        future: getMatches(),
        builder: (context, snapshot) {
          List<Widget>? matches;

          if (snapshot.hasData) {
            matches = snapshot.data!.map((e) {
              return ManualMatchTile(
                e,
                selected: selected == e.videoId,
                onTap: () => setState(() => selected = e.videoId),
              );
            }).toList();
          }

          return SizedBox(
            height: MediaQuery.of(context).size.height / 2,
            width: 400,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 12.0),
                  child: Text("Try matching manually!"),
                ),
                if (!snapshot.hasData)
                  Expanded(
                    child: Center(
                      child: LoadingAnimationWidget.staggeredDotsWave(
                        color: Theme.of(context).colorScheme.secondary,
                        size: 42.0,
                      ),
                    ),
                  ),
                if (snapshot.hasData)
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: matches!,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
          },
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            // Foreground color
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            // Background color
            backgroundColor: Theme.of(context).colorScheme.primary,
          ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0)),
          onPressed: () async {
            if (selected != null) {
              final api = context.read<MusicInfoProvider>();
              await api.purgeCache(widget.track);
              await api.matchManual(widget.track, selected!);
              // ignore: use_build_context_synchronously
              Navigator.of(context, rootNavigator: true).pop();
            }
          },
          child: const Text("Submit"),
        ),
      ],
    );
  }
}
