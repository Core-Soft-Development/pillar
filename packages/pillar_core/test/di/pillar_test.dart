import 'package:pillar_core/pillar_core.dart';
import 'package:test/test.dart';

class Binding {
  const Binding(this.origin);
  final String origin;
}

final class AppModule extends PillarModule {
  const AppModule();

  @override
  void register(PillarContainer container) {
    container.registerSingleton<Binding>(const Binding('installed'));
  }
}

void main() {
  tearDown(Pillar.reset);

  test('install registers into the root container', () async {
    await Pillar.install([const AppModule()]);

    expect(Pillar.get<Binding>().origin, 'installed');
    expect(Pillar.container.get<Binding>().origin, 'installed');
  });

  test('reset disposes the graph and starts an empty one', () async {
    await Pillar.install([const AppModule()]);
    final first = Pillar.container;

    await Pillar.reset();

    expect(Pillar.isRegistered<Binding>(), isFalse);
    expect(identical(Pillar.container, first), isFalse);
  });

  test('a scope off the root shadows it without mutating it', () async {
    await Pillar.install([const AppModule()]);
    final scope = Pillar.openScope()..registerSingleton<Binding>(const Binding('fake'));

    expect(scope.get<Binding>().origin, 'fake');
    expect(Pillar.get<Binding>().origin, 'installed');
  });
}
