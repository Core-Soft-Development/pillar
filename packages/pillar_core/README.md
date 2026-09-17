# Pillar Core

A foundational package for Flutter applications following Clean Architecture principles with powerful dependency injection using Provider.

## Features

- 🏗️ **Clean Architecture Foundation**: Pre-built base classes for entities, use cases, repositories, and services
- 💉 **Dependency Injection**: Comprehensive DI system with Provider integration
- 🔄 **Lifecycle Management**: Support for factory, singleton, and lazy singleton patterns
- 🎯 **Type Safety**: Fully typed dependency resolution with compile-time safety
- 🧪 **Testing Support**: Built-in testing utilities and mocking support
- 📱 **Flutter Integration**: Seamless integration with Flutter widgets and Provider

## Installation

Add `pillar_core` to your `pubspec.yaml`:

```yaml
dependencies:
  pillar_core: ^1.0.0
```

## Quick Start

### 1. Setup Dependencies

```dart
import 'package:pillar_core/pillar_core.dart';

void setupDependencies() {
  final container = ServiceLocator.container;

  // Register repositories
  container.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(),
  );

  // Register services
  container.registerLazySingleton<AuthService>(
    () => AuthServiceImpl(
      repository: ServiceLocator.get<UserRepository>(),
    ),
  );

  // Register providers
  container.registerFactory<AuthProvider>(
    () => AuthProvider(
      service: ServiceLocator.get<AuthService>(),
    ),
  );
}
```

### 2. Initialize in Your App

```dart
void main() {
  setupDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DependencyInjectionProvider(
      child: MaterialApp(
        home: const HomePage(),
      ),
    );
  }
}
```

### 3. Use Dependencies in Widgets

#### Using the Mixin

```dart
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with DependencyInjectionMixin {
  late final AuthProvider _authProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _authProvider = getDependency<AuthProvider>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => _authProvider.login(),
          child: const Text('Login'),
        ),
      ),
    );
  }
}
```

#### Using Context Extension

```dart
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            final authService = context.getDependency<AuthService>();
            authService.login();
          },
          child: const Text('Login'),
        ),
      ),
    );
  }
}
```

#### Using Consumer Widgets

```dart
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DependencyConsumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.isLoading) {
            return const CircularProgressIndicator();
          }
          
          return ElevatedButton(
            onPressed: () => authProvider.login(),
            child: const Text('Login'),
          );
        },
      ),
    );
  }
}
```

## Architecture Layers

### Domain Layer

The domain layer contains the business logic and is framework-independent.

#### Entities

```dart
import 'package:pillar_core/pillar_core.dart';

class User extends BaseEntity<String> {
  const User({
    required this.id,
    required this.name,
    required this.email,
  });

  @override
  final String id;
  final String name;
  final String email;
}
```

#### Use Cases

```dart
import 'package:pillar_core/pillar_core.dart';

class LoginParams extends UseCaseParams {
  const LoginParams({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;
}

class LoginUseCase implements BaseUseCase<User, LoginParams> {
  const LoginUseCase({
    required this.repository,
  });

  final AuthRepository repository;

  @override
  Future<User> execute(LoginParams params) async {
    return repository.login(params.email, params.password);
  }
}
```

#### Repositories

```dart
import 'package:pillar_core/pillar_core.dart';

abstract interface class AuthRepository extends BaseRepository {
  Future<User> login(String email, String password);
  Future<void> logout();
}
```

### Infrastructure Layer

The infrastructure layer contains implementations of domain interfaces.

#### Repository Implementation

```dart
import 'package:pillar_core/pillar_core.dart';

class AuthRepositoryImpl implements AuthRepository {
  @override
  String get repositoryName => 'AuthRepository';

  @override
  Future<User> login(String email, String password) async {
    // Implementation details
  }

  @override
  Future<void> logout() async {
    // Implementation details
  }
}
```

#### Services

```dart
import 'package:pillar_core/pillar_core.dart';

abstract interface class AuthService extends BaseService {
  Future<User> login(String email, String password);
}

class AuthServiceImpl implements AuthService {
  const AuthServiceImpl({
    required this.repository,
  });

  final AuthRepository repository;

  @override
  String get serviceName => 'AuthService';

  @override
  Future<User> login(String email, String password) {
    return repository.login(email, password);
  }
}
```

### Presentation Layer

The presentation layer handles UI state and user interactions.

#### Providers

```dart
import 'package:pillar_core/pillar_core.dart';

class AuthProvider extends BaseProvider {
  AuthProvider({
    required this.service,
  });

  final AuthService service;
  User? _user;

  User? get user => _user;
  bool get isLoggedIn => _user != null;

  Future<void> login(String email, String password) async {
    final user = await executeAsync<User>(
      () => service.login(email, password),
    );

    if (user != null) {
      _user = user;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _user = null;
    notifyListeners();
  }
}
```

## Dependency Registration Types

### Factory

Creates a new instance every time it's requested:

```dart
container.registerFactory<Service>(() => ServiceImpl());
```

### Singleton

Registers a single instance that's shared across the app:

```dart
final instance = ServiceImpl();
container.registerSingleton<Service>(instance);
```

### Lazy Singleton

Creates a single instance when first requested:

```dart
container.registerLazySingleton<Service>(() => ServiceImpl());
```

## Error Handling

Pillar Core provides a comprehensive error handling system:

```dart
try {
  final result = await useCase.execute(params);
} on ServerException catch (e) {
  throw ServerFailure(message: e.message);
} on NetworkException catch (e) {
  throw NetworkFailure(message: e.message);
}
```

## Testing

Pillar Core is designed with testing in mind:

```dart
void main() {
  group('AuthProvider', () {
    late AuthProvider provider;
    late MockAuthService mockService;

    setUp(() {
      mockService = MockAuthService();
      provider = AuthProvider(service: mockService);
    });

    test('should login successfully', () async {
      // Arrange
      final expectedUser = User(id: '1', name: 'John', email: 'john@example.com');
      when(() => mockService.login(any(), any()))
          .thenAnswer((_) async => expectedUser);

      // Act
      await provider.login('john@example.com', 'password');

      // Assert
      expect(provider.user, equals(expectedUser));
      expect(provider.isLoggedIn, isTrue);
    });
  });
}
```

## Best Practices

1. **Keep the domain layer pure**: Don't import Flutter or external packages in domain entities and use cases
2. **Use interfaces**: Define contracts in the domain layer and implement them in infrastructure
3. **Register dependencies at app startup**: Setup all dependencies before running the app
4. **Use appropriate lifecycles**: Choose between factory, singleton, and lazy singleton based on your needs
5. **Handle errors gracefully**: Use the provided failure and exception types for consistent error handling
6. **Test your dependencies**: Use the testing utilities to mock dependencies in tests

## Contributing

Contributions are welcome! Please read the contributing guidelines before submitting PRs.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
