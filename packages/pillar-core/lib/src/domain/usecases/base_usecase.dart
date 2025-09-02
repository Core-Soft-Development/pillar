import 'package:meta/meta.dart';

/// Base interface for all use cases
/// Use cases represent application-specific business rules
abstract interface class BaseUseCase<TResult, TParams> {
  /// Execute the use case with given parameters
  Future<TResult> execute(TParams params);
}

/// Base use case for operations that don't require parameters
abstract interface class NoParamsUseCase<TResult> {
  /// Execute the use case without parameters
  Future<TResult> execute();
}

/// Base use case for synchronous operations
abstract interface class SyncUseCase<TResult, TParams> {
  /// Execute the use case synchronously with given parameters
  TResult execute(TParams params);
}

/// Base use case for synchronous operations that don't require parameters
abstract interface class SyncNoParamsUseCase<TResult> {
  /// Execute the use case synchronously without parameters
  TResult execute();
}

/// Parameters wrapper for use cases
@immutable
abstract class UseCaseParams {
  const UseCaseParams();
}

/// Empty parameters for use cases that don't need parameters
class NoParams extends UseCaseParams {
  const NoParams();
}
