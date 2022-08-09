import 'package:flutter/material.dart';

class SettingsSwitchTile extends StatelessWidget {
  SettingsSwitchTile({
    Key? key,
    required this.name,
    required this.desc,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  final String name;
  final String desc;
  bool value;
  final Function(bool) onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0, bottom: 6.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 15.0),
                  ),
                  Text(
                    desc,
                    style: const TextStyle(fontWeight: FontWeight.w300, fontSize: 13.0, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
