import 'package:pillar_core/pillar_core.dart';

/// Remote configuration service interface
abstract interface class RemoteConfigService implements BaseService {
  /// Get a string value from remote config
  String getString(String key, {String defaultValue = ''});

  /// Get a boolean value from remote config
  bool getBool(String key, {bool defaultValue = false});

  /// Get an integer value from remote config
  int getInt(String key, {int defaultValue = 0});

  /// Get a double value from remote config
  double getDouble(String key, {double defaultValue = 0.0});

  /// Fetch and activate remote config
  Future<bool> fetchAndActivate();

  /// Check if a key exists in remote config
  bool hasKey(String key);
}

/// Firebase implementation of remote config service
class FirebaseRemoteConfigService implements RemoteConfigService {
  @override
  String get serviceName => 'FirebaseRemoteConfigService';

  @override
  String getString(String key, {String defaultValue = ''}) {
    // Firebase implementation would go here
    return defaultValue;
  }

  @override
  bool getBool(String key, {bool defaultValue = false}) {
    // Firebase implementation would go here
    return defaultValue;
  }

  @override
  int getInt(String key, {int defaultValue = 0}) {
    // Firebase implementation would go here
    return defaultValue;
  }

  @override
  double getDouble(String key, {double defaultValue = 0.0}) {
    // Firebase implementation would go here
    return defaultValue;
  }

  @override
  Future<bool> fetchAndActivate() async {
    // Firebase implementation would go here
    await Future<void>.delayed(const Duration(seconds: 1));
    return true;
  }

  @override
  bool hasKey(String key) {
    // Firebase implementation would go here
    return false;
  }
}
