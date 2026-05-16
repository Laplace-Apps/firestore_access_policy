import 'dart:io';

import 'rules_output_target.dart';
import 'rules_write_exception.dart';
import 'rules_write_if_exists.dart';
import 'rules_write_result.dart';

/// Writes generated rules text to disk with safe overwrite behaviour.
final class RulesFileWriter {
  /// Creates a rules file writer.
  const RulesFileWriter();

  /// Writes [content] to [target.path] according to [target.ifExists].
  Future<RulesWriteResult> writeString(
    String content,
    RulesOutputTarget target,
  ) async {
    final file = File(target.path);
    final exists = await file.exists();

    if (exists) {
      switch (target.ifExists) {
        case RulesWriteIfExists.skip:
          return RulesWriteResult.skipped(target.path);
        case RulesWriteIfExists.fail:
          throw RulesWriteException(
            'Refusing to write ${target.path}: file already exists. '
            'Use RulesWriteIfExists.overwrite or choose another path '
            '(e.g. firestore.generated.rules).',
          );
        case RulesWriteIfExists.overwrite:
          break;
      }
    }

    await file.parent.create(recursive: true);
    await file.writeAsString(content);
    return RulesWriteResult.written(target.path, content.length);
  }
}
