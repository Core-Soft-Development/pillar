#!/usr/bin/env dart
// Creates one GitHub release per package that melos just tagged, plus a
// summary release for the BoM.
//
//   dart run scripts/github_releases.dart [--dry-run]
//
// The body of each release is the matching section of that package's
// CHANGELOG.md — the one melos generated from conventional commits. Nobody
// consuming pillar_webview should have to read a monorepo-wide changelog to
// find out what changed for them.
//
// Requires `gh` to be authenticated (GH_TOKEN in CI).

import 'dart:io';

import 'melos_json.dart';

const bomName = 'pillar';

Future<void> main(List<String> args) async {
  final dryRun = args.contains('--dry-run');
  final packages = await _packages();

  // Tags melos created in the commit it just made. Anything already released
  // is skipped, so re-running the job is safe.
  final tags = await _tagsAtHead();
  if (tags.isEmpty) {
    stdout.writeln('No release tags at HEAD — nothing to publish.');
    return;
  }

  final released = <String, String>{};

  for (final tag in tags) {
    final package = packages.keys.firstWhere((name) => tag == '$name-v${packages[name]}', orElse: () => '');
    if (package.isEmpty) {
      stdout.writeln('Skipping $tag: no package matches it.');
      continue;
    }
    if (await _releaseExists(tag)) {
      stdout.writeln('Skipping $tag: release already exists.');
      continue;
    }

    final version = packages[package]!;
    final notes = _changelogSection(package, version) ?? 'See CHANGELOG.md for details.';

    await _createRelease(tag: tag, title: '$package v$version', body: notes, dryRun: dryRun);
    released[package] = version;
  }

  // The BoM release ties the set together: one page listing what shipped and
  // linking to each package's own notes.
  final bomTag = tags.firstWhere((t) => t.startsWith('$bomName-v'), orElse: () => '');
  if (bomTag.isNotEmpty && !await _releaseExists(bomTag) && released.isNotEmpty) {
    final bomVersion = bomTag.substring(bomName.length + 2);
    await _createRelease(
      tag: bomTag,
      title: 'Pillar BoM $bomVersion',
      body: _bomNotes(bomVersion, released),
      dryRun: dryRun,
    );
  }

  stdout.writeln('Done — ${released.length} package release(s).');
}

String _bomNotes(String bomVersion, Map<String, String> released) {
  final repo = Platform.environment['GITHUB_REPOSITORY'] ?? 'Core-Soft-Development/pillar';
  final lines = (released.keys.toList()..sort()).map((name) {
    final version = released[name]!;
    return '- [`$name` $version](https://github.com/$repo/releases/tag/$name-v$version) '
        '· [pub.dev](https://pub.dev/packages/$name/versions/$version)';
  });

  return '''
This Bill of Materials pins the set of packages released together below.

```yaml
dependencies:
  $bomName: ^$bomVersion
```

## Packages in this set

${lines.join('\n')}
''';
}

/// The section of a package's CHANGELOG.md describing [version].
///
/// melos writes `## 1.2.0` headings, so we take everything from that heading
/// up to the next one.
String? _changelogSection(String package, String version) {
  final path = '${_locations[package]}/CHANGELOG.md';
  final file = File(path);
  if (!file.existsSync()) return null;

  final lines = file.readAsLinesSync();
  final heading = RegExp(r'^(#{1,6})\s');

  final start = lines.indexWhere((l) => heading.hasMatch(l) && l.contains(version));
  if (start == -1) return null;

  // Stop at the next heading of the same level or higher. Stopping at any
  // heading would cut the body off at its own "### Added" subsection.
  final level = heading.firstMatch(lines[start])!.group(1)!.length;
  final rest = lines.skip(start + 1).toList();
  final end = rest.indexWhere((l) {
    final match = heading.firstMatch(l);
    return match != null && match.group(1)!.length <= level;
  });

  final body = (end == -1 ? rest : rest.take(end)).join('\n').trim();
  return body.isEmpty ? null : body;
}

final _locations = <String, String>{};

Future<Map<String, String>> _packages() async {
  final entries = ((await melosJson(['list', '--json', '--no-private'])) as List).cast<Map<String, dynamic>>();

  for (final e in entries) {
    _locations[e['name'] as String] = e['location'] as String;
  }
  return {for (final e in entries) e['name'] as String: e['version'] as String};
}

Future<List<String>> _tagsAtHead() async {
  final raw = await _run('git', ['tag', '--points-at', 'HEAD']);
  return raw.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
}

Future<bool> _releaseExists(String tag) async {
  final result = await Process.run('gh', ['release', 'view', tag], runInShell: true);
  return result.exitCode == 0;
}

Future<void> _createRelease({
  required String tag,
  required String title,
  required String body,
  required bool dryRun,
}) async {
  if (dryRun) {
    stdout.writeln('[dry-run] would create release $tag ("$title") with notes:');
    stdout.writeln(body.split('\n').map((l) => '    $l').join('\n'));
    return;
  }

  final notes = File('${Directory.systemTemp.path}/$tag.md')..writeAsStringSync(body);
  await _run('gh', ['release', 'create', tag, '--title', title, '--notes-file', notes.path, '--verify-tag']);
  stdout.writeln('Created release $tag');
}

Future<String> _run(String executable, List<String> args) async {
  final result = await Process.run(executable, args, runInShell: true);
  if (result.exitCode != 0) {
    stderr.writeln('$executable ${args.join(" ")} failed:\n${result.stderr}');
    exit(result.exitCode);
  }
  return result.stdout as String;
}
