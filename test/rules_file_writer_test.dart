import 'dart:io';

import 'package:firestore_access_policy/firestore_access_policy.dart';
import 'package:test/test.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('fap_rules_');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('fail if exists by default', () async {
    final path = '${tempDir.path}/firestore.rules';
    await File(path).writeAsString('existing');

    expect(
      () => const RulesFileWriter().writeString(
        'new',
        RulesOutputTarget(path: path),
      ),
      throwsA(isA<RulesWriteException>()),
    );
  });

  test('writes to custom path without touching default name', () async {
    final existing = '${tempDir.path}/firestore.rules';
    final generated = '${tempDir.path}/firestore.generated.rules';
    await File(existing).writeAsString('hand written');

    final result = await const RulesFileWriter().writeString(
      'generated content',
      RulesOutputTarget(path: generated),
    );

    expect(result.wasWritten, isTrue);
    expect(await File(existing).readAsString(), 'hand written');
    expect(await File(generated).readAsString(), 'generated content');
  });

  test('skip when file exists', () async {
    final path = '${tempDir.path}/firestore.generated.rules';
    await File(path).writeAsString('keep');

    final result = await const RulesFileWriter().writeString(
      'replace',
      RulesOutputTarget(
        path: path,
        ifExists: RulesWriteIfExists.skip,
      ),
    );

    expect(result.wasSkipped, isTrue);
    expect(await File(path).readAsString(), 'keep');
  });
}
