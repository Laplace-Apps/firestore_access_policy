import '../conditions/policy_condition.dart';
import 'storage_policy_action.dart';
import 'storage_resource_path.dart';

/// One `allow` clause for Cloud Storage.
final class StoragePolicyRule {
  const StoragePolicyRule(this.condition, {this.comment});

  final PolicyCondition condition;
  final String? comment;
}

typedef StorageActionRules = Map<StoragePolicyAction, List<StoragePolicyRule>>;

/// Describes access rules for a Storage object path.
final class StorageAccessPolicy {
  const StorageAccessPolicy({
    required this.path,
    this.description,
    this.rules = const {},
  });

  final StorageResourcePath path;
  final String? description;
  final StorageActionRules rules;

  Iterable<StoragePolicyAction> get configuredActions => rules.keys;
}
