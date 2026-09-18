# pillar_remote_config

Typed access to configuration that lives outside the app — feature flags,
thresholds, anything you want to change without shipping a build.

This package is the **contract**. It ships one implementation,
`InMemoryRemoteConfigService`, which serves a plain map. A real backend
(Firebase Remote Config, a REST endpoint, a file) belongs in its own
`pillar_remote_config_*` package, so that swapping one for another never
touches the code that reads config.

## Installation

```yaml
dependencies:
  pillar_remote_config: ^0.1.0
```

## Usage

### Register the dependencies

```dart
import 'package:pillar_core/pillar_core.dart';
import 'package:pillar_remote_config/pillar_remote_config.dart';

final container = PillarContainer();

// Swap this one registration for a real backend when you have one.
container.registerLazySingleton<RemoteConfigService>(
  () => InMemoryRemoteConfigService({
    'welcome_message': 'Hello',
    'feature_x_enabled': false,
    'max_retries': 3,
  }),
);

container.registerLazySingleton<RemoteConfigRepository>(
  () => RemoteConfigRepositoryImpl(service: container.get<RemoteConfigService>()),
);

container.registerFactory<RemoteConfigProvider>(
  () => RemoteConfigProvider(repository: container.get<RemoteConfigRepository>()),
);
```

The backend is named exactly once, at the composition root. Nothing downstream
knows which one it is.

### Read values

```dart
final config = container.get<RemoteConfigService>();

final message = config.getString('welcome_message', defaultValue: 'Hi');
final enabled = config.getBool('feature_x_enabled');
final retries = config.getInt('max_retries', defaultValue: 1);
```

Every getter takes a `defaultValue`, returned when the key is missing **or**
holds a value of another type. Remote config is data someone else controls; a
bad value upstream should not take the app down.

### In Flutter

```dart
import 'package:pillar_flutter/pillar_flutter.dart';

runApp(PillarScope(container: container, child: const MyApp()));

// then, anywhere below it
final config = context.get<RemoteConfigService>();
```

`RemoteConfigProvider` is a `BaseProvider`, so it works with
`ListenableBuilder` for screens that refresh config at runtime.

### In tests

`InMemoryRemoteConfigService` is the whole test setup — no fakes to write:

```dart
final service = InMemoryRemoteConfigService({'feature_x_enabled': true});
// ... exercise the code under test
service.setAll({'feature_x_enabled': false});
```

## API

| Type | Role |
|---|---|
| `RemoteConfigService` | The contract: typed reads, `hasKey`, `getAll`, `fetchAndActivate` |
| `InMemoryRemoteConfigService` | Map-backed implementation, for tests and defaults |
| `RemoteConfigRepository` | Async access over a service, used by the provider |
| `RemoteConfigProvider` | Flutter state for config that changes at runtime |

`fetchAndActivate` returns whether new values were activated.
`InMemoryRemoteConfigService` returns `false` — there is nothing behind it to
fetch, and claiming otherwise would hide a backend you forgot to wire in.
