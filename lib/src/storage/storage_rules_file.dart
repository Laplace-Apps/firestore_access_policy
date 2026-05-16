import '../rules/helper_function.dart';
import 'storage_access_policy.dart';

/// Complete Storage rules document.
final class StorageRulesFile {
  const StorageRulesFile({
    this.helpers = const [],
    this.policies = const [],
    this.headerComment,
    this.bucketMatch = '/b/{bucket}/o',
    this.denyUnmatched = true,
  });

  final List<HelperFunction> helpers;
  final List<StorageAccessPolicy> policies;
  final String? headerComment;
  final String bucketMatch;
  final bool denyUnmatched;
}
