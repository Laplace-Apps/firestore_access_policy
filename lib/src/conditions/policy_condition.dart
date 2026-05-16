/// A boolean expression in Firebase Security Rules syntax.
sealed class PolicyCondition {
  const PolicyCondition();

  /// Emits Rules-language source (no trailing semicolon).
  String emit();
}

/// Signed-in user (`request.auth != null`).
final class Authenticated extends PolicyCondition {
  /// Creates an authenticated-user check.
  const Authenticated();

  @override
  String emit() => 'request.auth != null';
}

/// `request.auth.uid == <field>` on [target] (`resource` or `request.resource`).
final class AuthUidEqualsField extends PolicyCondition {
  /// Compares `request.auth.uid` to [fieldPath] on [target].
  const AuthUidEqualsField(this.fieldPath, {this.target = RulesDataTarget.resource});

  /// Document field path (e.g. `createdBy`).
  final String fieldPath;

  /// Whether to read [fieldPath] from `resource` or `request.resource`.
  final RulesDataTarget target;

  @override
  String emit() {
    final data = switch (target) {
      RulesDataTarget.resource => 'resource.data',
      RulesDataTarget.requestResource => 'request.resource.data',
    };
    return 'request.auth.uid == $data.$fieldPath';
  }
}

/// Compare a field on [target] to a literal or expression fragment.
final class FieldEquals extends PolicyCondition {
  /// Emits `data.<fieldPath> == <valueExpression>`.
  const FieldEquals(
    this.fieldPath,
    this.valueExpression, {
    this.target = RulesDataTarget.resource,
  });

  /// Document field path.
  final String fieldPath;

  /// Right-hand side Rules expression (literal or fragment).
  final String valueExpression;

  /// Which document payload supplies the left-hand field.
  final RulesDataTarget target;

  @override
  String emit() {
    final data = _dataRef(target);
    return '$data.$fieldPath == $valueExpression';
  }
}

/// `resource.data.field == request.resource.data.field` (immutable field).
final class FieldUnchanged extends PolicyCondition {
  /// Requires [fieldPath] to be unchanged on write.
  const FieldUnchanged(this.fieldPath);

  /// Field that must not change between resource and request.
  final String fieldPath;

  @override
  String emit() =>
      'request.resource.data.$fieldPath == resource.data.$fieldPath';
}

/// `uid in mapField.keys()` (Firestore list membership on map keys).
final class InMapKeys extends PolicyCondition {
  /// Checks [uidExpression] is a key of [mapField] on [target].
  const InMapKeys(
    this.mapField, {
    this.uidExpression = 'request.auth.uid',
    this.target = RulesDataTarget.resource,
  });

  /// Map field name (e.g. `members`).
  final String mapField;

  /// UID expression, usually `request.auth.uid`.
  final String uidExpression;

  /// Which document supplies [mapField].
  final RulesDataTarget target;

  @override
  String emit() {
    final data = _dataRef(target);
    return '$uidExpression in $data.$mapField.keys()';
  }
}

/// Logical AND of [conditions].
final class And extends PolicyCondition {
  /// Combines [conditions] with `&&`.
  const And(this.conditions);

  /// Sub-conditions that must all hold.
  final List<PolicyCondition> conditions;

  @override
  String emit() {
    if (conditions.isEmpty) return 'true';
    if (conditions.length == 1) return conditions.first.emit();
    return conditions.map((c) => '(${c.emit()})').join(' &&\n          ');
  }
}

/// Logical OR of [conditions].
final class Or extends PolicyCondition {
  /// Combines [conditions] with `||`.
  const Or(this.conditions);

  /// Sub-conditions where at least one must hold.
  final List<PolicyCondition> conditions;

  @override
  String emit() {
    if (conditions.isEmpty) return 'false';
    if (conditions.length == 1) return conditions.first.emit();
    return conditions.map((c) => '(${c.emit()})').join(' ||\n          ');
  }
}

/// Call a helper function defined in the same rules file.
final class CallHelper extends PolicyCondition {
  /// Invokes [name] with optional [arguments].
  const CallHelper(this.name, [this.arguments = const []]);

  /// Helper function name.
  final String name;

  /// Argument expressions passed to the helper.
  final List<String> arguments;

  @override
  String emit() {
    if (arguments.isEmpty) return '$name()';
    return '$name(${arguments.join(', ')})';
  }
}

/// `valueExpression == pathParam` (e.g. `request.auth.uid == userId` in Storage).
final class PathParamEquals extends PolicyCondition {
  /// Compares a path wildcard to [valueExpression].
  const PathParamEquals(this.paramName, this.valueExpression);

  /// Path parameter name from the `match` pattern.
  final String paramName;

  /// Left-hand expression (e.g. `request.auth.uid`).
  final String valueExpression;

  @override
  String emit() => '$valueExpression == $paramName';
}

/// Raw Rules expression (escape hatch for complex logic).
final class RulesExpression extends PolicyCondition {
  /// Emits [source] verbatim in the `if` clause.
  const RulesExpression(this.source);

  /// Rules-language source (no trailing semicolon).
  final String source;

  @override
  String emit() => source;
}

/// Which document payload a condition reads from.
enum RulesDataTarget {
  /// `resource.data` (existing document).
  resource,

  /// `request.resource.data` (incoming write).
  requestResource,
}

String _dataRef(RulesDataTarget target) => switch (target) {
      RulesDataTarget.resource => 'resource.data',
      RulesDataTarget.requestResource => 'request.resource.data',
    };
