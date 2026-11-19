# staggered-ui

Staggered entrance animations for Flutter lists, with the per-row delay clamped
so long lists stay snappy instead of animating for seconds.

![demo placeholder](https://bdncg76374.github.io/staggered-ui/demo.gif)

## Why

Wrapping `ListView.builder` in a single `AnimationController` is easy; getting
the timing right is not. Naive `Future.delayed` chains drift, fire after the
widget is disposed, and make 200-row feeds feel sluggish. `staggered-ui` keeps
the sequence on one controller, caps the accumulated delay, and exposes the
math as a pure value object so it can be unit tested.

## Install

```yaml
dependencies:
  staggered_ui:
    git:
      url: https://github.com/bdncg76374/staggered-ui.git
      ref: main
```

Requires Flutter 3.19 or newer (Material 3 era, `View`-based `MediaQuery`).

## Usage

```dart
import 'package:staggered_ui/staggered_ui.dart';

final timing = StaggerTiming(
  itemCount: items.length,
  itemDuration: const Duration(milliseconds: 220),
  step: const Duration(milliseconds: 40),
  maxStagger: const Duration(milliseconds: 480),
);

StaggeredListView(
  timing: timing,
  itemCount: items.length,
  padding: const EdgeInsets.all(16),
  itemBuilder: (context, index, animation) => Card(
    child: FadeTransition(
      opacity: animation,
      child: ListTile(title: Text(items[index].title)),
    ),
  ),
);
```

The builder receives the row's own `animation`, so you can drive anything with
it — the built-in fade and slide are applied for you unless `translate: false`.
`replay()` on a `GlobalKey<StaggeredListViewState>` restarts the sequence, for
pull-to-refresh and "load more" affordances.

## API

| Symbol | Purpose |
| --- | --- |
| `StaggerTiming` | Delay, duration and curve per row; `delayFor`, `intervalFor`, `totalDuration`. |
| `StaggeredListView` | `ListView.builder` wrapper that fades and slides rows in. |
| `StaggeredListViewState.replay()` | Restarts the entrance. |

`delayFor` saturates at `maxStagger`, so rows past
`1 + maxStagger / step` share the same start time.

## Platform notes

- iOS and Android behave identically; the slide offset is a fraction of the row
  height, not a device pixel value, so text scaling does not skew it.
- Web works, but expect a frame of jank on first paint for lists over ~100 rows;
  keep `maxStagger` low there.
- Rows animate once per controller run. Scrolling far and back does not replay
  early rows because the controller has already completed.

## Layout

```
lib/staggered_ui.dart          barrel export
lib/src/stagger.dart           pure timing math, unit tested
lib/src/staggered_list_view.dart  widget + controller lifecycle
test/stagger_test.dart         clamp and interval bounds
```

## License

MIT, see [LICENSE](LICENSE).
