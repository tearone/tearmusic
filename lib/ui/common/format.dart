extension DurationFormat on Duration {
  String format() {
    return "${inHours > 0 ? '$inHours h ' : ''}${inMinutes % 60} mins";
  }
}
