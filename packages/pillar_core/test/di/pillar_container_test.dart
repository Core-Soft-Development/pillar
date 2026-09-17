import 'dart:async';

import 'package:pillar_core/pillar_core.dart';
import 'package:test/test.dart';

class Clock {
  const Clock(this.label);
  final String label;
}

class Service {
  Service(this.clock);
  final Clock clock;
  bool closed = false;
}

void main() {
  late PillarContainer container;

  setUp(() => container = PillarContainer());
  tearDown(() => container.dispose());

  group('lifetimes', () {
    test('a factory runs on every resolution', () {
      var built = 0;
      container.registerFactory<Clock>((_) {
        built++;
        return const Clock('tick');
      });

      expect(container.get<Clock>().label, 'tick');
      container.get<Clock>();
      expect(built, 2);
    });

    test('a singleton is the instance that was registered', () {
      const instance = Clock('fixed');
      container.registerSingleton<Clock>(instance);

      expect(identical(container.get<Clock>(), instance), isTrue);
    });

    test('a lazy singleton is built once, on first resolution', () {
      var built = 0;
      container.registerLazySingleton<Clock>((_) {
        built++;
        return const Clock('lazy');
      });

      expect(built, 0, reason: 'registration alone must not build anything');
      final first = container.get<Clock>();
      expect(identical(container.get<Clock>(), first), isTrue);
      expect(built, 1);
    });

    test('a factory resolves its own dependencies from the container', () {
      container
        ..registerSingleton<Clock>(const Clock('shared'))
        ..registerLazySingleton<Service>((c) => Service(c.get<Clock>()));

      expect(container.get<Service>().clock.label, 'shared');
    });
  });

  group('named registrations', () {
    test('two instances of one type coexist under different names', () {
      container
        ..registerSingleton<Clock>(const Clock('utc'), name: 'utc')
        ..registerSingleton<Clock>(const Clock('local'), name: 'local');

      expect(container.get<Clock>(name: 'utc').label, 'utc');
      expect(container.get<Clock>(name: 'local').label, 'local');
    });

    test('a name is part of the identity, so the unnamed one is absent', () {
      container.registerSingleton<Clock>(const Clock('utc'), name: 'utc');

      expect(container.isRegistered<Clock>(name: 'utc'), isTrue);
      expect(container.isRegistered<Clock>(), isFalse);
      expect(container.maybeGet<Clock>(), isNull);
    });
  });

  group('failures', () {
    test('resolving something unregistered names it, and what is registered', () {
      container.registerSingleton<Clock>(const Clock('tick'));

      expect(
        () => container.get<Service>(),
        throwsA(
          isA<DependencyNotFoundError>()
              .having((e) => e.dependency, 'dependency', 'Service')
              .having((e) => e.message, 'message', contains('Clock')),
        ),
      );
    });

    test('registering the same key twice is refused', () {
      container.registerSingleton<Clock>(const Clock('first'));

      expect(
        () => container.registerSingleton<Clock>(const Clock('second')),
        throwsA(isA<DependencyAlreadyRegisteredError>()),
      );
    });

    test('a cycle is reported as the path that produced it', () {
      container
        ..registerLazySingleton<Clock>((c) => Clock(c.get<Service>().clock.label))
        ..registerLazySingleton<Service>((c) => Service(c.get<Clock>()));

      expect(
        () => container.get<Clock>(),
        throwsA(
          isA<CircularDependencyError>().having(
            (e) => e.chain,
            'chain',
            ['Clock', 'Service', 'Clock'],
          ),
        ),
      );
    });

    test('a resolution that fails leaves no half-built state behind', () {
      var attempts = 0;
      container.registerLazySingleton<Clock>((_) {
        attempts++;
        if (attempts == 1) throw StateError('boom');
        return const Clock('second try');
      });

      expect(() => container.get<Clock>(), throwsStateError);
      expect(container.get<Clock>().label, 'second try');
    });

    test('a disposed container refuses further use', () async {
      await container.dispose();

      expect(
        () => container.registerSingleton<Clock>(const Clock('late')),
        throwsA(isA<ContainerDisposedError>()),
      );
    });
  });

  group('asynchronous registrations', () {
    test('ready() resolves eager ones, and get() works afterwards', () async {
      container.registerAsyncSingleton<Clock>((_) async => const Clock('booted'));

      expect(() => container.get<Clock>(), throwsA(isA<DependencyNotReadyError>()));
      await container.ready();
      expect(container.get<Clock>().label, 'booted');
    });

    test('a lazy one stays unresolved until getAsync asks for it', () async {
      var built = 0;
      container.registerAsyncSingleton<Clock>(
        (_) async {
          built++;
          return const Clock('on demand');
        },
        eager: false,
      );

      await container.ready();
      expect(built, 0);
      expect((await container.getAsync<Clock>()).label, 'on demand');
      expect(built, 1);
    });

    test('concurrent resolutions share one future', () async {
      var built = 0;
      container.registerAsyncSingleton<Clock>(
        (_) async {
          built++;
          await Future<void>.delayed(const Duration(milliseconds: 10));
          return const Clock('once');
        },
        eager: false,
      );

      await Future.wait([container.getAsync<Clock>(), container.getAsync<Clock>()]);
      expect(built, 1);
    });

    test('eager ones resolve in registration order', () async {
      final order = <String>[];
      container
        ..registerAsyncSingleton<Clock>((_) async {
          order.add('clock');
          return const Clock('first');
        })
        ..registerAsyncSingleton<Service>((c) async {
          order.add('service');
          return Service(await c.getAsync<Clock>());
        });

      await container.ready();
      expect(order, ['clock', 'service']);
    });

    test('getAsync also serves synchronous registrations', () async {
      container.registerSingleton<Clock>(const Clock('sync'));

      expect((await container.getAsync<Clock>()).label, 'sync');
    });
  });

  group('scopes', () {
    test('a scope reads through to its parent', () {
      container.registerSingleton<Clock>(const Clock('root'));
      final scope = container.openScope();

      expect(scope.get<Clock>().label, 'root');
    });

    test('a scope shadows the parent without mutating it', () {
      container.registerSingleton<Clock>(const Clock('real'));
      final scope = container.openScope()..registerSingleton<Clock>(const Clock('fake'));

      expect(scope.get<Clock>().label, 'fake');
      expect(container.get<Clock>().label, 'real');
    });

    test("a parent's singleton is built once, however many scopes read it", () {
      var built = 0;
      container.registerLazySingleton<Clock>((_) {
        built++;
        return const Clock('shared');
      });

      container.openScope().get<Clock>();
      container.openScope().get<Clock>();
      expect(built, 1);
    });

    test('a shadowed dependency is used by the parent registration resolving it', () {
      container
        ..registerSingleton<Clock>(const Clock('real'))
        ..registerFactory<Service>((c) => Service(c.get<Clock>()));

      final scope = container.openScope()..registerSingleton<Clock>(const Clock('fake'));

      expect(scope.get<Service>().clock.label, 'fake');
    });

    test('disposing a scope releases only what it owns', () async {
      final parent = Service(const Clock('parent'));
      final child = Service(const Clock('child'));
      container.registerSingleton<Service>(parent, dispose: (s) => s.closed = true);

      final scope = container.openScope()
        ..registerSingleton<Service>(child, name: 'child', dispose: (s) => s.closed = true);
      await scope.dispose();

      expect(child.closed, isTrue);
      expect(parent.closed, isFalse);
    });

    test('disposing a container disposes its scopes first', () async {
      final order = <String>[];
      container.registerSingleton<Clock>(
        const Clock('root'),
        dispose: (_) => order.add('root'),
      );
      container.openScope().registerSingleton<Clock>(
            const Clock('scoped'),
            dispose: (_) => order.add('scope'),
          );

      await container.dispose();
      expect(order, ['scope', 'root']);
    });
  });

  group('disposal', () {
    test('disposers run in reverse registration order', () async {
      final order = <String>[];
      container
        ..registerSingleton<Clock>(const Clock('a'), dispose: (_) => order.add('clock'))
        ..registerSingleton<Service>(Service(const Clock('a')), dispose: (_) => order.add('service'));

      await container.dispose();
      expect(order, ['service', 'clock'], reason: 'a dependency must outlive its dependents');
    });

    test('a lazy singleton that was never built is not disposed', () async {
      var disposed = false;
      container.registerLazySingleton<Service>(
        (_) => Service(const Clock('a')),
        dispose: (_) => disposed = true,
      );

      await container.dispose();
      expect(disposed, isFalse);
    });

    test('an asynchronous disposer is awaited', () async {
      final completer = Completer<void>();
      container.registerSingleton<Clock>(
        const Clock('a'),
        dispose: (_) async {
          await Future<void>.delayed(Duration.zero);
          completer.complete();
        },
      );

      await container.dispose();
      expect(completer.isCompleted, isTrue);
    });

    test('unregister disposes the instance and frees the key', () async {
      final service = Service(const Clock('a'));
      container.registerSingleton<Service>(service, dispose: (s) => s.closed = true);

      await container.unregister<Service>();

      expect(service.closed, isTrue);
      expect(container.isRegistered<Service>(), isFalse);
      expect(
        () => container.registerSingleton<Service>(Service(const Clock('b'))),
        returnsNormally,
      );
    });

    test('unregister does not reach into an enclosing scope', () async {
      container.registerSingleton<Clock>(const Clock('root'));
      final scope = container.openScope();

      await scope.unregister<Clock>();

      expect(container.isRegistered<Clock>(), isTrue);
    });
  });
}
