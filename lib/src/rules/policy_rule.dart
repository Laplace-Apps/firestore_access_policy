import '../conditions/policy_condition.dart';
import '../policy_action.dart';

/// One `allow <action>: if ...` clause for a resource policy.
final class PolicyRule {
  const PolicyRule(this.condition, {this.comment});

  final PolicyCondition condition;
  final String? comment;
}

/// Maps CRUD actions to one or more allow clauses (supports multiple `allow read`).
typedef ActionRules = Map<PolicyAction, List<PolicyRule>>;
