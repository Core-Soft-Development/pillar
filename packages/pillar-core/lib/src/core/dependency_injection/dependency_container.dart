import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

/// Abstract interface for dependency container
abstract interface class DependencyContainer {
  /// Register a factory that creates instances of [T]
  void registerFactory<T extends Object>(T Function() factory);

  /// Register a singleton instance of [T]
  void registerSingleton<T extends Object>(T instance);

  /// Register a lazy singleton that creates instance of [T] when first accessed
  void registerLazySingleton<T extends Object>(T Function() factory);

  /// Get an instance of [T]
  T get<T extends Object>();

  /// Check if type [T] is registered
  bool isRegistered<T extends Object>();

  /// Unregister type [T]
  void unregister<T extends Object>();

  /// Clear all registrations
  void clear();

  /// Reset the container to initial state
  void reset();
}

/// Exception thrown when dependency is not found
class DependencyNotFoundException implements Exception {
  const DependencyNotFoundException(this.type);

  final Type type;

  @override
  String toString() => 'DependencyNotFoundException: No registration found for type $type';
}

/// Exception thrown when trying to register already registered dependency
class DependencyAlreadyRegisteredException implements Exception {
  const DependencyAlreadyRegisteredException(this.type);

  final Type type;

  @override
  String toString() => 'DependencyAlreadyRegisteredException: Type $type is already registered';
}

/// Lifecycle of a dependency
enum DependencyLifecycle {
  /// New instance created every time
  factory,

  /// Single instance shared across the application
  singleton,

  /// Single instance created when first accessed
  lazySingleton,
}

/// Registration information for a dependency
@immutable
class DependencyRegistration<T extends Object> {
  const DependencyRegistration({
    required this.factory,
    required this.lifecycle,
    this.instance,
  });

  final T Function() factory;
  final DependencyLifecycle lifecycle;
  final T? instance;

  DependencyRegistration<T> copyWith({
    T Function()? factory,
    DependencyLifecycle? lifecycle,
    T? instance,
  }) {
    return DependencyRegistration<T>(
      factory: factory ?? this.factory,
      lifecycle: lifecycle ?? this.lifecycle,
      instance: instance ?? this.instance,
    );
  }
}
