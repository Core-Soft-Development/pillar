import 'package:pillar_core/pillar_core.dart';
import 'package:test/test.dart';

/// Stands in for whatever a package registers.
class Binding {
  const Binding(this.origin);
  final String origin;
}

class Downstream {
  const Downstream(this.binding);
  final Binding binding;
}

final class CoreModule extends PillarModule {
  const CoreModule([this.label = 'default']);

  final String label;

  @override
  void register(PillarContainer container) {
    container.registerSingleton<Binding>(Binding(label));
  }
}

final class FeatureModule extends PillarModule {
  const FeatureModule();

  @override
  List<PillarModule> get dependencies => const [CoreModule()];

  @override
  void register(PillarContainer container) {
    container.registerLazySingleton<Downstream>((c) => Downstream(c.get<Binding>()));
  }
}

final class AsyncModule extends PillarModule {
  const AsyncModule();

  @override
  void register(PillarContainer container) {
    container.registerAsyncSingleton<Binding>(
      (_) async => const Binding('awaited'),
      name: 'async',
    );
  }
}

final class CycleA extends PillarModule {
  const CycleA();

  @override
  List<PillarModule> get dependencies => const [CycleB()];

  @override
  void register(PillarContainer container) {}
}

final class CycleB extends PillarModule {
  const CycleB();

  @override
  List<PillarModule> get dependencies => const [CycleA()];

  @override
  void register(PillarContainer container) {}
}

void main() {
  late PillarContainer container;

  setUp(() => container = PillarContainer());
  tearDown(() => container.dispose());

  test('a module\'s dependencies are registered before it', () async {
    await installModules(container, [const FeatureModule()]);

    expect(container.get<Downstream>().binding.origin, 'default');
  });

  test('a module type is installed once, however often it appears', () async {
    await installModules(container, [
      const CoreModule(),
      const FeatureModule(), // also depends on CoreModule
    ]);

    expect(container.get<Binding>().origin, 'default');
  });

  test('an explicitly passed module beats the one a dependency would supply', () async {
    await installModules(container, [
      const FeatureModule(),
      const CoreModule('configured'),
    ]);

    expect(
      container.get<Downstream>().binding.origin,
      'configured',
      reason: 'the application configures a module that another package also needs',
    );
  });

  test('installing resolves eager asynchronous bindings', () async {
    await installModules(container, [const AsyncModule()]);

    expect(container.get<Binding>(name: 'async').origin, 'awaited');
  });

  test('a cycle between modules is reported as the path that produced it', () {
    expect(
      () => installModules(container, [const CycleA()]),
      throwsA(
        isA<ModuleCycleError>().having(
          (e) => e.chain,
          'chain',
          ['CycleA', 'CycleB', 'CycleA'],
        ),
      ),
    );
  });
}
