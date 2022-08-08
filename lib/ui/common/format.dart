extension DurationFormat on Duration {
  String format() {
    return "${inHours > 0 ? '$inHours h ' : ''}${inMinutes % 60} mins";
  }

  String shortFormat() {
    return "${inHours > 0 ? '$inHours:' : ''}${(inMinutes % 60).toString().padLeft(2, '0')}:${(inSeconds % 60).toString().padLeft(2, '0')}";
  }
}
