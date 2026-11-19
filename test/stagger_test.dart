import 'package:flutter/animation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staggered_ui/staggered_ui.dart';

StaggerTiming timing({
  int itemCount = 10,
  Duration step = const Duration(milliseconds: 40),
  Duration maxStagger = const Duration(milliseconds: 200),
}) =>
    StaggerTiming(
      itemCount: itemCount,
      itemDuration: const Duration(milliseconds: 220),
      step: step,
      maxStagger: maxStagger,
    );

void main() {
  group('delayFor', () {
    test('grows linearly before the clamp', () {
      expect(timing().delayFor(0), Duration.zero);
      expect(timing().delayFor(3), const Duration(milliseconds: 120));
    });

    test('saturates at maxStagger', () {
      expect(timing().delayFor(5), const Duration(milliseconds: 200));
      expect(timing().delayFor(9), const Duration(milliseconds: 200));
    });
  });

  test('totalDuration ends with the last row', () {
    expect(
      timing(itemCount: 3).totalDuration,
      const Duration(milliseconds: 80 + 220),
    );
  });

  test('intervals stay ordered and inside the controller range', () {
    final sequence = timing();
    var previousEnd = -1.0;
    for (var index = 0; index < sequence.itemCount; index++) {
      final interval = sequence.intervalFor(index);
      expect(interval.begin, greaterThanOrEqualTo(previousEnd));
      expect(interval.end, lessThanOrEqualTo(1.0));
      expect(interval.curve, Curves.easeOutCubic);
      previousEnd = interval.begin;
    }
  });

  test('single row fills the whole sequence', () {
    final interval = timing(itemCount: 1).intervalFor(0);
    expect(interval.begin, 0);
    expect(interval.end, 1);
  });
}
