import 'policy_action.dart';
import 'resource_path.dart';

/// Describes access rules for a single Firestore resource path.
///
/// In step 1, [permissions] holds human-oriented descriptions. Later steps
/// attach structured [PolicyCondition]s and emit `firestore.rules` text.
final class AccessPolicy {
  /// Creates a policy for [path].
  const AccessPolicy({
    required this.path,
    this.description,
    this.permissions = const {},
  });

  /// Firestore `match` path for this resource.
  final ResourcePath path;

  /// Optional documentation shown in generated rules comments.
  final String? description;

  /// Intended access per action. Values are descriptions until conditions
  /// are wired in step 2+.
  final Map<PolicyAction, String> permissions;

  /// Actions explicitly configured on this policy.
  Iterable<PolicyAction> get configuredActions => permissions.keys;

  /// Whether [action] has an entry in [permissions].
  bool allows(PolicyAction action) => permissions.containsKey(action);

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
