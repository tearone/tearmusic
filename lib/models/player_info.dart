class PlayerInfo {
  QueueItem? currentMusic;
  QueueSource queueSource;
  List<String> normalQueue;
  List<String> primaryQueue;
  List<QueueItem> queueHistory;
  List<Map> operations;
  int version;
  late int operationsVersion; // start version of the operations

  PlayerInfo({
    List<Map>? operations,
    List<String>? normalQueue,
    List<String>? primaryQueue,
    List<QueueItem>? queueHistory,
    this.operationsVersion = 0,
    this.currentMusic,
    required this.queueSource,
    required this.version,
  })  : operations = List.from(operations ?? []),
        normalQueue = List.from(normalQueue ?? []),
        primaryQueue = List.from(primaryQueue ?? []),
        queueHistory = List.from(queueHistory ?? []);

  // ik server response dont include operations field, but db save may include.
  factory PlayerInfo.decode(Map json) {
    return PlayerInfo(
      normalQueue: (json["normal_queue"] as List).cast<String>(),
      primaryQueue: (json["primary_queue"] as List).cast<String>(),
      queueHistory: (json["queue_history"] as List).map((e) => QueueItem.decode(e)).toList(),
      version: json["version"] ?? 0,
      operations: ((json["operations"] ?? []) as List).cast<Map>().toList(),
      operationsVersion: json["operations_version"] ?? 0,
      currentMusic: json["current_music"] != null ? QueueItem.decode(json["current_music"]) : null,
      queueSource: QueueSource.decode(json["queue_source"]),
    );
  }

  Map encode() {
    return {
      "normal_queue": normalQueue,
      "primary_queue": primaryQueue,
      "queue_history": queueHistory.map((e) => e.encode()).toList(),
      "version": version,
      "operations": operations,
      "operations_version": operationsVersion,
      "current_music": currentMusic?.encode(),
      "queue_source": queueSource.encode(),
    };
  }
}

enum PlayerInfoPostType { primary, normal, history, current }

enum PlayerInfoReorderMoveType { primary, normal }

enum PlayerInfoSourceType { playlist, album, artist, radio }

class QueueSource {
  int? seed;
  String? id;
  int? index;
  PlayerInfoSourceType type;

  final types = {
    'playlist': PlayerInfoSourceType.playlist,
    'album': PlayerInfoSourceType.album,
    'artist': PlayerInfoSourceType.artist,
    'radio': PlayerInfoSourceType.radio,
  };

  QueueSource({
    this.seed,
    this.id,
    this.index,
    required this.type,
  });

  factory QueueSource.decode(Map json) {
    return QueueSource(
      seed: json["seed"],
      id: json["id"],
      index: json["index"],
      type: PlayerInfoSourceType.values.firstWhere((element) => element.name == json["type"]),
    );
  }

  Map encode() => {
        "seed": seed,
        "id": id,
        "index": index,
        "type": type.name,
      };
}

class QueueItem {
  String id;
  bool fromPrimary;

  QueueItem({required this.id, required this.fromPrimary});

  factory QueueItem.decode(Map json) {
    return QueueItem(id: json["id"], fromPrimary: json["fromPrimary"]);
  }

  Map encode() => {
        "id": id,
        "fromPrimary": fromPrimary,
      };
}
