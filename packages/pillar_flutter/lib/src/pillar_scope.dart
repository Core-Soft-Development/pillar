import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:pillar_core/pillar_core.dart';

/// Exposes a [PillarContainer] to a widget subtree.
///
/// Install the graph before the app runs, then hand the container to the tree:
///
/// ```dart
/// Future<void> main() async {
///   final container = PillarContainer();
///   await installModules(container, [PillarRemoteConfigFirebaseModule()]);
///   runApp(PillarScope(container: container, child: const MyApp()));
/// }
/// ```
///
/// Reading a dependency does not register an inherited-widget dependency, so
/// [PillarScopeContext.get] works from `initState` and does not rebuild the
/// caller. The container is a wiring root, not reactive state: to change what a
/// widget resolves, open a scope and mount a new [PillarScope] under a
/// different key.
class PillarScope extends InheritedWidget {
  /// Exposes [container] to [child] and its descendants.
  const PillarScope({
    required this.container,
    required super.child,
    super.key,
  });

  /// The container descendants resolve from.
  final PillarContainer container;

  /// The container exposed by the nearest enclosing [PillarScope].
  ///
  /// Throws a [FlutterError] when there is none, rather than returning null:
  /// a missing scope is a wiring mistake, and the message says which widget
  /// asked.
  static PillarContainer of(BuildContext context) {
    final container = maybeOf(context);
    if (container == null) {
      throw FlutterError.fromParts([
        ErrorSummary('No PillarScope found above ${context.widget.runtimeType}.'),
        ErrorDescription(
          'Widgets resolve their dependencies from a PillarScope, which is '
          'usually mounted around the application root.',
        ),
        ErrorHint(
          'Wrap the app in a PillarScope:\n'
          '  runApp(PillarScope(container: container, child: const MyApp()));',
        ),
        context.describeElement('The widget that asked was'),
      ]);
    }
    return container;
  }

  /// The container exposed by the nearest enclosing [PillarScope], or null.
  static PillarContainer? maybeOf(BuildContext context) {
    final element = context.getElementForInheritedWidgetOfExactType<PillarScope>();
    return (element?.widget as PillarScope?)?.container;
  }

  @override
  bool updateShouldNotify(PillarScope oldWidget) => container != oldWidget.container;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<PillarContainer>('container', container));
  }
}

/// Resolving dependencies from a [BuildContext].
extension PillarScopeContext on BuildContext {
  /// The container of the nearest enclosing [PillarScope].
  PillarContainer get pillar => PillarScope.of(this);

  /// Resolves [T] from the nearest enclosing [PillarScope].
  T get<T extends Object>({String? name}) => pillar.get<T>(name: name);

  /// Resolves [T], returning null when it is not registered.
  T? maybeGet<T extends Object>({String? name}) => pillar.maybeGet<T>(name: name);
}
