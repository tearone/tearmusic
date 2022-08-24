import 'package:automatic_animated_list/automatic_animated_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tearmusic/models/model.dart';
import 'package:tearmusic/ui/mobile/common/wallpaper.dart';

typedef ContentListViewBuilder = Widget? Function(ValueWidgetBuilder)?;
typedef ContentListViewItemBuilder<T> = Widget? Function(BuildContext, T);
typedef ContentListViewRetriever<T> = Future<List<T>>? Function();

class ContentListView<T extends Model> extends StatefulWidget {
  const ContentListView({
    Key? key,
    this.title,
    this.emptyTitle,
    required this.loadingWidget,
    required this.itemBuilder,
    required this.retriever,
    this.builder,
  }) : super(key: key);

  final Widget? title;
  final Widget? emptyTitle;
  final Widget loadingWidget;
  final ContentListViewItemBuilder<T> itemBuilder;
  final ContentListViewRetriever<T> retriever;
  final ContentListViewBuilder builder;

  @override
  State<ContentListView<T>> createState() => _ContentListViewState<T>();
}

class _ContentListViewState<T extends Model> extends State<ContentListView<T>> {
  Widget itemBuilder<U>(BuildContext context, U? value, Widget? child) {
    if ((value as List?)?.isEmpty ?? false) {
      return Padding(
        padding: const EdgeInsets.only(top: 6.0, bottom: 24.0),
        child: Center(
          child: widget.emptyTitle,
        ),
      );
    }

    return FutureBuilder<List<T>>(
      future: widget.retriever(),
      builder: ((context, snapshot) {
        if (!snapshot.hasData) {
          return widget.loadingWidget;
        }

        final List<T> items = snapshot.data!;

        return AutomaticAnimatedList<T>(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          items: items,
          keyingFunction: (item) => Key(item.id),
          itemBuilder: (BuildContext context, T item, Animation<double> animation) {
            return FadeTransition(
              key: Key(item.id),
              opacity: animation,
              child: SizeTransition(
                sizeFactor: CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOut,
                  reverseCurve: Curves.easeIn,
                ),
                child: widget.itemBuilder(context, item),
              ),
            );
          },
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Wallpaper(
        gradient: false,
        child: CupertinoScrollbar(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: false,
                pinned: true,
                snap: false,
                title: widget.title,
              ),
              SliverToBoxAdapter(
                child: widget.builder != null ? widget.builder!(itemBuilder) : itemBuilder(context, null, null),
              ),
              const SliverToBoxAdapter(
                child: SafeArea(
                  top: false,
                  child: SizedBox(
                    height: 200,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
