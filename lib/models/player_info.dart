class PlayerInfo {
  List<String> normalQueue;
  List<String> primaryQueue;
  List<QueueHistory> queueHistory;
  List<Map> operations;
  int version;

  PlayerInfo({
    this.normalQueue = const [],
    this.primaryQueue = const [],
    this.queueHistory = const [],
    this.operations = const [],
    required this.version,
  });

  // ik server response dont include operations field, but db save may include.
  factory PlayerInfo.decode(Map json) {
    return PlayerInfo(
      normalQueue: json["normal_queue"],
      primaryQueue: json["primary_queue"],
      queueHistory: (json["queue_history"] as List).map((e) => QueueHistory.decode(e)).toList(),
      version: json["version"],
      operations: json["operations"] ?? [],
    );
  }

  Map encode() {
    return {
      "normal_queue": normalQueue,
      "primary_queue": primaryQueue,
      "queue_history": queueHistory.map((e) => e.encode()),
      "version": version,
      "operations": operations,
    };
  }
}

enum PlayerInfoPostType { primary, normal, history }
enum PlayerInfoReorderMoveType { primary, normal }

class QueueHistory {
  String id;
  bool fromPrimary;

  QueueHistory({required this.id, required this.fromPrimary});

  factory QueueHistory.decode(Map json) {
    return QueueHistory(id: json["id"], fromPrimary: json["fromPrimary"]);
  }

  Map encode() => {
        "id": id,
        "fromPrimary": fromPrimary,
      };
}
