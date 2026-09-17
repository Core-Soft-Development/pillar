# pillar_flutter

Flutter bindings for [`pillar_core`](../pillar_core).

`pillar_core` is pure Dart and knows nothing about widgets. This package is the
seam between the two: it hands a `PillarContainer` to a widget tree, and
supplies the presentation-layer base class that needs `ChangeNotifier`.

Keeping them apart is what lets an interface package — `pillar_webview`,
`pillar_notifications` — be consumed from a server, a CLI or a plain `dart test`
run without dragging in a UI toolkit.

```yaml
dependencies:
  pillar_flutter: ^1.0.0
```

## Exposing the container

Build the graph before the first frame, then hand it to the tree. Widgets
resolve synchronously afterwards, so no screen has to render a "still wiring up"
state.

```dart
Future<void> main() async {
  final container = PillarContainer();
  await installModules(container, [const AppModule()]);

  runApp(PillarScope(container: container, child: const MyApp()));
}
```

## Resolving

```dart
class _ProfilePageState extends State<ProfilePage> {
  late final ProfilePresenter _presenter = context.get<ProfilePresenter>();
}
```

`context.get<T>()` works in `initState`: `PillarScope` hands out the container
without registering an inherited-widget dependency, so reading one does not
rebuild the caller. A container is a wiring root, not reactive state. To change
what a subtree resolves, open a scope and mount a nested `PillarScope`:

```dart
PillarScope(
  container: container.openScope()..registerSingleton<Gateway>(FakeGateway()),
  child: const CheckoutFlow(),
)
```

`PillarScope.of(context)` throws a `FlutterError` naming the widget that asked
when no scope is mounted above it; `PillarScope.maybeOf(context)` returns null.

## BaseProvider

A `ChangeNotifier` holding the loading and error state a screen needs, and
running an asynchronous operation with both handled:

```dart
class ProfilePresenter extends BaseProvider {
  ProfilePresenter(this._service);

  final ProfileService _service;
  Profile? profile;

  Future<void> load() async {
    final result = await executeAsync(_service.fetch);
    if (result != null) {
      profile = result;
      notifyListeners();
    }
  }
}
```

Register it as a factory so each screen gets its own, and render it with
Flutter's own `ListenableBuilder` — the framework ships no state-management
opinion beyond `ChangeNotifier`:

```dart
container.registerFactory<ProfilePresenter>((c) => ProfilePresenter(c.get<ProfileService>()));
```

```dart
ListenableBuilder(
  listenable: _presenter,
  builder: (context, _) => _presenter.isLoading
      ? const CircularProgressIndicator()
      : Text(_presenter.profile?.name ?? ''),
)
```

## Example

[`example/lib/main.dart`](example/lib/main.dart) — a module, the layers, and a
screen resolving its presenter from the scope.
