# Pillar Remote Config

A remote configuration package for the Pillar framework, providing easy access to Firebase Remote Config and other remote configuration services.

## Features

- 🔧 **Remote Configuration**: Easy access to remote configuration values
- 🏗️ **Clean Architecture**: Built on top of pillar-core's clean architecture
- 🚀 **Firebase Integration**: Built-in Firebase Remote Config support
- 💉 **Dependency Injection**: Seamless integration with pillar-core's DI system
- 🎯 **Type Safety**: Type-safe configuration access
- 📱 **Flutter Ready**: Provider-based state management for Flutter apps

## Installation

Add `pillar_remote_config` to your `pubspec.yaml`:

```yaml
dependencies:
  pillar_remote_config: ^1.0.0
```

## Usage

### Setup Dependencies

```dart
import 'package:pillar_core/pillar_core.dart';
import 'package:pillar_remote_config/pillar_remote_config.dart';

void setupDependencies() {
  final container = ServiceLocator.container;

  // Register remote config service
  container.registerLazySingleton<RemoteConfigService>(
    () => FirebaseRemoteConfigService(),
  );

  // Register repository
  container.registerLazySingleton<RemoteConfigRepository>(
    () => RemoteConfigRepositoryImpl(
      service: ServiceLocator.get<RemoteConfigService>(),
    ),
  );

  // Register provider
  container.registerFactory<RemoteConfigProvider>(
    () => RemoteConfigProvider(
      repository: ServiceLocator.get<RemoteConfigRepository>(),
    ),
  );
}
```

### Using in Widgets

```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DependencyConsumer<RemoteConfigProvider>(
      builder: (context, provider, child) {
        final welcomeMessage = provider.getConfig<String>('welcome_message') ?? 'Welcome!';
        final isFeatureEnabled = provider.getConfig<bool>('feature_enabled') ?? false;
        
        return Column(
          children: [
            Text(welcomeMessage),
            if (isFeatureEnabled) 
              ElevatedButton(
                onPressed: () => provider.refreshConfigs(),
                child: Text('Refresh Config'),
              ),
          ],
        );
      },
    );
  }
}
```

## Version

Current version: 1.0.0

This package depends on `pillar_core` and will be updated automatically when pillar_core has breaking changes.
