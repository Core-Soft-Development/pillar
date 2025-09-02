/// Base interface for all repositories
/// Repositories define contracts for data access
abstract interface class BaseRepository {
  /// Repository identifier for debugging and logging
  String get repositoryName;
}
