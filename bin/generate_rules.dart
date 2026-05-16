import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:firestore_access_policy/firestore_access_policy.dart';

/// CLI: write rules from stdin or document usage for app-specific generators.
///
/// Typical app flow (keeps your hand-written `firestore.rules` safe):
///   dart run tool/generate_my_rules.dart | dart run generate_rules --firestore-out=firestore.generated.rules
///
/// Or call [RulesGeneration.writeFirestore] from `tool/generate_my_rules.dart`.
Future<void> main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption(
      'firestore-out',
      help: 'Output path for Firestore rules (e.g. firestore.generated.rules)',
    )
    ..addOption(
      'storage-out',
      help: 'Output path for Storage rules (e.g. storage.generated.rules)',
    )
    ..addOption(
      'if-exists',
      defaultsTo: 'fail',
      allowed: ['fail', 'skip', 'overwrite'],
      help: 'fail = never overwrite (default), skip, overwrite',
    )
    ..addFlag(
      'stdin',
      help: 'Read Firestore rules text from stdin (used with --firestore-out)',
      negatable: false,
    )
    ..addFlag('help', abbr: 'h', negatable: false);

  late final ArgResults args;
  try {
    args = parser.parse(arguments);
  } on FormatException catch (e) {
    stderr.writeln(e.message);
    stderr.writeln(parser.usage);
    exitCode = 64;
    return;
  }

  if (args.flag('help')) {
    stdout.writeln('Generate / write Firebase security rules safely.\n');
    stdout.writeln(parser.usage);
    stdout.writeln('''
Examples:
  # Safe default: fails if firestore.rules already exists
  dart run generate_rules --firestore-out=firestore.generated.rules --stdin < policy.txt

  # Explicit overwrite
  dart run generate_rules --firestore-out=firestore.generated.rules --if-exists=overwrite --stdin

Recommended: define policies in Dart and call RulesGeneration from tool/generate_rules.dart.
See example/firestore_access_policy_example.dart
''');
    return;
  }

  final ifExists = switch (args['if-exists'] as String) {
    'skip' => RulesWriteIfExists.skip,
    'overwrite' => RulesWriteIfExists.overwrite,
    _ => RulesWriteIfExists.fail,
  };

  final firestoreOut = args['firestore-out'] as String?;
  final storageOut = args['storage-out'] as String?;
  if (firestoreOut == null && storageOut == null) {
    stderr.writeln('Provide --firestore-out and/or --storage-out');
    exitCode = 64;
    return;
  }

  final writer = const RulesFileWriter();

  if (firestoreOut != null) {
    if (!args.flag('stdin')) {
      stderr.writeln('--firestore-out requires --stdin (pipe generated rules text)');
      exitCode = 64;
      return;
    }
    final content = await stdin.transform(utf8.decoder).join();
    final result = await writer.writeString(
      content,
      RulesOutputTarget(path: firestoreOut, ifExists: ifExists),
    );
    _printResult('Firestore', result);
  }

  if (storageOut != null) {
    stderr.writeln('Storage output via CLI requires an app tool using RulesGeneration.writeStorage.');
    exitCode = 64;
  }
}

void _printResult(String label, RulesWriteResult result) {
  if (result.wasWritten) {
    stdout.writeln('$label: wrote ${result.path} (${result.bytesWritten} bytes)');
  } else {
    stdout.writeln('$label: skipped ${result.path} (already exists)');
  }
}
