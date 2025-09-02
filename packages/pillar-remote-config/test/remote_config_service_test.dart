import 'package:flutter_test/flutter_test.dart';
import 'package:pillar_remote_config/pillar_remote_config.dart';

void main() {
  group('FirebaseRemoteConfigService', () {
    late FirebaseRemoteConfigService service;

    setUp(() {
      service = FirebaseRemoteConfigService();
    });

    test('should return service name', () {
      expect(service.serviceName, equals('FirebaseRemoteConfigService'));
    });

    test('should return default values when not configured', () {
      expect(service.getString('test_key'), equals(''));
      expect(
        service.getString('test_key', defaultValue: 'default'),
        equals('default'),
      );
      expect(service.getBool('test_bool'), equals(false));
      expect(service.getBool('test_bool', defaultValue: true), equals(true));
      expect(service.getInt('test_int'), equals(0));
      expect(service.getInt('test_int', defaultValue: 42), equals(42));
      expect(service.getDouble('test_double'), equals(0.0));
      expect(
        service.getDouble('test_double', defaultValue: 3.14),
        equals(3.14),
      );
    });

    test('should return false for hasKey when not configured', () {
      expect(service.hasKey('any_key'), isFalse);
    });

    test('should simulate fetchAndActivate', () async {
      final result = await service.fetchAndActivate();
      expect(result, isTrue);
    });
  });
}
