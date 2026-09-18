import 'dart:async';

import 'package:meta/meta.dart';
import 'package:pillar_core/src/di/di_errors.dart';

/// Builds an instance of [T], resolving whatever else it needs from
/// [container].
///
/// Taking the container as an argument, rather than reaching for a global,
/// is what lets the same registration run inside a test scope unchanged.
typedef PillarFactory<T extends Object> = T Function(PillarContainer container);

/// Builds an instance of [T] asynchronously.
typedef PillarAsyncFactory<T extends Object> = Future<T> Function(PillarContainer container);

/// Releases whatever [instance] holds — a stream subscription, a socket, a
/// platform channel. Run in reverse registration order when the owning
/// container is disposed.
typedef PillarDisposer<T extends Object> = FutureOr<void> Function(T instance);

/// A dependency container.
///
/// Pillar ships its own rather than depending on a third-party locator: every
/// package in the framework registers through this interface, so it has to sit
/// in `pillar_core`, which carries no dependencies beyond `meta`.
///
/// ```dart
/// final container = PillarContainer()
///   ..registerLazySingleton<Clock>((_) => const SystemClock())
///   ..registerLazySingleton<AuthService>((c) => AuthService(clock: c.get<Clock>()));
///
/// final auth = container.get<AuthService>();
/// ```
///
/// Four lifetimes are available:
///
/// | registration | instances | resolved |
/// |---|---|---|
/// | `registerFactory` | one per `get` | on demand |
/// | `registerSingleton` | one | at registration |
/// | `registerLazySingleton` | one | on first `get` |
/// | `registerAsyncSingleton` | one | by `ready()`, or `getAsync` |
///
/// A container may be scoped. [openScope] returns a child that reads through to
/// its parent but registers locally, so disposing it releases only what it
/// owns. Scopes are how a binding is replaced without mutating shared state —
/// a test, or a feature whose dependencies live only as long as its screen.
abstract interface class PillarContainer {
  /// Creates an empty root container.
  factory PillarContainer() = _Container.root;

  /// Registers a factory that runs on every [get].
  void registerFactory<T extends Object>(PillarFactory<T> create, {String? name});

  /// Registers an already-built [instance] as the single instance of [T].
  void registerSingleton<T extends Object>(T instance, {String? name, PillarDisposer<T>? dispose});

  /// Registers a singleton built on first access.
  void registerLazySingleton<T extends Object>(PillarFactory<T> create, {String? name, PillarDisposer<T>? dispose});

  /// Registers a singleton built asynchronously.
  ///
  /// When [eager] is true — the default — [ready] resolves it at startup, and
  /// [get] works normally from then on. Set it to false for something expensive
  /// that may never be needed, and read it with [getAsync].
  void registerAsyncSingleton<T extends Object>(
    PillarAsyncFactory<T> create, {
    String? name,
    PillarDisposer<T>? dispose,
    bool eager = true,
  });

  /// Resolves [T], throwing if it is not registered.
  ///
  /// Throws [DependencyNotFoundError] if nothing is registered, and
  /// [DependencyNotReadyError] for an asynchronous registration that has not
  /// resolved yet.
  T get<T extends Object>({String? name});

  /// Resolves [T], returning null rather than throwing when it is absent.
  T? maybeGet<T extends Object>({String? name});

  /// Resolves [T], awaiting an asynchronous registration if needed.
  ///
  /// Concurrent calls for the same dependency share one future; the factory
  /// runs once.
  Future<T> getAsync<T extends Object>({String? name});

  /// Whether [T] is registered here or in an enclosing scope.
  bool isRegistered<T extends Object>({String? name});

  /// Removes a registration made in *this* container, disposing its instance.
  ///
  /// Registrations inherited from a parent scope are left alone.
  Future<void> unregister<T extends Object>({String? name});

  /// Resolves every eager asynchronous registration, in registration order.
  ///
  /// Called for you by `installModules`. Safe to call more than once: anything
  /// already resolved is skipped.
  Future<void> ready();

  /// Opens a child scope that reads through to this container.
  ///
  /// Registering a type that the parent also registers shadows it, for this
  /// scope only. Disposing the parent disposes its scopes first.
  PillarContainer openScope({String? name});

  /// Disposes this container, its scopes, and every instance it built.
  ///
  /// Disposers run in reverse registration order, so a dependency outlives
  /// whatever depends on it.
  Future<void> dispose();

  /// The registrations held by this container, for diagnostics.
  ///
  /// Does not include registrations inherited from enclosing scopes.
  @visibleForTesting
  List<String> get debugRegistrations;
}

// --- implementation --------------------------------------------------------

enum _Lifetime { transient, singleton, lazy, asynchronous }

/// Identifies a registration. Two dependencies of the same type coexist when
/// they carry different names — the case that makes a framework with several
/// implementations of one interface workable.
@immutable
final class _Key {
  const _Key(this.type, this.name);

  final Type type;
  final String? name;

  @override
  bool operator ==(Object other) => other is _Key && other.type == type && other.name == name;

  @override
  int get hashCode => Object.hash(type, name);

  @override
  String toString() => name == null ? '$type' : "$type('$name')";
}

final class _Registration {
  _Registration({
    required this.lifetime,
    this.create,
    this.createAsync,
    this.dispose,
    this.instance,
    this.eager = false,
  });

  final _Lifetime lifetime;
  final Object Function(PillarContainer container)? create;
  final Future<Object> Function(PillarContainer container)? createAsync;
  final FutureOr<void> Function(Object instance)? dispose;
  final bool eager;

  Object? instance;
  Future<Object>? pending;
}

final class _Container implements PillarContainer {
  _Container.root() : _parent = null, _name = null;

  _Container._scope(this._parent, this._name);

  final _Container? _parent;
  final String? _name;

  final Map<_Key, _Registration> _registrations = {};

  /// Registration order. Disposal walks it backwards.
  final List<_Key> _order = [];
  final List<_Container> _children = [];

  /// The path currently being resolved, used to report cycles. Saved and
  /// restored around each factory call rather than held globally, so a scope
  /// and its parent never trip over each other.
  ///
  /// Exact for synchronous resolution. Across asynchronous factories it holds
  /// while resolution is sequential, which is how [ready] drives it.
  List<_Key> _chain = const [];

  bool _disposed = false;

  @override
  void registerFactory<T extends Object>(PillarFactory<T> create, {String? name}) {
    _put(_Key(T, name), _Registration(lifetime: _Lifetime.transient, create: (c) => create(c)));
  }

  @override
  void registerSingleton<T extends Object>(T instance, {String? name, PillarDisposer<T>? dispose}) {
    _put(
      _Key(T, name),
      _Registration(
        lifetime: _Lifetime.singleton,
        instance: instance,
        dispose: dispose == null ? null : (o) => dispose(o as T),
      ),
    );
  }

  @override
  void registerLazySingleton<T extends Object>(PillarFactory<T> create, {String? name, PillarDisposer<T>? dispose}) {
    _put(
      _Key(T, name),
      _Registration(
        lifetime: _Lifetime.lazy,
        create: (c) => create(c),
        dispose: dispose == null ? null : (o) => dispose(o as T),
      ),
    );
  }

  @override
  void registerAsyncSingleton<T extends Object>(
    PillarAsyncFactory<T> create, {
    String? name,
    PillarDisposer<T>? dispose,
    bool eager = true,
  }) {
    _put(
      _Key(T, name),
      _Registration(
        lifetime: _Lifetime.asynchronous,
        createAsync: (c) => create(c),
        dispose: dispose == null ? null : (o) => dispose(o as T),
        eager: eager,
      ),
    );
  }

  @override
  T get<T extends Object>({String? name}) {
    final key = _Key(T, name);
    final registration = _lookup(key) ?? (throw DependencyNotFoundError('$key', debugRegistrations));
    return _instantiate(registration, key) as T;
  }

  @override
  T? maybeGet<T extends Object>({String? name}) {
    final key = _Key(T, name);
    final registration = _lookup(key);
    if (registration == null) return null;
    return _instantiate(registration, key) as T;
  }

  @override
  Future<T> getAsync<T extends Object>({String? name}) async {
    final key = _Key(T, name);
    final registration = _lookup(key) ?? (throw DependencyNotFoundError('$key', debugRegistrations));
    if (registration.lifetime != _Lifetime.asynchronous) {
      return _instantiate(registration, key) as T;
    }
    return await _resolveAsync(registration, key) as T;
  }

  @override
  bool isRegistered<T extends Object>({String? name}) => _lookup(_Key(T, name)) != null;

  @override
  Future<void> unregister<T extends Object>({String? name}) async {
    final key = _Key(T, name);
    final registration = _registrations.remove(key);
    _order.remove(key);
    final instance = registration?.instance;
    if (registration != null && instance != null) {
      await registration.dispose?.call(instance);
    }
  }

  @override
  Future<void> ready() async {
    _assertUsable();
    // Sequential, not Future.wait: an eager registration routinely depends on
    // an earlier one, and resolving them in parallel would race.
    for (final key in List<_Key>.of(_order)) {
      final registration = _registrations[key];
      if (registration == null) continue;
      if (registration.lifetime == _Lifetime.asynchronous && registration.eager && registration.instance == null) {
        await _resolveAsync(registration, key);
      }
    }
  }

  @override
  PillarContainer openScope({String? name}) {
    _assertUsable();
    final child = _Container._scope(this, name);
    _children.add(child);
    return child;
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;

    for (final child in List<_Container>.of(_children)) {
      await child.dispose();
    }
    _children.clear();

    for (final key in _order.reversed) {
      final registration = _registrations[key];
      final instance = registration?.instance;
      if (registration != null && instance != null) {
        await registration.dispose?.call(instance);
      }
    }
    _registrations.clear();
    _order.clear();
    _parent?._children.remove(this);
  }

  @override
  List<String> get debugRegistrations => _order.map((k) => '$k').toList(growable: false);

  @override
  String toString() => _name == null ? 'PillarContainer' : "PillarContainer('$_name')";

  // --- internals -----------------------------------------------------------

  void _put(_Key key, _Registration registration) {
    _assertUsable();
    if (_registrations.containsKey(key)) {
      throw DependencyAlreadyRegisteredError('$key');
    }
    _registrations[key] = registration;
    _order.add(key);
  }

  /// Walks up the scope chain. The instance is memoised on the registration
  /// itself, which the owning container holds, so a scope never caches a copy
  /// of its parent's singletons.
  _Registration? _lookup(_Key key) {
    _Container? container = this;
    while (container != null) {
      final registration = container._registrations[key];
      if (registration != null) return registration;
      container = container._parent;
    }
    return null;
  }

  Object _instantiate(_Registration registration, _Key key) {
    switch (registration.lifetime) {
      case _Lifetime.singleton:
        return registration.instance!;

      case _Lifetime.transient:
        return _invoke(registration, key);

      case _Lifetime.lazy:
        final existing = registration.instance;
        if (existing != null) return existing;
        return registration.instance = _invoke(registration, key);

      case _Lifetime.asynchronous:
        final existing = registration.instance;
        if (existing != null) return existing;
        throw DependencyNotReadyError('$key');
    }
  }

  Object _invoke(_Registration registration, _Key key) {
    final previous = _enter(key);
    try {
      // The factory receives `this`, not the owning container: a dependency
      // registered in a parent scope still resolves its own dependencies
      // against the scope that asked for it.
      return registration.create!(this);
    } finally {
      _chain = previous;
    }
  }

  Future<Object> _resolveAsync(_Registration registration, _Key key) {
    final existing = registration.instance;
    if (existing != null) return Future<Object>.value(existing);

    final pending = registration.pending;
    if (pending != null) return pending;

    final previous = _enter(key);
    final future = Future<Object>(() => registration.createAsync!(this))
        .then((instance) {
          registration.instance = instance;
          registration.pending = null;
          return instance;
        })
        .whenComplete(() => _chain = previous);

    return registration.pending = future;
  }

  /// Pushes [key] onto the resolution path, returning the previous one.
  List<_Key> _enter(_Key key) {
    if (_chain.contains(key)) {
      throw CircularDependencyError([..._chain, key].map((k) => '$k').toList());
    }
    final previous = _chain;
    _chain = [..._chain, key];
    return previous;
  }

  void _assertUsable() {
    if (_disposed) throw ContainerDisposedError();
  }
}
