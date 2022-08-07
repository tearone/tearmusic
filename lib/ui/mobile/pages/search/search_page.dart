import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tearmusic/models/music/search_results.dart';
import 'package:tearmusic/providers/music_info_provider.dart';
import 'package:tearmusic/ui/mobile/common/search_track.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchInputController = TextEditingController();

  SearchResults? results;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          onSubmitted: (value) async {
            results = await context.read<MusicInfoProvider>().search(value);
            setState(() {});
          },
          controller: _searchInputController,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            hintText: "Search...",
            border: UnderlineInputBorder(
              borderSide: BorderSide.none,
            ),
          ),
        ),
        if (results != null)
          Expanded(
            child: ListView.builder(
              itemCount: (results?.tracks.length ?? 0) + 1,
              itemBuilder: (context, index) {
                if (index == results!.tracks.length) {
                  return const SizedBox(height: 200);
                }

                return SearchTrack(results!.tracks[index]);
              },
            ),
          )
      ],
    );
  }
}
