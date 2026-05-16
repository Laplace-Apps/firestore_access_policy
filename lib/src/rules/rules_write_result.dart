/// Result of writing generated rules to disk.
enum RulesWriteOutcome {
  written,
  skipped,
}

/// Outcome of [RulesFileWriter.writeString].
final class RulesWriteResult {
  const RulesWriteResult.written(this.path, this.bytesWritten)
      : outcome = RulesWriteOutcome.written;

  const RulesWriteResult.skipped(this.path)
      : outcome = RulesWriteOutcome.skipped,
        bytesWritten = 0;

  final RulesWriteOutcome outcome;
  final String path;
  final int bytesWritten;

  bool get wasWritten => outcome == RulesWriteOutcome.written;
  bool get wasSkipped => outcome == RulesWriteOutcome.skipped;
}
