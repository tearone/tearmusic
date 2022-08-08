import 'package:flutter/material.dart';

class TopResultContainer extends StatelessWidget {
  const TopResultContainer({
    Key? key,
    required this.results,
    required this.kind,
    required this.index,
    required this.tabController,
    required this.pageController,
  }) : super(key: key);

  final List<Widget> results;
  final String kind;
  final int index;
  final TabController tabController;
  final PageController pageController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Card(
        elevation: 3.0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "Top $kind",
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      tabController.animateTo(index);
                      pageController.animateToPage(index, curve: Curves.easeIn, duration: kTabScrollDuration);
                    },
                    child: const Text("Show All"),
                  )
                ],
              ),
            ),
            ...results,
          ],
        ),
      ),
    );
  }
}
