/// Thrown when [RulesFileWriter] cannot write (e.g. target exists and
/// [RulesWriteIfExists.fail]).
final class RulesWriteException implements Exception {
  /// Describes why [RulesFileWriter] refused to write.
  RulesWriteException(this.message);

  /// Human-readable error detail.
  final String message;

  @override
  String toString() => 'RulesWriteException: $message';
}
