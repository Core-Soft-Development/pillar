#!/usr/bin/env dart
// Lists every hand-written Dart file in the repo, one per line, for `dart
// format` to consume.
//
//   dart run scripts/dart_files.dart | xargs dart format --line-length=120
//
// Generated sources are excluded: formatting them produces diffs that the next
// build_runner run throws away.

import 'dart:io';

const _generatedSuffixes = ['.g.dart', '.freezed.dart', '.gr.dart', '.config.dart', '.mocks.dart'];

const _skippedDirs = {'.dart_tool', '.git', '.fvm', '.idea', 'build', '.symlinks', 'ios', 'macos', 'windows', 'linux'};

void main() {
  final files =
      Directory.current
          .listSync(recursive: true, followLinks: false)
          .whereType<File>()
          .map((f) => f.path)
          .where(_isFormattable)
          .toList()
        ..sort();

  stdout.writeln(files.join('\n'));
}

bool _isFormattable(String path) {
  if (!path.endsWith('.dart')) return false;
  if (_generatedSuffixes.any(path.endsWith)) return false;

  final segments = path.split(Platform.pathSeparator);
  return !segments.any((s) => _skippedDirs.contains(s));
}
