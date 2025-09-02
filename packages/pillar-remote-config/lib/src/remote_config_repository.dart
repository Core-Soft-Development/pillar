import 'package:pillar_core/pillar_core.dart';
import 'package:pillar_remote_config/src/remote_config_service.dart';

/// Remote configuration repository interface
abstract interface class RemoteConfigRepository implements BaseRepository {
  /// Get configuration value by key
  Future<T?> getConfig<T>(String key);

  /// Get all configuration values
  Future<Map<String, dynamic>> getAllConfigs();

  /// Refresh configuration from remote source
  Future<bool> refreshConfig();
}

/// Implementation of remote config repository
class RemoteConfigRepositoryImpl implements RemoteConfigRepository {
  /// Constructor for RemoteConfigRepositoryImpl
  const RemoteConfigRepositoryImpl({
    required this.service,
  });

  /// Service for remote configuration operations
  final RemoteConfigService service;

  @override
  String get repositoryName => 'RemoteConfigRepository';

  @override
  Future<T?> getConfig<T>(String key) async {
    if (T == String) {
      return service.getString(key) as T?;
    } else if (T == bool) {
      return service.getBool(key) as T?;
    } else if (T == int) {
      return service.getInt(key) as T?;
    } else if (T == double) {
      return service.getDouble(key) as T?;
    }
    return null;
  }

  @override
  Future<Map<String, dynamic>> getAllConfigs() async {
    // Implementation would return all configs
    return {};
  }

  @override
  Future<bool> refreshConfig() async {
    return service.fetchAndActivate();
  }
}
