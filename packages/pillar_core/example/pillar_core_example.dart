// Run with: dart run example/pillar_core_example.dart
//
// Shows how a Pillar package contributes to the graph: a module registers the
// bindings it owns, an application names the modules it wants, and the wiring
// between them is the injector's job.

import 'package:pillar_core/pillar_core.dart';

// --- what a tier-1 package declares ----------------------------------------

abstract interface class Clock {
  DateTime now();
}

abstract interface class Greeter {
  Future<String> greet(String name);
}

// --- what an implementation package provides --------------------------------

class SystemClock implements Clock {
  @override
  DateTime now() => DateTime.now();
}

class RemoteGreeter implements Greeter {
  RemoteGreeter({required this.clock, required this.template});

  final Clock clock;
  final String template;
  var _closed = false;

  @override
  Future<String> greet(String name) async {
    if (_closed) throw StateError('greeter is closed');
    await Future<void>.delayed(const Duration(milliseconds: 20));
    return template.replaceAll('{name}', name).replaceAll('{hour}', '${clock.now().hour}');
  }

  void close() => _closed = true;
}

/// Each package ships one of these instead of asking consumers to wire it.
final class ClockModule extends PillarModule {
  const ClockModule();

  @override
  void register(PillarContainer container) {
    container.registerLazySingleton<Clock>((_) => SystemClock());
  }
}

final class GreeterModule extends PillarModule {
  const GreeterModule();

  /// Declared, so the injector registers ClockModule first whatever order the
  /// application lists them in.
  @override
  List<PillarModule> get dependencies => const [ClockModule()];

  @override
  void register(PillarContainer container) {
    // Asynchronous because a real one would be fetching a template, opening a
    // channel or waiting on a platform SDK. `installModules` awaits it.
    container.registerAsyncSingleton<Greeter>(
      (c) async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        return RemoteGreeter(clock: c.get<Clock>(), template: 'Hello {name}, it is {hour}h');
      },
      // Runs when the container is disposed, in reverse registration order.
      dispose: (greeter) => (greeter as RemoteGreeter).close(),
    );
  }
}

// --- what the application does ----------------------------------------------

Future<void> main() async {
  final container = PillarContainer();

  // Order does not matter: GreeterModule declares what it needs.
  await installModules(container, [const GreeterModule()]);

  // Resolved synchronously: ready() already awaited the asynchronous binding.
  print(await container.get<Greeter>().greet('Ada'));

  // A scope shadows a binding without touching the parent — how a test swaps a
  // dependency, and how a feature gets one that lives only as long as it does.
  //
  // It shadows the binding, not instances already built from it: shadowing
  // Clock here would change nothing, because the greeter singleton was
  // constructed above and holds the real one. Shadow what you want replaced.
  final scope = container.openScope(name: 'test')..registerSingleton<Greeter>(_FakeGreeter());

  print('scope sees:  ${await scope.get<Greeter>().greet('Ada')}');
  print('parent sees: ${await container.get<Greeter>().greet('Ada')}');

  // Disposes the scope, then everything the container built, newest first.
  await container.dispose();
}

class _FakeGreeter implements Greeter {
  @override
  Future<String> greet(String name) async => 'Hi $name (fake)';
}
