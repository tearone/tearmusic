class Model {
  final Map json;
  final String id;
  final String? key;

  Model({required this.json, required this.id, this.key});

  static List<String> encodeIdList(List<Model> models) => models.map((e) => "$e").toList();

  bool match(String filter) {
    if (key == null || filter == "") return false;
    filter = filter.toLowerCase();
    filter = SearchUtils.specialChars(filter);
    return filter.split(" ").every((variation) => SearchUtils.specialChars(key!.toLowerCase()).contains(variation));
  }

  @override
  bool operator ==(other) => other is Model && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => id;
}

class SearchUtils {
  static String specialChars(String s) => s
      .replaceAll("é", "e")
      .replaceAll("á", "a")
      .replaceAll("ó", "o")
      .replaceAll("ő", "o")
      .replaceAll("ö", "o")
      .replaceAll("ú", "u")
      .replaceAll("ű", "u")
      .replaceAll("ü", "u")
      .replaceAll("í", "i");
}
