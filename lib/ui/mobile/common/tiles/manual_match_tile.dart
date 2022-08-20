import 'package:flutter/material.dart';
import 'package:tearmusic/models/manual_match.dart';
import 'package:tearmusic/ui/common/format.dart';

class ManualMatchTile extends StatelessWidget {
  const ManualMatchTile(this.match, {Key? key, this.onTap, this.selected = false}) : super(key: key);

  final ManualMatch match;
  final void Function()? onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      visualDensity: VisualDensity.compact,
      contentPadding: EdgeInsets.zero,
      leading: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4.0),
            child: SizedBox(
              height: 42.0,
              width: 42.0,
              child: Image.network(
                match.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          if (selected)
            Container(
              height: 42.0,
              width: 42.0,
              color: Colors.black.withOpacity(.5),
              child: const Center(
                child: Icon(Icons.check),
              ),
            ),
        ],
      ),
      title: Text(
        match.name,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: selected ? const TextStyle(fontWeight: FontWeight.bold) : null,
      ),
      subtitle: Text(
        match.artist,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(match.duration.shortFormat()),
      onTap: onTap,
    );
  }
}
