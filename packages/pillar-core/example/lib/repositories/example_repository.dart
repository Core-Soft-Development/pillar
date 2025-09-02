import 'package:pillar_core/pillar_core.dart';

abstract interface class ExampleRepository implements BaseRepository {
  Future<String> getData();
}

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
