# pillar_core

The foundation every Pillar package builds on: a dependency injector, a module
system, and the error and layering contracts the rest of the framework shares.

**Pure Dart.** Nothing here imports Flutter, so the same contracts compile in a
server, a CLI or a plain `dart test` run. The Flutter bindings live in
[`pillar_flutter`](../pillar_flutter).

```yaml
dependencies:
  pillar_core: ^1.0.0
```

## The injector

Pillar ships its own rather than depending on a third-party locator. Every
package in the framework registers through this one interface, so it has to sit
in the package with no dependencies of its own.

```dart
final container = PillarContainer()
  ..registerLazySingleton<Clock>((_) => const SystemClock())
  ..registerLazySingleton<AuthService>((c) => AuthService(clock: c.get<Clock>()));

final auth = container.get<AuthService>();
```

A factory receives the container rather than reaching for a global. That is what
lets the same registration run unchanged inside a test scope.

### Lifetimes

| Registration | Instances | Built |
|---|---|---|
| `registerFactory` | one per `get` | on demand |
| `registerSingleton` | one | at registration |
| `registerLazySingleton` | one | on first `get` |
| `registerAsyncSingleton` | one | by `ready()`, or on `getAsync` |

Anything that needs to await — a Firebase handle, a platform channel, an opened
database — is registered asynchronously and resolved once at startup:

```dart
container.registerAsyncSingleton<Database>(
  (c) async => Database.open(c.get<Config>().path),
  dispose: (db) => db.close(),
);

await container.ready(); // resolves eager async registrations, in order
container.get<Database>(); // synchronous from here on
```

Reading one before it has resolved throws `DependencyNotReadyError` rather than
returning a half-built object.

### Names

Two implementations of one interface coexist under different names — the case a
framework with swappable vendors runs into immediately.

```dart
container
  ..registerSingleton<Cache>(MemoryCache(), name: 'session')
  ..registerSingleton<Cache>(DiskCache(), name: 'persistent');

container.get<Cache>(name: 'session');
```

### Scopes

`openScope()` returns a child that reads through to its parent but registers
locally. It is how a binding is replaced without mutating shared state:

```dart
final scope = container.openScope()
  ..registerSingleton<PaymentGateway>(FakeGateway());

scope.get<PaymentGateway>();      // the fake
container.get<PaymentGateway>();  // untouched
await scope.dispose();            // releases only what the scope owns
```

A scope shadows the *binding*, not instances already built from it. Shadowing
`Clock` after a singleton that depends on it has been constructed changes
nothing — shadow what you want replaced.

### Disposal

`dispose()` releases scopes first, then runs each disposer in reverse
registration order, so a dependency outlives whatever depended on it. A lazy
singleton that was never built is never disposed.

### Errors

Every failure is an `Error`, not an `Exception`: each one reports a wiring
mistake fixed in code, not a condition a caller recovers from. A cycle is
reported as the path that produced it — `AuthService -> UserRepository ->
AuthService` — rather than as a stack overflow.

## Modules

A module is one package's contribution to the graph. Packages ship one instead
of asking consumers to wire their internals:

```dart
final class PillarRemoteConfigFirebaseModule extends PillarModule {
  const PillarRemoteConfigFirebaseModule();

  @override
  List<PillarModule> get dependencies => const [PillarCoreModule()];

  @override
  void register(PillarContainer container) {
    container.registerAsyncSingleton<RemoteConfig>((c) => FirebaseRemoteConfig.open());
  }
}
```

An application names what it wants; order and asynchronous setup follow:

```dart
await installModules(container, [
  const PillarRemoteConfigFirebaseModule(),
  const PillarNotificationsFirebaseModule(),
]);
```

A module type is installed once however often it appears in the graph, and an
explicitly passed instance beats the default a dependency would have supplied —
which is how an application configures a module another package also needs.

Swapping a vendor means swapping one entry in that list. Nothing else changes.

## The global container

`Pillar` wraps a single root container for the common case of one graph per
process:

```dart
Future<void> main() async {
  await Pillar.install([const AppModule()]);
  runApp(const MyApp());
}
```

Library code should take a `PillarContainer` instead. A package that resolves
from the global cannot be used twice in one process, and its tests have to reset
shared state between cases. Pillar's own packages never touch `Pillar` — they
register through `PillarModule` and resolve from the container handed to their
factories.

## Clean architecture base classes

`BaseEntity`, `BaseRepository`, `BaseUseCase`, `BaseService`, and the `Failure`
and `Exception` hierarchies. They carry no dependencies and impose no state
management; the presentation-layer base class lives in `pillar_flutter`, because
it needs `ChangeNotifier`.

## Migrating from the Provider-based API

`pillar_core` 1.x wrapped the `provider` package. It no longer does, and the
widget-facing half moved to `pillar_flutter`.

| Before | Now |
|---|---|
| `DependencyContainer` | `PillarContainer` |
| `ProviderDependencyContainer.instance` | `PillarContainer()`, or `Pillar.container` |
| `ServiceLocator.get<T>()` | `Pillar.get<T>()` |
| `registerFactory(() => T())` | `registerFactory((c) => T())` — factories take the container |
| `DependencyInjectionProvider` | `PillarScope` (`pillar_flutter`) |
| `context.getDependency<T>()` | `context.get<T>()` (`pillar_flutter`) |
| `DependencyInjectionMixin` | `context.get<T>()` in `initState` |
| `BaseProvider` | unchanged, in `pillar_flutter` |
| `DependencyConsumer`, `DependencySelector` | removed — use `ListenableBuilder` |

The two removed widgets wrapped `Consumer<DependencyContainer>`. A container is
not a `Listenable`, so neither ever rebuilt on anything.

## Example

[`example/pillar_core_example.dart`](example/pillar_core_example.dart) — modules,
lifetimes, asynchronous setup and scopes, in a console app.
