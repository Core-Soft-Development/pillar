import 'package:pillar_core/pillar_core.dart';

/// ExampleRepository demonstrating a simple repository pattern
abstract interface class ExampleRepository implements BaseRepository {
  /// Repository name
  Future<String> getData();
}

/// Implementation of ExampleRepository
class ExampleRepositoryImpl implements ExampleRepository {
  @override
  String get repositoryName => 'ExampleRepository';

  @override
  Future<String> getData() async {
    // Simulate data fetching
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return 'Sample data from repository';
  }
}
