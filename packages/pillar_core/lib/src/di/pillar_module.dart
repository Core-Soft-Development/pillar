import 'package:pillar_core/src/di/di_errors.dart';
import 'package:pillar_core/src/di/pillar_container.dart';

/// One package's contribution to the dependency graph.
///
/// Every Pillar package ships a module instead of asking consumers to wire its
/// internals by hand. An application names the modules it wants, and the
/// bindings, their order and their asynchronous setup follow:
///
/// ```dart
/// await Pillar.install([
///   PillarRemoteConfigFirebaseModule(app: firebaseApp),
///   PillarNotificationsFirebaseModule(),
/// ]);
/// ```
///
/// A module registers the implementations it owns against the interfaces
/// declared by its tier-1 package. That is the seam: swapping a vendor means
/// swapping one module in the list above, and nothing else in the application
/// changes.
abstract base class PillarModule {
  /// Creates a module.
  const PillarModule();

  /// Modules that must be registered before this one.
  ///
  /// Declare what you resolve in [register], not everything you can imagine
  /// wanting. Duplicates across the graph are installed once.
  List<PillarModule> get dependencies => const <PillarModule>[];

  /// Registers this package's bindings into [container].
  ///
  /// Keep it synchronous. Anything that needs to await belongs in
  /// [PillarContainer.registerAsyncSingleton], which `installModules` resolves
  /// afterwards, in dependency order.
  void register(PillarContainer container);

  /// Name used in diagnostics.
  String get debugName => '$runtimeType';
}

/// Registers [modules] into [container] in dependency order, then resolves
/// every eager asynchronous binding.
///
/// A module type is installed once, however many times it appears in the graph.
/// When a module is passed explicitly *and* pulled in as someone else's
/// dependency, the explicit instance wins — that is how an application
/// configures a module that another package also depends on.
///
/// Throws [ModuleCycleError] if the modules depend on each other in a loop.
Future<void> installModules(PillarContainer container, List<PillarModule> modules) async {
  for (final module in _sorted(modules)) {
    module.register(container);
  }
  await container.ready();
}

List<PillarModule> _sorted(List<PillarModule> roots) {
  // Explicitly passed instances take precedence over the defaults a dependency
  // graph would otherwise supply.
  final explicit = <Type, PillarModule>{for (final module in roots) module.runtimeType: module};

  final ordered = <PillarModule>[];
  final installed = <Type>{};
  final visiting = <Type>{};

  void visit(PillarModule module, List<String> stack) {
    final resolved = explicit[module.runtimeType] ?? module;
    final type = resolved.runtimeType;

    if (installed.contains(type)) return;
    if (!visiting.add(type)) {
      final start = stack.indexOf(resolved.debugName);
      throw ModuleCycleError([...stack.sublist(start), resolved.debugName]);
    }

    for (final dependency in resolved.dependencies) {
      visit(dependency, [...stack, resolved.debugName]);
    }

    visiting.remove(type);
    installed.add(type);
    ordered.add(resolved);
  }

  for (final module in roots) {
    visit(module, const []);
  }
  return ordered;
}
