/// Base interface for all services
/// Services contain business logic and coordinate between different layers
abstract interface class BaseService {
  /// Service identifier for debugging and logging
  String get serviceName;
}

/// Base interface for services that can be initialized
abstract interface class InitializableService extends BaseService {
  /// Initialize the service
  Future<void> initialize();

  /// Dispose resources used by the service
  Future<void> dispose();

  /// Check if the service is initialized
  bool get isInitialized;
}
