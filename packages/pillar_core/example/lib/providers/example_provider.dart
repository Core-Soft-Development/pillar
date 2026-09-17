import 'package:pillar_core/pillar_core.dart';
import 'package:pillar_core_example/services/example_service.dart';

/// ExampleProvider demonstrating state management and async operations
class ExampleProvider extends BaseProvider {
  /// Constructs an [ExampleProvider].
  ExampleProvider({
    required this.service,
  });

  /// Service for fetching example data
  final ExampleService service;
  String? _data;

  /// Get the fetched data
  String? get data => _data;

  /// Load data asynchronously using the service
  Future<void> loadData() async {
    final result = await executeAsync<String>(
      () => service.fetchData(),
    );

    if (result != null) {
      _data = result;
      notifyListeners();
    }
  }

  /// Clear the fetched data and any errors
  void clearData() {
    _data = null;
    clearError();
    notifyListeners();
  }
}
