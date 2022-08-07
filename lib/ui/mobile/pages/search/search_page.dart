import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    return const TextField(
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: "Search...",
        border: UnderlineInputBorder(
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
