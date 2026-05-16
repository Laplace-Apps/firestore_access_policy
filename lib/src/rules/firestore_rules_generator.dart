import '../access_policy.dart';
import '../policy_action.dart';
import 'rules_file.dart';

/// Generates `firestore.rules` text from [FirestoreRulesFile].
final class FirestoreRulesGenerator {
  /// Creates a Firestore rules generator.
  const FirestoreRulesGenerator();

  /// Returns complete `firestore.rules` source for [file].
  String generate(FirestoreRulesFile file) {
    final buffer = StringBuffer()
      ..writeln('rules_version = \'2\';')
      ..writeln('service cloud.firestore {')
      ..writeln('  match /databases/{database}/documents {');

    if (file.headerComment != null) {
      for (final line in file.headerComment!.split('\n')) {
        buffer.writeln('    // $line');
      }
      buffer.writeln();
    }

    for (final helper in file.helpers) {
      buffer.writeln(helper.emit());
    }
    if (file.helpers.isNotEmpty) {
      buffer.writeln();
    }

    for (final policy in file.policies) {
      buffer.writeln(_emitPolicy(policy));
    }

    if (file.denyUnmatched) {
      buffer.writeln('    match /{document=**} {');
      buffer.writeln('      allow read, write: if false;');
      buffer.writeln('    }');
    }

    buffer
      ..writeln('  }')
      ..writeln('}');

    return buffer.toString();
  }

  String _emitPolicy(AccessPolicy policy) {
    final buffer = StringBuffer();
    if (policy.description != null) {
      buffer.writeln('    // ${policy.description}');
    }
    buffer.writeln('    match /${policy.path.matchPath} {');

    for (final action in PolicyAction.values) {
      final rules = policy.rules[action];
      if (rules == null) continue;
      for (final rule in rules) {
        if (rule.comment != null) {
          buffer.writeln('      // ${rule.comment}');
        }
        final condition = rule.condition.emit();
        buffer.writeln('      allow ${_actionName(action)}: if $condition;');
      }
    }

    buffer.writeln('    }');
    return buffer.toString();
  }

  String _actionName(PolicyAction action) => switch (action) {
        PolicyAction.read => 'read',
        PolicyAction.create => 'create',
        PolicyAction.update => 'update',
        PolicyAction.delete => 'delete',
      };
}
