import 'package:flutter_test/flutter_test.dart';
import 'package:pillar_remote_config/pillar_remote_config.dart';

void main() {
  group('InMemoryRemoteConfigService', () {
    test('serves the values it was given', () {
      final service = InMemoryRemoteConfigService({'greeting': 'hello', 'enabled': true, 'retries': 3, 'ratio': 0.5});

      expect(service.getString('greeting'), 'hello');
      expect(service.getBool('enabled'), isTrue);
      expect(service.getInt('retries'), 3);
      expect(service.getDouble('ratio'), 0.5);
    });

    test('falls back to the default for an unknown key', () {
      final service = InMemoryRemoteConfigService();

      expect(service.getString('missing'), '');
      expect(service.getString('missing', defaultValue: 'fallback'), 'fallback');
      expect(service.getBool('missing', defaultValue: true), isTrue);
      expect(service.getInt('missing', defaultValue: 42), 42);
      expect(service.getDouble('missing', defaultValue: 3.14), 3.14);
    });

    test('falls back rather than throwing when a value has another type', () {
      // Remote config is data someone else controls; a bad type upstream must
      // not take the app down.
      final service = InMemoryRemoteConfigService({'retries': 'not a number'});

      expect(service.getInt('retries', defaultValue: 1), 1);
      expect(service.hasKey('retries'), isTrue);
    });

    test('hasKey reports presence, not truthiness', () {
      final service = InMemoryRemoteConfigService({'enabled': false});

      expect(service.hasKey('enabled'), isTrue);
      expect(service.hasKey('absent'), isFalse);
    });

    test('getAll exposes every value and cannot be mutated through', () {
      final service = InMemoryRemoteConfigService({'a': 1});

      expect(service.getAll(), {'a': 1});
      expect(() => service.getAll()['b'] = 2, throwsUnsupportedError);
    });

    test('setAll replaces the held values', () {
      final service = InMemoryRemoteConfigService({'old': 'gone'});

      service.setAll({'new': 'here'});

      expect(service.hasKey('old'), isFalse);
      expect(service.getString('new'), 'here');
    });

    test('fetchAndActivate reports that nothing was fetched', () async {
      // There is no backend behind this implementation, and saying otherwise
      // would hide a missing one.
      expect(await InMemoryRemoteConfigService().fetchAndActivate(), isFalse);
    });
  });

  group('RemoteConfigRepositoryImpl', () {
    test('reads typed values through the service', () async {
      final repository = RemoteConfigRepositoryImpl(
        service: InMemoryRemoteConfigService({'name': 'pillar', 'count': 7}),
      );

      expect(await repository.getConfig<String>('name'), 'pillar');
      expect(await repository.getConfig<int>('count'), 7);
    });

    test('getAllConfigs returns what the service holds', () async {
      final repository = RemoteConfigRepositoryImpl(service: InMemoryRemoteConfigService({'a': 1, 'b': 'two'}));

      expect(await repository.getAllConfigs(), {'a': 1, 'b': 'two'});
    });
  });
}
