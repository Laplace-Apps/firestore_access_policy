/// Thrown when [RulesFileWriter] cannot write (e.g. target exists and
/// [RulesWriteIfExists.fail]).
final class RulesWriteException implements Exception {
  RulesWriteException(this.message);

  final String message;

  @override
  String toString() => 'RulesWriteException: $message';
}
