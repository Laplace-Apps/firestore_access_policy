import '../conditions/policy_condition.dart';
import '../policy_action.dart';

/// One `allow <action>: if ...` clause for a resource policy.
final class PolicyRule {
  /// One `allow` clause with optional inline comment.
  const PolicyRule(this.condition, {this.comment});

  /// Boolean expression for the `if` clause.
  final PolicyCondition condition;

  /// Optional comment above this `allow` line in generated rules.
  final String? comment;
}

/// Maps CRUD actions to one or more allow clauses (supports multiple `allow read`).
typedef ActionRules = Map<PolicyAction, List<PolicyRule>>;
