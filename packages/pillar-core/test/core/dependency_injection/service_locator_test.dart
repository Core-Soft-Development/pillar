import 'package:flutter_test/flutter_test.dart';
import 'package:pillar_core/pillar_core.dart';

// Test service interface
abstract interface class TestService {
  String getName();
}

class TestServiceImpl implements TestService {
  @override
  String getName() => 'TestService';
}

void main() {
  group('ServiceLocator', () {
    setUp(() {
      ServiceLocator.reset();
    });

    tearDown(() {
      ServiceLocator.reset();
    });

    test('should initialize with custom container', () {
      // Arrange
      final customContainer = ProviderDependencyContainer.instance;

      // Act
      ServiceLocator.initialize(customContainer);

      // Assert
      expect(ServiceLocator.container, same(customContainer));
    });

    test('should use default container when not initialized', () {
      // Act
      final container = ServiceLocator.container;

      // Assert
      expect(container, isA<ProviderDependencyContainer>());
    });

    test('should register and resolve factory dependency', () {
      // Act
      ServiceLocator.registerFactory<TestService>(() => TestServiceImpl());
      final instance = ServiceLocator.get<TestService>();

      // Assert
      expect(instance, isA<TestService>());
      expect(instance.getName(), equals('TestService'));
    });

    test('should register and resolve singleton dependency', () {
      // Arrange
      final instance = TestServiceImpl();

      // Act
      ServiceLocator.registerSingleton<TestService>(instance);
      final resolved = ServiceLocator.get<TestService>();

      // Assert
      expect(resolved, same(instance));
    });

    test('should register and resolve lazy singleton dependency', () {
      // Arrange
      var creationCount = 0;

      // Act
      ServiceLocator.registerLazySingleton<TestService>(() {
        creationCount++;
        return TestServiceImpl();
      });

      final instance1 = ServiceLocator.get<TestService>();
      final instance2 = ServiceLocator.get<TestService>();

      // Assert
      expect(creationCount, equals(1));
      expect(instance1, same(instance2));
    });

    test('should check if dependency is registered', () {
      // Arrange
      ServiceLocator.registerFactory<TestService>(() => TestServiceImpl());

      // Act & Assert
      expect(ServiceLocator.isRegistered<TestService>(), isTrue);
      expect(ServiceLocator.isRegistered<String>(), isFalse);
    });

    test('should unregister dependency', () {
      // Arrange
      ServiceLocator.registerFactory<TestService>(() => TestServiceImpl());
      expect(ServiceLocator.isRegistered<TestService>(), isTrue);

      // Act
      ServiceLocator.unregister<TestService>();

      // Assert
      expect(ServiceLocator.isRegistered<TestService>(), isFalse);
    });

    test('should clear all dependencies', () {
      // Arrange
      ServiceLocator.registerFactory<TestService>(() => TestServiceImpl());
      expect(ServiceLocator.isRegistered<TestService>(), isTrue);

      // Act
      ServiceLocator.clear();

      // Assert
      expect(ServiceLocator.isRegistered<TestService>(), isFalse);
    });

    test('should reset service locator', () {
      // Arrange
      final customContainer = ProviderDependencyContainer.instance;
      ServiceLocator.initialize(customContainer);
      ServiceLocator.registerFactory<TestService>(() => TestServiceImpl());

      // Act
      ServiceLocator.reset();

      // Assert
      expect(ServiceLocator.isRegistered<TestService>(), isFalse);
    });
  });
}
