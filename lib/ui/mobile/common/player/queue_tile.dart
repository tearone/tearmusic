import 'package:flutter/material.dart';
import 'package:tearmusic/ui/mobile/common/player/image_placeholder.dart';

class QueueTile extends StatelessWidget {
  const QueueTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const ListTile(
      leading: AspectRatio(
        aspectRatio: 1,
        child: ImagePlaceholder(),
      ),
      title: Text("Music"),
      subtitle: Text("Artist"),
      trailing: Text("1:24"),
    );
  }
}
