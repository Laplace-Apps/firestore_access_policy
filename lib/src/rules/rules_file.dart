import '../access_policy.dart';
import 'helper_function.dart';

/// Complete Firestore rules document: helpers + resource policies + deny fallback.
final class FirestoreRulesFile {
  const FirestoreRulesFile({
    this.helpers = const [],
    this.policies = const [],
    this.headerComment,
    this.denyUnmatched = true,
  });

  final List<HelperFunction> helpers;
  final List<AccessPolicy> policies;
  final String? headerComment;
  final bool denyUnmatched;
}
