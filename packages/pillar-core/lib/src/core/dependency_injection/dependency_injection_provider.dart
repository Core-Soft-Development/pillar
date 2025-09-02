import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:pillar_core/src/core/dependency_injection/dependency_container.dart';
import 'package:pillar_core/src/core/dependency_injection/provider_dependency_container.dart';

/// Provider wrapper for dependency injection container
class DependencyInjectionProvider extends StatelessWidget {
  /// Creates a provider that supplies a [DependencyContainer] to its descendants
  const DependencyInjectionProvider({
    super.key,
    required this.child,
    this.container,
    this.setup,
  });

  final Widget child;
  final DependencyContainer? container;
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

  final R Function(T dependency) selector;
  final Widget Function(BuildContext context, R value, Widget? child) builder;
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
}
