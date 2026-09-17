/// Errors thrown by the Pillar dependency injector.
///
/// They extend [Error] rather than [Exception] on purpose: each one reports a
/// wiring mistake that is fixed in code, not a runtime condition a caller could
/// sensibly recover from. Catching one is almost always the wrong move.
library;

/// Base class for every dependency injection error.
sealed class PillarDiError extends Error {
  /// Creates a dependency injection error carrying [message].
  PillarDiError(this.message);

  /// Human-readable description of what went wrong.
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Thrown when a dependency is resolved before anything registered it.
final class DependencyNotFoundError extends PillarDiError {
  /// Creates the error for the unresolved [dependency].
  DependencyNotFoundError(this.dependency, List<String> registered)
      : super(
          'nothing is registered for $dependency.\n'
          "Registered here: ${registered.isEmpty ? '<empty container>' : registered.join(', ')}",
        );

  /// The dependency that could not be resolved, as `Type` or `Type('name')`.
  final String dependency;
}

/// Thrown when a dependency is registered twice in the same container.
///
/// To replace a binding — in a test, typically — open a scope with
/// `container.openScope()` and register the replacement there: a scope shadows
/// its parent instead of mutating it.
final class DependencyAlreadyRegisteredError extends PillarDiError {
  /// Creates the error for the duplicate [dependency].
  DependencyAlreadyRegisteredError(this.dependency)
      : super(
          '$dependency is already registered in this container.\n'
          'Open a scope and register the replacement there, or unregister first.',
        );

  /// The dependency that was registered twice.
  final String dependency;
}

/// Thrown when resolving a dependency leads back to itself.
///
/// The [chain] reads in resolution order, ending with the repeated entry:
/// `AuthService -> UserRepository -> AuthService`.
final class CircularDependencyError extends PillarDiError {
  /// Creates the error for the given resolution [chain].
  CircularDependencyError(this.chain) : super('circular dependency: ${chain.join(' -> ')}');

  /// The resolution path, ending with the dependency that repeats.
  final List<String> chain;
}

/// Thrown when an asynchronous registration is read synchronously before it has
/// been resolved.
///
/// Either await `container.ready()` once at startup — which is what
/// `installModules` does — or read it with `getAsync`.
final class DependencyNotReadyError extends PillarDiError {
  /// Creates the error for the unresolved asynchronous [dependency].
  DependencyNotReadyError(this.dependency)
      : super(
          '$dependency is registered asynchronously and has not resolved yet.\n'
          'Await container.ready() at startup, or read it with getAsync().',
        );

  /// The dependency that is not ready yet.
  final String dependency;
}

/// Thrown when a disposed container is used again.
final class ContainerDisposedError extends PillarDiError {
  /// Creates the error for a container that was already disposed.
  ContainerDisposedError() : super('this container was disposed and can no longer be used');
}

/// Thrown when modules declare a dependency cycle between themselves.
final class ModuleCycleError extends PillarDiError {
  /// Creates the error for the given module [chain].
  ModuleCycleError(this.chain) : super('module dependency cycle: ${chain.join(' -> ')}');

  /// The module path, ending with the module that repeats.
  final List<String> chain;
}
