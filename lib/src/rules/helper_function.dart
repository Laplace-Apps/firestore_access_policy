/// Reusable `function name(...) { ... }` block in a rules file.
final class HelperFunction {
  const HelperFunction({
    required this.name,
    this.parameters = const [],
    required this.body,
    this.comment,
  });

  final String name;
  final List<String> parameters;
  /// Rules statements inside the function (without outer braces).
  final String body;
  final String? comment;

  String emit({String indent = '    '}) {
    final buffer = StringBuffer();
    if (comment != null) {
      buffer.writeln('$indent// $comment');
    }
    final params = parameters.join(', ');
    buffer.writeln('${indent}function $name($params) {');
    for (final line in body.split('\n')) {
      final trimmed = line.trimRight();
      if (trimmed.isEmpty) {
        buffer.writeln();
      } else {
        buffer.writeln('$indent  $trimmed');
      }
    }
    buffer.writeln('$indent}');
    return buffer.toString();
  }
}
