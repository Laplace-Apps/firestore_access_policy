import '../access_policy.dart';
import 'helper_function.dart';

/// Complete Firestore rules document: helpers + resource policies + deny fallback.
final class FirestoreRulesFile {
  /// Describes a full Firestore rules document to generate.
  const FirestoreRulesFile({
    this.helpers = const [],
    this.policies = const [],
    this.headerComment,
    this.denyUnmatched = true,
  });

  /// Top-level helper functions emitted before `match` blocks.
  final List<HelperFunction> helpers;

  /// Resource policies (one `match` per entry).
  final List<AccessPolicy> policies;

  /// Optional multi-line banner comment at the top of the rules file.
  final String? headerComment;

  /// When true, appends `match /{document=**} { allow read, write: if false; }`.
  final bool denyUnmatched;
}
