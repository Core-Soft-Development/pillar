#!/usr/bin/env dart
// Generates and verifies the `pillar` BoM (Bill of Materials).
//
// The BoM holds no code. It pins one exact version of every published
// pillar_* package, so a consumer can depend on a set that was released and
// tested together instead of resolving six constraints by hand.
//
//   dart run scripts/bom.dart sync     # rewrite the BoM from current versions
//   dart run scripts/bom.dart verify   # fail if the BoM has drifted
//
// The BoM is versioned by calendar (2026.09.0), not semver: it tracks no API
// of its own, so a semver bump would imply a promise it cannot make.

import 'dart:convert';
import 'dart:io';

const bomName = 'pillar';
const bomPath = 'packages/pillar/pubspec.yaml';

Future<void> main(List<String> args) async {
  final mode = args.isEmpty ? 'verify' : args.first;
  if (mode != 'sync' && mode != 'verify') {
    stderr.writeln('usage: dart run scripts/bom.dart <sync|verify>');
    exit(64);
  }

  final members = await _publishedPackages();
  if (members.isEmpty) {
    stderr.writeln('No publishable packages found — is melos bootstrapped?');
    exit(1);
  }

  final bomFile = File(bomPath);
  final current = bomFile.existsSync() ? bomFile.readAsStringSync() : null;
  final version = _nextBomVersion(current);
  final generated = _renderBom(version, members);

  if (mode == 'sync') {
    bomFile.parent.createSync(recursive: true);
    bomFile.writeAsStringSync(generated);
    stdout.writeln('BoM $bomName $version pins ${members.length} packages:');
    members.forEach((name, v) => stdout.writeln('  $name $v'));
    return;
  }

  // verify: compare the pinned set, ignoring the BoM's own version so that a
  // check run outside a release does not fail on the calendar rolling over.
  final pinned = _parsePins(current);
  if (_sameSet(pinned, members)) {
    stdout.writeln('BoM is in sync (${members.length} packages).');
    return;
  }

  stderr.writeln('BoM is out of sync with published package versions.\n');
  for (final name in {...pinned.keys, ...members.keys}.toList()..sort()) {
    final was = pinned[name];
    final now = members[name];
    if (was == now) continue;
    if (was == null) stderr.writeln('  + $name $now (missing from BoM)');
    if (now == null) stderr.writeln('  - $name $was (no longer published)');
    if (was != null && now != null) stderr.writeln('  ~ $name $was -> $now');
  }
  stderr.writeln('\nRun: melos run bom:sync');
  exit(1);
}

/// Every package melos would publish, minus the BoM itself.
Future<Map<String, String>> _publishedPackages() async {
  final result = await Process.run(
    'melos',
    ['list', '--json', '--no-private'],
    runInShell: true,
  );
  if (result.exitCode != 0) {
    stderr.writeln('melos list failed:\n${result.stderr}');
    exit(result.exitCode);
  }

  final packages = (jsonDecode(result.stdout as String) as List)
      .cast<Map<String, dynamic>>()
      .where((p) => p['name'] != bomName);

  return {
    for (final p in packages) p['name'] as String: p['version'] as String,
  }..removeWhere((_, v) => v.isEmpty);
}

/// `YYYY.MM.N` — N resets when the month changes, increments within it.
String _nextBomVersion(String? current) {
  final now = DateTime.now();
  final prefix = '${now.year}.${now.month.toString().padLeft(2, '0')}';

  final previous = current == null
      ? null
      : RegExp(r'^version:\s*(\S+)', multiLine: true).firstMatch(current)?.group(1);

  if (previous != null && previous.startsWith('$prefix.')) {
    final patch = int.tryParse(previous.split('.').last) ?? 0;
    return '$prefix.${patch + 1}';
  }
  return '$prefix.0';
}

Map<String, String> _parsePins(String? pubspec) {
  if (pubspec == null) return {};
  final deps = RegExp(r'^dependencies:$', multiLine: true).firstMatch(pubspec);
  if (deps == null) return {};

  final body = pubspec.substring(deps.end);
  final entry = RegExp(r'^  (pillar_\w+):\s*(\S+)\s*$', multiLine: true);
  return {
    for (final m in entry.allMatches(body)) m.group(1)!: m.group(2)!,
  };
}

bool _sameSet(Map<String, String> a, Map<String, String> b) =>
    a.length == b.length && a.keys.every((k) => a[k] == b[k]);

String _renderBom(String version, Map<String, String> members) {
  final names = members.keys.toList()..sort();
  final pins = names.map((n) => '  $n: ${members[n]}').join('\n');

  return '''
# GENERATED FILE — do not edit by hand.
# Regenerate with: melos run bom:sync
#
# Versions are exact, not caret ranges. A BoM that allowed resolution to drift
# would guarantee nothing; the point is a set that CI released together.
name: $bomName
description: Bill of Materials for the Pillar framework — pins one compatible, released set of pillar_* package versions.
version: $version
homepage: https://github.com/Core-Soft-Development/pillar
repository: https://github.com/Core-Soft-Development/pillar
issue_tracker: https://github.com/Core-Soft-Development/pillar/issues

environment:
  sdk: ">=3.6.0 <4.0.0"
  flutter: ">=3.35.0"

dependencies:
$pins
''';
}
