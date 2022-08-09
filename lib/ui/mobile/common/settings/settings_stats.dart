import 'package:flutter/material.dart';

class SettingsStatsItem extends StatelessWidget {
  const SettingsStatsItem({
    Key? key,
    required this.name,
    required this.value,
  }) : super(key: key);

  final String value;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 0.0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
          child: Column(
            children: [
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18.0),
              ),
              Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.w300, fontSize: 11.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
