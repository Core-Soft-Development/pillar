import 'package:flutter/foundation.dart';

/// Base class for presentation-layer state holders.
///
/// Holds the loading and error state a screen needs, and runs an asynchronous
/// operation with both handled ([executeAsync]).
///
/// Lives in `pillar_flutter` rather than `pillar_core` because it extends
/// [ChangeNotifier], which is Flutter's. Register one with
/// `container.registerFactory<MyProvider>(...)` so each screen gets its own.
abstract class BaseProvider extends ChangeNotifier {
  /// Constructs a [BaseProvider].
  BaseProvider() : _isDisposed = false;

  bool _isDisposed;
  bool _isLoading = false;
  String? _error;

  /// Check if the provider is disposed
  bool get isDisposed => _isDisposed;

  /// Check if the provider is in loading state
  bool get isLoading => _isLoading;

  /// Get current error message
  String? get error => _error;

  /// Check if there's an error
  bool get hasError => _error != null;

  /// Sets the loading state, notifying listeners when it actually changes.
  @protected
  void setLoading(bool loading) {
    if (_isDisposed || _isLoading == loading) return;
    _isLoading = loading;
    notifyListeners();
  }

  /// Sets the error message, notifying listeners when it actually changes.
  @protected
  void setError(String? error) {
    if (_isDisposed || _error == error) return;
    _error = error;
    notifyListeners();
  }

  /// Clears the error, if there is one.
  @protected
  void clearError() => setError(null);

  /// Execute an async operation with loading and error handling
  @protected
  Future<T?> executeAsync<T>(
    Future<T> Function() operation, {
    bool showLoading = true,
    bool clearPreviousError = true,
  }) async {
    if (_isDisposed) return null;

    try {
      if (clearPreviousError) clearError();
      if (showLoading) setLoading(true);

      final result = await operation();
      return result;
    } catch (error) {
      setError(error.toString());
      return null;
    } finally {
      if (showLoading) setLoading(false);
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }
}
