import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:pillar_core/src/core/dependency_injection/dependency_container.dart';
import 'package:pillar_core/src/core/dependency_injection/provider_dependency_container.dart';
import 'package:provider/provider.dart';

/// Provider wrapper for dependency injection container
class DependencyInjectionProvider extends StatelessWidget {
  /// Creates a provider that supplies a [DependencyContainer] to its descendants
  const DependencyInjectionProvider({
    super.key,
    required this.child,
    this.container,
    this.setup,
  });

  /// The child widget that will have access to the dependency container
  final Widget child;

  /// Optional custom dependency container. If not provided, the default singleton instance will be used.
  final DependencyContainer? container;

  /// Optional setup function to register dependencies in the container
  final void Function(DependencyContainer container)? setup;

  @override
  Widget build(BuildContext context) {
    final dependencyContainer = container ?? ProviderDependencyContainer.instance;

    // Setup dependencies if setup function is provided
    setup?.call(dependencyContainer);

    return Provider<DependencyContainer>.value(
      value: dependencyContainer,
      child: child,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<DependencyContainer?>('container', container));
    properties.add(
      ObjectFlagProperty<void Function(DependencyContainer container)?>.has(
        'setup',
        setup,
      ),
    );
  }
}

/// Extension on BuildContext to easily access dependencies
extension DependencyInjectionContext on BuildContext {
  /// Get dependency container from context
  DependencyContainer get dependencies => read<DependencyContainer>();

  /// Get an instance of [T] from dependency container
  T getDependency<T extends Object>() => dependencies.get<T>();
}

/// Mixin to provide easy access to dependencies in widgets
mixin DependencyInjectionMixin<T extends StatefulWidget> on State<T> {
  late final DependencyContainer _dependencies;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _dependencies = context.read<DependencyContainer>();
  }

  /// Get an instance of [T] from dependency container
  D getDependency<D extends Object>() => _dependencies.get<D>();

  /// Check if dependency is registered
  bool isDependencyRegistered<D extends Object>() => _dependencies.isRegistered<D>();
}

/// Consumer widget for dependency injection
class DependencyConsumer<T extends Object> extends StatelessWidget {
  /// Creates a consumer widget that listens to changes in the dependency of type [T]
  const DependencyConsumer({
    super.key,
    required this.builder,
  });

  /// The builder function that receives the dependency and builds the widget
  final Widget Function(BuildContext context, T dependency, Widget? child) builder;

  @override
  Widget build(BuildContext context) {
    return Consumer<DependencyContainer>(
      builder: (context, container, child) {
        final dependency = container.get<T>();
        return builder(context, dependency, child);
      },
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      ObjectFlagProperty<
          Widget Function(
            BuildContext context,
            T dependency,
            Widget? child,
          )>.has('builder', builder),
    );
  }
}

/// Selector widget for dependency injection with specific property selection
class DependencySelector<T extends Object, R> extends StatelessWidget {
  /// Creates a selector widget that listens to changes in a selected property of the dependency of type [T]
  const DependencySelector({
    super.key,
    required this.selector,
    required this.builder,
    this.shouldRebuild,
  });

  /// The selector function that selects a specific property from the dependency
  final R Function(T dependency) selector;

  /// The builder function that receives the selected property and builds the widget
  final Widget Function(BuildContext context, R value, Widget? child) builder;

  /// Optional function to determine if the widget should rebuild based on changes in the selected property
  final bool Function(R previous, R next)? shouldRebuild;

  @override
  Widget build(BuildContext context) {
    return Consumer<DependencyContainer>(
      builder: (context, container, child) {
        final dependency = container.get<T>();
        final selectedValue = selector(dependency);
        return builder(context, selectedValue, child);
      },
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      ObjectFlagProperty<R Function(T dependency)>.has('selector', selector),
    );
    properties.add(
      ObjectFlagProperty<Widget Function(BuildContext context, R value, Widget? child)>.has(
        'builder',
        builder,
      ),
    );
    properties.add(
      ObjectFlagProperty<bool Function(R previous, R next)?>.has(
        'shouldRebuild',
        shouldRebuild,
      ),
    );
  }
}
