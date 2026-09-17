#!/usr/bin/env dart
// Enforces the layering rules that make the federated package model hold.
//
//   dart run scripts/validate_deps.dart
//
// Layering only survives if something checks it. Nothing stops an author from
// having one implementation import another, and by the time anyone notices,
// consumers can no longer swap either one out. These rules run in CI.

import 'dart:io';

import 'melos_json.dart';

/// Where a package sits in the stack. Derived from its path and name, so the
/// folder layout is the source of truth rather than a hand-kept list.
enum Tier { bom, core, binding, domain, implementation, tooling, private }

class Package {
  Package(this.name, this.path, this.tier, this.domain);

  final String name;
  final String path;
  final Tier tier;

  /// The domain folder this package belongs to, e.g. `remote_config`.
  final String? domain;

  File get pubspec => File('$path/pubspec.yaml');
}

final violations = <String>[];

Future<void> main() async {
  final packages = await _loadPackages();
  final graph = await _loadGraph();

  for (final p in packages.values) {
    final deps = (graph[p.name] ?? const []).where(packages.containsKey).map((d) => packages[d]!).toList();

    _checkLayering(p, deps);
    if (p.tier == Tier.core) {
      _checkCoreIsPureDart(p);
    }
    if (p.tier != Tier.private) {
      _checkPublishable(p);
    }
  }

  _checkCycles(graph, packages);

  if (violations.isEmpty) {
    stdout.writeln('Dependency graph is valid (${packages.length} packages).');
    return;
  }

  stderr.writeln('Dependency rules violated:\n');
  for (final v in violations) {
    stderr.writeln('  $v');
  }
  stderr.writeln('\nRules are documented in packages/README.md.');
  exit(1);
}

// --- rules -----------------------------------------------------------------

/// Rules 1-3: who may depend on whom.
void _checkLayering(Package p, List<Package> deps) {
  for (final d in deps) {
    switch (p.tier) {
      case Tier.core:
        // Rule 1: the root of the stack depends on nothing above it.
        violations.add(
          '[rule 1] ${p.name} must not depend on any pillar package, '
          'but depends on ${d.name}',
        );

      case Tier.binding:
        // Rule 2: a binding adapts core to one runtime (pillar_flutter) and
        // must not reach across into a domain — otherwise every consumer of
        // that domain inherits the runtime.
        if (d.tier != Tier.core) {
          violations.add(
            '[rule 2] ${p.name} is a binding package and may only depend on '
            'pillar_core, but depends on ${d.name}',
          );
        }

      case Tier.domain:
        // Rule 2: an interface knows the tier-0 packages, and its own platform
        // interface. A domain that renders needs pillar_flutter; one that does
        // not should stay off it, which is a review call rather than a rule.
        final allowed = d.tier == Tier.core || d.tier == Tier.binding || _isPlatformInterfaceOf(d, p);
        if (!allowed) {
          violations.add(
            '[rule 2] ${p.name} is a domain interface and may only depend on '
            'pillar_core or pillar_flutter, but depends on ${d.name}',
          );
        }

      case Tier.implementation:
        // Rule 3: the one that keeps implementations swappable.
        if (d.tier == Tier.implementation) {
          violations.add(
            '[rule 3] ${p.name} is an implementation and must not depend on '
            'another implementation (${d.name}) — depend on the interface',
          );
        } else if (d.tier == Tier.domain && d.domain != p.domain) {
          violations.add(
            '[rule 3] ${p.name} implements "${p.domain}" but depends on the '
            '"${d.domain}" interface (${d.name})',
          );
        }

      case Tier.tooling:
      case Tier.bom:
      case Tier.private:
        break;
    }
  }
}

/// Rule 7: pillar_core stays pure Dart.
///
/// It is the one package every other package depends on. The moment it pulls in
/// the Flutter SDK, every interface in the framework does too, and none of them
/// can be used from a server, a CLI, or a plain `dart test` run. The Flutter
/// bindings live in pillar_flutter for exactly this reason.
void _checkCoreIsPureDart(Package p) {
  if (p.pubspec.existsSync()) {
    final spec = p.pubspec.readAsStringSync();
    if (RegExp(r'^\s*flutter:', multiLine: true).hasMatch(spec)) {
      violations.add(
        '[rule 7] ${p.name} must stay pure Dart, but its pubspec.yaml mentions '
        'flutter — move whatever needs it to pillar_flutter',
      );
    }
  }

  for (final dir in ['lib', 'test']) {
    final directory = Directory('${p.path}/$dir');
    if (!directory.existsSync()) continue;
    for (final file in directory.listSync(recursive: true).whereType<File>()) {
      if (!file.path.endsWith('.dart')) continue;
      if (file.readAsStringSync().contains('package:flutter/')) {
        final relative = file.path.replaceFirst('${p.path}/', '');
        violations.add('[rule 7] ${p.name}/$relative imports package:flutter — it must stay pure Dart');
      }
    }
  }
}

/// Rules 5-6: what pub.dev needs before it will take the package.
void _checkPublishable(Package p) {
  if (!p.pubspec.existsSync()) return;
  final spec = p.pubspec.readAsStringSync();

  // Rule 5. A path dependency is rejected by pub.dev at publish time; the pub
  // workspace resolves sibling packages from a version constraint instead.
  if (RegExp(r'^\s+path:\s', multiLine: true).hasMatch(spec)) {
    violations.add(
      '[rule 5] ${p.name} declares a path: dependency, which pub.dev rejects — '
      'use a version constraint and let melos bootstrap override it',
    );
  }

  // Rule 6. The BoM holds no code, so it is exempt from the changelog.
  for (final field in ['homepage', 'repository', 'issue_tracker']) {
    if (!RegExp('^$field:', multiLine: true).hasMatch(spec)) {
      violations.add('[rule 6] ${p.name} is missing `$field:` in pubspec.yaml');
    }
  }

  final description = _description(spec);
  if (description == null || description.length < 60) {
    violations.add(
      '[rule 6] ${p.name} needs a description of at least 60 characters '
      '(has ${description?.length ?? 0}) — pana scores on it',
    );
  }

  for (final file in ['LICENSE', if (p.tier != Tier.bom) 'CHANGELOG.md']) {
    if (!File('${p.path}/$file').existsSync()) {
      violations.add('[rule 6] ${p.name} is missing $file');
    }
  }
}

/// Reads `description:` from a pubspec, including the folded form
/// (`description: >-` followed by indented lines), which is how any description
/// long enough to satisfy rule 6 is actually written.
String? _description(String spec) {
  final lines = spec.split('\n');
  final start = lines.indexWhere((l) => l.startsWith('description:'));
  if (start == -1) return null;

  final inline = lines[start].substring('description:'.length).trim();
  if (inline.isNotEmpty && inline != '>' && inline != '>-' && inline != '|' && inline != '|-') {
    return inline;
  }

  final folded = <String>[];
  for (final line in lines.skip(start + 1)) {
    if (line.trim().isEmpty) break;
    if (!line.startsWith(' ') && !line.startsWith('\t')) break;
    folded.add(line.trim());
  }
  return folded.isEmpty ? null : folded.join(' ');
}

/// Rule 4: no cycles. Iterative DFS over the internal graph.
void _checkCycles(Map<String, List<String>> graph, Map<String, Package> known) {
  final visiting = <String>{};
  final done = <String>{};
  final reported = <String>{};

  void visit(String node, List<String> stack) {
    if (done.contains(node)) return;
    if (!visiting.add(node)) {
      final cycle = [...stack.sublist(stack.indexOf(node)), node];
      final signature = (cycle.toList()..sort()).join();
      if (reported.add(signature)) {
        violations.add('[rule 4] dependency cycle: ${cycle.join(" -> ")}');
      }
      return;
    }
    for (final next in graph[node] ?? const <String>[]) {
      if (known.containsKey(next)) visit(next, [...stack, node]);
    }
    visiting.remove(node);
    done.add(node);
  }

  for (final node in graph.keys) {
    if (known.containsKey(node)) visit(node, []);
  }
}

// --- loading ---------------------------------------------------------------

bool _isPlatformInterfaceOf(Package dep, Package p) => dep.name == '${p.name}_platform_interface';

Future<Map<String, Package>> _loadPackages() async {
  final entries = (await melosJson(['list', '--json'])) as List;
  final packages = <String, Package>{};

  for (final entry in entries.cast<Map<String, dynamic>>()) {
    final name = entry['name'] as String;
    final path = entry['location'] as String;
    final isPrivate = entry['private'] == true;
    packages[name] = Package(name, path, _tierOf(name, path, isPrivate), _domainOf(path));
  }
  return packages;
}

Future<Map<String, List<String>>> _loadGraph() async {
  final graph = (await melosJson(['list', '--graph'])) as Map<String, dynamic>;
  return graph.map((k, v) => MapEntry(k, (v as List).cast<String>()));
}

/// `packages/remote_config/pillar_remote_config` -> `remote_config`.
/// Top-level packages (`packages/pillar_core`) have no domain.
String? _domainOf(String path) {
  final parts = path.split(Platform.pathSeparator);
  final i = parts.lastIndexOf('packages');
  if (i == -1 || parts.length - i < 3) return null;
  return parts[i + 1];
}

Tier _tierOf(String name, String path, bool isPrivate) {
  if (isPrivate) return Tier.private;
  if (name == 'pillar') return Tier.bom;
  if (name == 'pillar_core') return Tier.core;

  final domain = _domainOf(path);
  // A published package that sits at the top level rather than inside a domain
  // folder adapts core to a runtime: pillar_flutter today.
  if (domain == null) return Tier.binding;
  if (domain == 'testing' || domain == 'tooling') return Tier.tooling;

  // pillar_remote_config == the interface; pillar_remote_config_firebase, an
  // implementation of it.
  return name == 'pillar_$domain' ? Tier.domain : Tier.implementation;
}
