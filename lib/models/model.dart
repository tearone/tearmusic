class Model {
  final String id;
  final Map json;

  Model({required this.json, required this.id});

  static List<String> encodeIdList(List<Model> models) => models.map((e) => "$e").toList();

  @override
  bool operator ==(other) => other is Model && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => id;
}
