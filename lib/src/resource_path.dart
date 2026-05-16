/// Firestore `match` path, e.g. `lists/{listId}` or `groups/{groupId}/lists/{listId}`.
final class ResourcePath {
  /// Creates a path from segments such as `['lists', '{listId}']`.
  const ResourcePath(this.segments)
      : assert(segments.length > 0, 'path must have at least one segment');

  /// Parses a slash-separated Firestore match path.
  ///
  /// ```dart
  /// ResourcePath.parse('lists/{listId}'); // segments: lists, {listId}
  /// ```
  factory ResourcePath.parse(String path) {
    final trimmed = path.trim();
    if (trimmed.isEmpty) {
      throw FormatException('Resource path cannot be empty', path);
    }
    final segments = trimmed.split('/').where((s) => s.isNotEmpty).toList();
    if (segments.isEmpty) {
      throw FormatException('Resource path cannot be empty', path);
    }
    return ResourcePath(List.unmodifiable(segments));
  }

  /// Ordered path segments (collection ids and `{param}` placeholders).
  final List<String> segments;

  /// Full path string suitable for `match /...` in rules.
  String get matchPath => segments.join('/');

  /// Wildcard parameter names, e.g. `{listId}` → `listId`.
  Iterable<String> get parameters sync* {
    for (final segment in segments) {
      if (segment.startsWith('{') && segment.endsWith('}')) {
        yield segment.substring(1, segment.length - 1);
      }
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResourcePath &&
          other.runtimeType == runtimeType &&
          _listEquals(other.segments, segments);

  @override
  int get hashCode => Object.hashAll(segments);

  @override
  String toString() => 'ResourcePath($matchPath)';
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
