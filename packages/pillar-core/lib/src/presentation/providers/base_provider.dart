import 'package:flutter/foundation.dart';

/// Base class for all presentation providers
/// Providers manage UI state and handle user interactions
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

  /// Set loading state
  @protected
  void setLoading(bool loading) {
    if (_isDisposed) return;
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error message
  @protected
  void setError(String? error) {
    if (_isDisposed) return;
    _error = error;
    notifyListeners();
  }

  /// Clear error
  @protected
  void clearError() {
    if (_isDisposed) return;
    _error = null;
    notifyListeners();
  }

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
