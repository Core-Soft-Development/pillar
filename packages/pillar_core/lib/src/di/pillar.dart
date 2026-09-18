import 'package:pillar_core/src/di/pillar_container.dart';
import 'package:pillar_core/src/di/pillar_module.dart';

/// The application-wide container.
///
/// A convenience over holding a [PillarContainer] yourself, for the common case
/// where there is exactly one graph per process:
///
/// ```dart
/// Future<void> main() async {
///   await Pillar.install([PillarNotificationsFirebaseModule()]);
///   runApp(const MyApp());
/// }
/// ```
///
/// Library code should take a [PillarContainer] rather than reach for [Pillar].
/// A package that resolves from the global container cannot be used twice in
/// one process, and its tests have to reset shared state between cases. Pillar
/// packages themselves never touch this class — they register through
/// [PillarModule] and resolve from the container handed to their factories.
abstract final class Pillar {
  static PillarContainer _container = PillarContainer();

  /// The root container.
  static PillarContainer get container => _container;

  /// Registers [modules] into [container] and resolves their asynchronous
  /// bindings. See [installModules].
  static Future<void> install(List<PillarModule> modules) => installModules(_container, modules);

  /// Resolves [T] from the root container.
  static T get<T extends Object>({String? name}) => _container.get<T>(name: name);

  /// Resolves [T] from the root container, awaiting asynchronous bindings.
  static Future<T> getAsync<T extends Object>({String? name}) => _container.getAsync<T>(name: name);

  /// Whether [T] is registered in the root container.
  static bool isRegistered<T extends Object>({String? name}) => _container.isRegistered<T>(name: name);

  /// Opens a scope off the root container.
  static PillarContainer openScope({String? name}) => _container.openScope(name: name);

  /// Disposes the current graph and starts an empty one.
  ///
  /// Call it in `tearDown` when a test has installed modules globally.
  static Future<void> reset() async {
    await _container.dispose();
    _container = PillarContainer();
  }
}
