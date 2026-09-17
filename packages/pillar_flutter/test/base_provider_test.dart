import 'package:flutter_test/flutter_test.dart';
import 'package:pillar_flutter/pillar_flutter.dart';

class _Provider extends BaseProvider {
  Future<String?> run(Future<String> Function() operation) => executeAsync(operation);
}

void main() {
  test('a successful operation clears loading and leaves no error', () async {
    final provider = _Provider();
    final notifications = <bool>[];
    provider.addListener(() => notifications.add(provider.isLoading));

    final result = await provider.run(() async => 'done');

    expect(result, 'done');
    expect(provider.isLoading, isFalse);
    expect(provider.hasError, isFalse);
    expect(notifications, [true, false], reason: 'loading is raised, then lowered');
  });

  test('a failing operation records the error and returns null', () async {
    final provider = _Provider();

    final result = await provider.run(() async => throw StateError('boom'));

    expect(result, isNull);
    expect(provider.hasError, isTrue);
    expect(provider.error, contains('boom'));
    expect(provider.isLoading, isFalse);
  });

  test('a disposed provider stops notifying', () async {
    final provider = _Provider();
    var notified = 0;
    provider
      ..addListener(() => notified++)
      ..dispose();

    await provider.run(() async => 'ignored');

    expect(provider.isDisposed, isTrue);
    expect(notified, 0);
  });
}
