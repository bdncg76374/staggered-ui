import 'dart:math' as math;

import 'package:flutter/animation.dart';

/// Timing description for one staggered entrance sequence.
///
/// Every visible item waits [step] * index before it starts, but the wait is
/// clamped to [maxStagger] so a list with 200 rows does not animate for
/// seconds. Build it once per list and hand it to a `StaggeredListView`.
@immutable
class StaggerTiming {
  const StaggerTiming({
    required this.itemCount,
    required this.itemDuration,
    required this.step,
    this.maxStagger = const Duration(milliseconds: 600),
    this.curve = Curves.easeOutCubic,
  })  : assert(itemCount > 0, 'itemCount must be at least 1'),
        assert(maxStagger > Duration.zero, 'maxStagger must be positive');

  /// Number of rows in the list.
  final int itemCount;

  /// How long a single row takes once its delay has elapsed.
  final Duration itemDuration;

  /// Delay added per row index before the clamp applies.
  final Duration step;

  /// Upper bound for the accumulated delay.
  final Duration maxStagger;

  /// Curve applied to the fade and slide of each row.
  final Curve curve;

  /// Rows past the clamp all start together.
  int get _staggeredRows =>
      math.min(itemCount, 1 + maxStagger.inMicroseconds ~/ step.inMicroseconds);

  /// Delay before row [index] starts animating.
  Duration delayFor(int index) => Duration(
        microseconds:
            math.min(index, _staggeredRows - 1) * step.inMicroseconds,
      );

  /// Wall clock length of the whole sequence, last row included.
  Duration get totalDuration => delayFor(itemCount - 1) + itemDuration;

  /// The [Interval] of row [index] inside [totalDuration].
  Interval intervalFor(int index) {
    final total = totalDuration.inMicroseconds;
    final begin = delayFor(index).inMicroseconds / total;
    final end = math.min(1.0, begin + itemDuration.inMicroseconds / total);
    return Interval(begin, end, curve: curve);
  }
}
