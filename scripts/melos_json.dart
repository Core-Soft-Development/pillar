// Runs a melos command and decodes its JSON output.
//
// melos interleaves notices into stdout — the "a new version of melos is
// available" box being the common one — so the JSON cannot simply be handed to
// jsonDecode. This scans for the first balanced JSON value instead, which is
// stable whether or not melos decided to say something today.

import 'dart:convert';
import 'dart:io';

Future<dynamic> melosJson(List<String> args) async {
  final result = await Process.run('melos', args, runInShell: true);
  if (result.exitCode != 0) {
    stderr.writeln('melos ${args.join(" ")} failed:\n${result.stderr}');
    exit(result.exitCode);
  }

  final payload = extractJson(result.stdout as String);
  if (payload == null) {
    stderr.writeln('No JSON found in the output of: melos ${args.join(" ")}');
    exit(1);
  }
  return jsonDecode(payload);
}

/// The first balanced `[...]` or `{...}` in [output], or null if there is none.
///
/// Quoted strings are tracked so that a bracket inside a description does not
/// end the value early.
String? extractJson(String output) {
  final start = output.indexOf(RegExp(r'[\[{]'));
  if (start == -1) return null;

  final opening = output[start];
  final closing = opening == '[' ? ']' : '}';

  var depth = 0;
  var inString = false;
  var escaped = false;

  for (var i = start; i < output.length; i++) {
    final char = output[i];

    if (escaped) {
      escaped = false;
      continue;
    }
    if (inString) {
      if (char == r'\') escaped = true;
      if (char == '"') inString = false;
      continue;
    }

    if (char == '"') {
      inString = true;
    } else if (char == opening) {
      depth++;
    } else if (char == closing) {
      depth--;
      if (depth == 0) return output.substring(start, i + 1);
    }
  }

  return null;
}
