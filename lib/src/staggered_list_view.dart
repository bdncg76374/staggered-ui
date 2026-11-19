import 'package:flutter/widgets.dart';

import 'stagger.dart';

/// Builds the child for one row, driven by that row's own [animation].
typedef StaggeredItemBuilder = Widget Function(
  BuildContext context,
  int index,
  Animation<double> animation,
);

/// A [ListView] whose rows fade and slide in one after another.
///
/// Only the entrance is staggered: scrolling, physics and item recycling stay
/// stock [ListView] behaviour.
class StaggeredListView extends StatefulWidget {
  const StaggeredListView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.timing,
    this.scrollDirection = Axis.vertical,
    this.padding = EdgeInsets.zero,
    this.controller,
    this.translate = true,
  });

  final int itemCount;
  final StaggeredItemBuilder itemBuilder;
  final StaggerTiming timing;
  final Axis scrollDirection;
  final EdgeInsetsGeometry padding;
  final ScrollController? controller;

  /// When false, rows only fade.
  final bool translate;

  @override
  State<StaggeredListView> createState() => StaggeredListViewState();
}

class StaggeredListViewState extends State<StaggeredListView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late StaggerTiming _timing;

  @override
  void initState() {
    super.initState();
    _timing = widget.timing;
    _controller = AnimationController(vsync: this, duration: _timing.totalDuration)
      ..forward();
  }

  @override
  void didUpdateWidget(covariant StaggeredListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _timing = widget.timing;
    if (oldWidget.itemCount != widget.itemCount ||
        oldWidget.timing.totalDuration != widget.timing.totalDuration) {
      _controller
        ..duration = _timing.totalDuration
        ..forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Runs the entrance again from the first row.
  void replay() => _controller.forward(from: 0);

  Widget _animatedRow(BuildContext context, int index) {
    final animation =
        CurvedAnimation(parent: _controller, curve: _timing.intervalFor(index));
    final child = widget.itemBuilder(context, index, animation);
    if (!widget.translate) {
      return FadeTransition(opacity: animation, child: child);
    }
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.12),
        end: Offset.zero,
      ).animate(animation),
      child: FadeTransition(opacity: animation, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: widget.controller,
      scrollDirection: widget.scrollDirection,
      padding: widget.padding,
      itemCount: widget.itemCount,
      itemBuilder: _animatedRow,
    );
  }
}
