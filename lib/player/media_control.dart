import 'package:audio_service/audio_service.dart';

class TMMediaControl {
  static const play = MediaControl(
    action: MediaAction.play,
    label: "Play",
    androidIcon: "mipmap/ic_action_play",
  );
  static const pause = MediaControl(
    action: MediaAction.pause,
    label: "Pause",
    androidIcon: "mipmap/ic_action_pause",
  );

  static const skipForward = MediaControl(
    action: MediaAction.skipToNext,
    label: "Skip Forward",
    androidIcon: "mipmap/ic_action_skip_forward",
  );
  static const skipBack = MediaControl(
    action: MediaAction.skipToPrevious,
    label: "Skip Back",
    androidIcon: "mipmap/ic_action_skip_back",
  );

  static const heart = MediaControl(
    action: MediaAction.setRating,
    label: "Like",
    androidIcon: "mipmap/ic_action_heart",
  );
  static const unheart = MediaControl(
    action: MediaAction.setRating,
    label: "Unlike",
    androidIcon: "mipmap/ic_action_unheart",
  );
}
