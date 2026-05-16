import '../conditions/policy_condition.dart';
import 'storage_policy_action.dart';
import 'storage_resource_path.dart';

/// One `allow` clause for Cloud Storage.
final class StoragePolicyRule {
  /// One Storage `allow` clause with optional comment.
  const StoragePolicyRule(this.condition, {this.comment});

  /// Boolean expression for the `if` clause.
  final PolicyCondition condition;

  /// Optional comment above this `allow` line.
  final String? comment;
}

/// Maps Storage actions to one or more allow clauses.
typedef StorageActionRules = Map<StoragePolicyAction, List<StoragePolicyRule>>;

/// Describes access rules for a Storage object path.
final class StorageAccessPolicy {
  /// Creates a policy for [path] with structured [rules].
  const StorageAccessPolicy({
    required this.path,
    this.description,
    this.rules = const {},
  });

  /// Storage object path under the bucket match.
  final StorageResourcePath path;

  /// Optional documentation in generated rules comments.
  final String? description;

  /// `allow` clauses per Storage action.
  final StorageActionRules rules;

  /// Actions that have at least one rule entry.
  Iterable<StoragePolicyAction> get configuredActions => rules.keys;
}
