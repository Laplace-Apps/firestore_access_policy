/// Result of writing generated rules to disk.
enum RulesWriteOutcome {
  /// File was written successfully.
  written,

  /// File already existed and [RulesWriteIfExists.skip] was used.
  skipped,
}

/// Outcome of [RulesFileWriter.writeString].
final class RulesWriteResult {
  /// Successful write to [path] with [bytesWritten].
  const RulesWriteResult.written(this.path, this.bytesWritten)
      : outcome = RulesWriteOutcome.written;

  /// No write because the target already existed.
  const RulesWriteResult.skipped(this.path)
      : outcome = RulesWriteOutcome.skipped,
        bytesWritten = 0;

  /// Whether the file was written or skipped.
  final RulesWriteOutcome outcome;

  /// Output file path.
  final String path;

  /// Bytes written when [outcome] is [RulesWriteOutcome.written].
  final int bytesWritten;

  /// True when the file was written.
  bool get wasWritten => outcome == RulesWriteOutcome.written;

  /// True when the write was skipped.
  bool get wasSkipped => outcome == RulesWriteOutcome.skipped;
}
