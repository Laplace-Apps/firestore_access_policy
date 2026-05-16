/// What to do when the output rules file already exists on disk.
enum RulesWriteIfExists {
  /// Throw [RulesWriteException] if the target file exists.
  fail,

  /// Do not write; return [RulesWriteResult.skipped].
  skip,

  /// Replace the existing file.
  overwrite,
}
