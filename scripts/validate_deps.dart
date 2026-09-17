#!/usr/bin/env dart
// Enforces the layering rules that make the federated package model hold.
//
//   dart run scripts/validate_deps.dart
//
// Layering only survives if something checks it. Nothing stops an author from
// having one implementation import another, and by the time anyone notices,
// consumers can no longer swap either one out. These rules run in CI.

import 'dart:convert';
import 'dart:io';

/// Where a package sits in the stack. Derived from its path and name, so the
/// folder layout is the source of truth rather than a hand-kept list.
enum Tier { bom, core, domain, implementation, tooling, private }

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
    final deps = (graph[p.name] ?? const [])
        .where(packages.containsKey)
        .map((d) => packages[d]!)
        .toList();

    _checkLayering(p, deps);
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

      case Tier.domain:
        // Rule 2: an interface knows core, and its own platform interface.
        final allowed = d.tier == Tier.core || _isPlatformInterfaceOf(d, p);
        if (!allowed) {
          violations.add(
            '[rule 2] ${p.name} is a domain interface and may only depend on '
            'pillar_core, but depends on ${d.name}',
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

/// Rules 5-6: what pub.dev needs before it will take the package.
void _checkPublishable(Package p) {
  if (!p.pubspec.existsSync()) return;
  final spec = p.pubspec.readAsStringSync();

  // Rule 5. A path dependency is rejected by pub.dev at publish time; melos
  // supplies the local path through a generated pubspec_overrides.yaml.
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

  final description = RegExp(r'^description:\s*(.+)$', multiLine: true)
      .firstMatch(spec)
      ?.group(1)
      ?.trim();
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

bool _isPlatformInterfaceOf(Package dep, Package p) =>
    dep.name == '${p.name}_platform_interface';

Future<Map<String, Package>> _loadPackages() async {
  final raw = await _melos(['list', '--json']);
  final packages = <String, Package>{};

  for (final entry in (jsonDecode(raw) as List).cast<Map<String, dynamic>>()) {
    final name = entry['name'] as String;
    final path = entry['location'] as String;
    final isPrivate = entry['private'] == true;
    packages[name] = Package(name, path, _tierOf(name, path, isPrivate), _domainOf(path));
  }
  return packages;
}

Future<Map<String, List<String>>> _loadGraph() async {
  final raw = await _melos(['list', '--graph']);
  return (jsonDecode(raw) as Map<String, dynamic>)
      .map((k, v) => MapEntry(k, (v as List).cast<String>()));
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
  if (domain == null) return Tier.tooling;
  if (domain == 'testing' || domain == 'tooling') return Tier.tooling;

  // pillar_remote_config == the interface; pillar_remote_config_firebase, an
  // implementation of it.
  return name == 'pillar_$domain' ? Tier.domain : Tier.implementation;
}

Future<String> _melos(List<String> args) async {
  final result = await Process.run('melos', args, runInShell: true);
  if (result.exitCode != 0) {
    stderr.writeln('melos ${args.join(" ")} failed:\n${result.stderr}');
    exit(result.exitCode);
  }
  return result.stdout as String;
}
