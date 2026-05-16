import 'policy_action.dart';
import 'resource_path.dart';
import 'rules/policy_rule.dart';

/// Describes access rules for a single Firestore resource path.
final class AccessPolicy {
  /// Creates a policy for [path] with structured [rules] for code generation.
  const AccessPolicy({
    required this.path,
    this.description,
    this.rules = const {},
    @Deprecated('Use rules with PolicyRule and PolicyCondition. Removed in v0.3.')
    this.permissions = const {},
  });

  /// Firestore `match` path for this resource.
  final ResourcePath path;

  /// Optional documentation shown in generated rules comments.
  final String? description;

  /// `allow` clauses per CRUD action. Multiple entries per action are allowed.
  final ActionRules rules;

  /// Legacy human-readable descriptions (not emitted).
  @Deprecated('Use rules with PolicyRule and PolicyCondition.')
  final Map<PolicyAction, String> permissions;

  Iterable<PolicyAction> get configuredActions =>
      {...rules.keys, ...permissions.keys};

  bool allows(PolicyAction action) =>
      rules.containsKey(action) || permissions.containsKey(action);

  @override
  String toString() {
    final buffer = StringBuffer('AccessPolicy(${path.matchPath}');
    if (description != null) {
      buffer.write(', $description');
    }
    buffer.write(')');
    return buffer.toString();
  }
}
