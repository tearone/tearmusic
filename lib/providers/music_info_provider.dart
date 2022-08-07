import 'package:tearmusic/api/base_api.dart';
import 'package:tearmusic/api/music_api.dart';
import 'package:tearmusic/models/music/search_results.dart';

class MusicInfoProvider {
  MusicInfoProvider({required BaseApi base}) : _api = MusicApi(base: base);

  final MusicApi _api;

  Future<SearchResults> search(String query) async {
    return await _api.search(query);
  }
}
