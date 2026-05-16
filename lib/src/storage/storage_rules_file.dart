import '../rules/helper_function.dart';
import 'storage_access_policy.dart';

/// Complete Storage rules document.
final class StorageRulesFile {
  /// Describes a full Storage rules document to generate.
  const StorageRulesFile({
    this.helpers = const [],
    this.policies = const [],
    this.headerComment,
    this.bucketMatch = '/b/{bucket}/o',
    this.denyUnmatched = true,
  });

  /// Top-level helper functions emitted before `match` blocks.
  final List<HelperFunction> helpers;

  /// Object policies (one `match` per entry).
  final List<StorageAccessPolicy> policies;

  /// Optional multi-line banner comment at the top of the rules file.
  final String? headerComment;

  /// Outer `match` for the bucket (default `/b/{bucket}/o`).
  final String bucketMatch;

  /// When true, denies unmatched paths under the bucket.
  final bool denyUnmatched;
}
