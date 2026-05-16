import 'rules_write_if_exists.dart';

/// Destination path and overwrite behaviour for generated rules text.
final class RulesOutputTarget {
  /// Output path and overwrite policy for [RulesFileWriter].
  const RulesOutputTarget({
    required this.path,
    this.ifExists = RulesWriteIfExists.fail,
  });

  /// File path, e.g. `firestore.rules` or `firestore.generated.rules`.
  final String path;

  /// Default is [RulesWriteIfExists.fail] so an existing hand-written rules
  /// file is never replaced by accident.
  final RulesWriteIfExists ifExists;
}
