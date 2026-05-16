/// Storage object path under `match /b/{bucket}/o`, e.g. `users/{userId}/{allPaths=**}`.
final class StorageResourcePath {
  /// Creates a path from [segments] (non-empty).
  const StorageResourcePath(this.segments)
      : assert(segments.length > 0, 'path must have at least one segment');

  /// Parses a slash-separated Storage object path.
  factory StorageResourcePath.parse(String path) {
    final trimmed = path.trim();
    if (trimmed.isEmpty) {
      throw FormatException('Storage path cannot be empty', path);
    }
    final segments = trimmed.split('/').where((s) => s.isNotEmpty).toList();
    if (segments.isEmpty) {
      throw FormatException('Storage path cannot be empty', path);
    }
    return StorageResourcePath(List.unmodifiable(segments));
  }

  /// Path segments, e.g. `['users', '{userId}', '{allPaths=**}']`.
  final List<String> segments;

  /// Path joined for use in a `match` line.
  String get matchPath => segments.join('/');

  @override
  String toString() => 'StorageResourcePath($matchPath)';
}
