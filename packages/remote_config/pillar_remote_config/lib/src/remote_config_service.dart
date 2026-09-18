import 'package:pillar_core/pillar_core.dart';

/// Reads typed configuration values that come from somewhere outside the app.
///
/// This is the contract only. A backend — Firebase Remote Config, a REST
/// endpoint, a file on disk — belongs in its own `pillar_remote_config_*`
/// package, so that an app can swap one for another without touching the code
/// that reads config.
abstract interface class RemoteConfigService implements BaseService {
  /// Get a string value from remote config.
  String getString(String key, {String defaultValue = ''});

  /// Get a boolean value from remote config.
  bool getBool(String key, {bool defaultValue = false});

  /// Get an integer value from remote config.
  int getInt(String key, {int defaultValue = 0});

  /// Get a double value from remote config.
  double getDouble(String key, {double defaultValue = 0.0});

  /// Every value currently held, keyed by config key.
  Map<String, Object?> getAll();

  /// Whether [key] is present.
  bool hasKey(String key);

  /// Fetch the latest values and make them the ones [getString] and friends
  /// return. Returns whether anything was activated.
  Future<bool> fetchAndActivate();
}

/// A [RemoteConfigService] backed by a plain map.
///
/// Useful in tests and as an app's default before a real backend is wired in:
/// it behaves like a remote source that never changes. [fetchAndActivate]
/// reports `false`, since there is nothing to fetch.
class InMemoryRemoteConfigService implements RemoteConfigService {
  /// Creates a service serving [values].
  InMemoryRemoteConfigService([Map<String, Object?> values = const {}]) : _values = Map.of(values);

  final Map<String, Object?> _values;

  @override
  String get serviceName => 'InMemoryRemoteConfigService';

  /// Replaces the held values, as a real backend would on activation.
  void setAll(Map<String, Object?> values) {
    _values
      ..clear()
      ..addAll(values);
  }

  @override
  String getString(String key, {String defaultValue = ''}) => _read<String>(key) ?? defaultValue;

  @override
  bool getBool(String key, {bool defaultValue = false}) => _read<bool>(key) ?? defaultValue;

  @override
  int getInt(String key, {int defaultValue = 0}) => _read<int>(key) ?? defaultValue;

  @override
  double getDouble(String key, {double defaultValue = 0.0}) => _read<double>(key) ?? defaultValue;

  @override
  Map<String, Object?> getAll() => Map.unmodifiable(_values);

  @override
  bool hasKey(String key) => _values.containsKey(key);

  /// Falls back to the default rather than throwing when a key holds a value
  /// of another type: remote config is data someone else controls, and a type
  /// mismatch should not take the app down.
  T? _read<T>(String key) {
    final value = _values[key];
    return value is T ? value : null;
  }

  @override
  Future<bool> fetchAndActivate() async => false;
}
