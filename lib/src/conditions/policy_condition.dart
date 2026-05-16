/// A boolean expression in Firebase Security Rules syntax.
sealed class PolicyCondition {
  const PolicyCondition();

  /// Emits Rules-language source (no trailing semicolon).
  String emit();
}

/// Signed-in user (`request.auth != null`).
final class Authenticated extends PolicyCondition {
  const Authenticated();

  @override
  String emit() => 'request.auth != null';
}

/// `request.auth.uid == <field>` on [target] (`resource` or `request.resource`).
final class AuthUidEqualsField extends PolicyCondition {
  const AuthUidEqualsField(this.fieldPath, {this.target = RulesDataTarget.resource});

  final String fieldPath;
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
  const FieldEquals(
    this.fieldPath,
    this.valueExpression, {
    this.target = RulesDataTarget.resource,
  });

  final String fieldPath;
  final String valueExpression;
  final RulesDataTarget target;

  @override
  String emit() {
    final data = _dataRef(target);
    return '$data.$fieldPath == $valueExpression';
  }
}

/// `resource.data.field == request.resource.data.field` (immutable field).
final class FieldUnchanged extends PolicyCondition {
  const FieldUnchanged(this.fieldPath);

  final String fieldPath;

  @override
  String emit() =>
      'request.resource.data.$fieldPath == resource.data.$fieldPath';
}

/// `uid in mapField.keys()` (Firestore list membership on map keys).
final class InMapKeys extends PolicyCondition {
  const InMapKeys(
    this.mapField, {
    this.uidExpression = 'request.auth.uid',
    this.target = RulesDataTarget.resource,
  });

  final String mapField;
  final String uidExpression;
  final RulesDataTarget target;

  @override
  String emit() {
    final data = _dataRef(target);
    return '$uidExpression in $data.$mapField.keys()';
  }
}

/// Logical AND of [conditions].
final class And extends PolicyCondition {
  const And(this.conditions);

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
  const Or(this.conditions);

  final List<PolicyCondition> conditions;

  @override
  String emit() {
    if (conditions.isEmpty) return 'false';
    if (conditions.length == 1) return conditions.first.emit();
    return conditions.map((c) => '(${c.emit()})').join(' ||\n          ');
  }
}

/// Call a helper function defined in the same [RulesFile].
final class CallHelper extends PolicyCondition {
  const CallHelper(this.name, [this.arguments = const []]);

  final String name;
  final List<String> arguments;

  @override
  String emit() {
    if (arguments.isEmpty) return '$name()';
    return '$name(${arguments.join(', ')})';
  }
}

/// `valueExpression == pathParam` (e.g. `request.auth.uid == userId` in Storage).
final class PathParamEquals extends PolicyCondition {
  const PathParamEquals(this.paramName, this.valueExpression);

  final String paramName;
  final String valueExpression;

  @override
  String emit() => '$valueExpression == $paramName';
}

/// Raw Rules expression (escape hatch for complex logic).
final class RulesExpression extends PolicyCondition {
  const RulesExpression(this.source);

  final String source;

  @override
  String emit() => source;
}

/// Which document payload a condition reads from.
enum RulesDataTarget {
  resource,
  requestResource,
}

String _dataRef(RulesDataTarget target) => switch (target) {
      RulesDataTarget.resource => 'resource.data',
      RulesDataTarget.requestResource => 'request.resource.data',
    };
