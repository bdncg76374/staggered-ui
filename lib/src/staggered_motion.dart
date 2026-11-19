import 'package:flutter/widgets.dart';

/// Resolves whether an entrance sequence should run, based on platform
/// accessibility settings.
///
/// `MediaQuery.disableAnimations` (Android "Remove animations", iOS
/// "Reduce Motion", desktop equivalents) is honoured automatically by
/// [StaggeredListView]; nothing needs to be passed in by the caller.
@immutable
class StaggeredMotion {
  const StaggeredMotion._({required this.enabled, required this.translate});

  /// Sequence runs, rows fade and slide.
  static const StaggeredMotion full =
      StaggeredMotion._(enabled: true, translate: true);

  /// Sequence is skipped, rows are laid out at their final position.
  static const StaggeredMotion reduced =
      StaggeredMotion._(enabled: false, translate: false);

  /// Whether the controller should animate at all.
  final bool enabled;

  /// Whether rows may slide, as opposed to plain fades.
  final bool translate;

  /// Reads the closest [MediaQuery]; defaults to [full] without one
  /// (for example inside a bare `WidgetsApp` preview).
  static StaggeredMotion of(BuildContext context) {
    final query = MediaQuery.maybeOf(context);
    if (query != null && query.disableAnimations) {
      return reduced;
    }
    return full;
  }

  @override
  bool operator ==(Object other) =>
      other is StaggeredMotion &&
      other.enabled == enabled &&
      other.translate == translate;

  @override
  int get hashCode => Object.hash(enabled, translate);
}
