import 'package:flutter_test/flutter_test.dart';
import 'package:pillar_core/pillar_core.dart';

// Test interfaces and implementations
abstract interface class TestService {
  String getName();
}

class TestServiceImpl implements TestService {
  @override
  String getName() => 'TestService';
}

class AnotherTestService implements TestService {
  @override
  String getName() => 'AnotherTestService';
}

void main() {
  group('ProviderDependencyContainer', () {
    late ProviderDependencyContainer container;

    setUp(() {
      container = ProviderDependencyContainer.instance;
      container.clear();
    });

    tearDown(() {
      container.clear();
    });

    group('Factory Registration', () {
      test('should register and resolve factory dependency', () {
        // Arrange
        container.registerFactory<TestService>(() => TestServiceImpl());

        // Act
        final instance1 = container.get<TestService>();
        final instance2 = container.get<TestService>();

        // Assert
        expect(instance1, isA<TestService>());
        expect(instance2, isA<TestService>());
        expect(instance1, isNot(same(instance2))); // Different instances
        expect(instance1.getName(), equals('TestService'));
      });

      test('should throw exception when registering already registered factory', () {
        // Arrange
        container.registerFactory<TestService>(() => TestServiceImpl());

        // Act & Assert
        expect(
          () => container.registerFactory<TestService>(() => AnotherTestService()),
          throwsA(isA<DependencyAlreadyRegisteredException>()),
        );
      });
    });

    group('Singleton Registration', () {
      test('should register and resolve singleton dependency', () {
        // Arrange
        final instance = TestServiceImpl();
        container.registerSingleton<TestService>(instance);

        // Act
        final resolved1 = container.get<TestService>();
        final resolved2 = container.get<TestService>();

        // Assert
        expect(resolved1, same(instance));
        expect(resolved2, same(instance));
        expect(resolved1, same(resolved2));
      });

      test('should throw exception when registering already registered singleton', () {
        // Arrange
        container.registerSingleton<TestService>(TestServiceImpl());

        // Act & Assert
        expect(
          () => container.registerSingleton<TestService>(AnotherTestService()),
          throwsA(isA<DependencyAlreadyRegisteredException>()),
        );
      });
    });

    group('Lazy Singleton Registration', () {
      test('should register and resolve lazy singleton dependency', () {
        // Arrange
        var creationCount = 0;
        container.registerLazySingleton<TestService>(() {
          creationCount++;
          return TestServiceImpl();
        });

        // Act
        final instance1 = container.get<TestService>();
        final instance2 = container.get<TestService>();

        // Assert
        expect(creationCount, equals(1)); // Created only once
        expect(instance1, same(instance2));
        expect(instance1.getName(), equals('TestService'));
      });

      test('should throw exception when registering already registered lazy singleton', () {
        // Arrange
        container.registerLazySingleton<TestService>(() => TestServiceImpl());

        // Act & Assert
        expect(
          () => container.registerLazySingleton<TestService>(() => AnotherTestService()),
          throwsA(isA<DependencyAlreadyRegisteredException>()),
        );
      });
    });

    group('Dependency Resolution', () {
      test('should throw exception when dependency not found', () {
        // Act & Assert
        expect(
          () => container.get<TestService>(),
          throwsA(isA<DependencyNotFoundException>()),
        );
      });

      test('should check if dependency is registered', () {
        // Arrange
        container.registerFactory<TestService>(() => TestServiceImpl());

        // Act & Assert
        expect(container.isRegistered<TestService>(), isTrue);
        expect(container.isRegistered<AnotherTestService>(), isFalse);
      });
    });

    group('Container Management', () {
      test('should unregister dependency', () {
        // Arrange
        container.registerFactory<TestService>(() => TestServiceImpl());
        expect(container.isRegistered<TestService>(), isTrue);

        // Act
        container.unregister<TestService>();

        // Assert
        expect(container.isRegistered<TestService>(), isFalse);
      });

      test('should clear all dependencies', () {
        // Arrange
        container.registerFactory<TestService>(() => TestServiceImpl());
        container.registerSingleton<AnotherTestService>(AnotherTestService());
        expect(container.registeredTypes.length, equals(2));

        // Act
        container.clear();

        // Assert
        expect(container.registeredTypes, isEmpty);
      });

      test('should reset container', () {
        // Arrange
        container.registerFactory<TestService>(() => TestServiceImpl());
        expect(container.registeredTypes.length, equals(1));

        // Act
        container.reset();

        // Assert
        expect(container.registeredTypes, isEmpty);
      });
    });
  });
}
