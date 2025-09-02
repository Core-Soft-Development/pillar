import 'package:pillar_core/pillar_core.dart';
import 'package:pillar_core_example/services/example_service.dart';

class ExampleProvider extends BaseProvider {
  ExampleProvider({
    required this.service,
  });

  final ExampleService service;
  String? _data;

  String? get data => _data;

  Future<void> loadData() async {
    final result = await executeAsync<String>(
      () => service.fetchData(),
    );

    if (result != null) {
      _data = result;
      notifyListeners();
    }
  }

  void clearData() {
    _data = null;
    clearError();
    notifyListeners();
  }
}
