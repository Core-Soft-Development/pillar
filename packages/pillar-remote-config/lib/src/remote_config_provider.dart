import 'package:pillar_core/pillar_core.dart';
import 'package:pillar_remote_config/src/remote_config_repository.dart';

/// Provider for remote configuration management
class RemoteConfigProvider extends BaseProvider {
  /// Constructor for RemoteConfigProvider
  RemoteConfigProvider({
    required this.repository,
  });

  /// Repository for remote configuration operations
  final RemoteConfigRepository repository;
  Map<String, dynamic> _configs = {};

  /// Get all configurations
  Map<String, dynamic> get configs => Map.unmodifiable(_configs);

  /// Get a specific configuration value
  T? getConfig<T>(String key) {
    return _configs[key] as T?;
  }

  /// Refresh configurations from remote source
  Future<void> refreshConfigs() async {
    await executeAsync<bool>(
      () async {
        final success = await repository.refreshConfig();
        if (success) {
          _configs = await repository.getAllConfigs();
        }
        return success;
      },
    );
  }

  /// Load a specific configuration
  Future<void> loadConfig<T>(String key) async {
    final value = await executeAsync<T?>(
      () => repository.getConfig<T>(key),
    );

    if (value != null) {
      _configs[key] = value;
      notifyListeners();
    }
  }

  /// Check if a configuration exists
  bool hasConfig(String key) {
    return _configs.containsKey(key);
  }

  /// Clear all configurations
  void clearConfigs() {
    _configs.clear();
    notifyListeners();
  }
}
