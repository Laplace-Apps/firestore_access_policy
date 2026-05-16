import 'storage_access_policy.dart';
import 'storage_policy_action.dart';
import 'storage_rules_file.dart';

/// Generates Firebase Storage `storage.rules` text from [StorageRulesFile].
final class StorageRulesGenerator {
  const StorageRulesGenerator();

  String generate(StorageRulesFile file) {
    final buffer = StringBuffer()
      ..writeln('rules_version = \'2\';')
      ..writeln('service firebase.storage {')
      ..writeln('  match ${file.bucketMatch} {');

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
      buffer.writeln('    match /{allPaths=**} {');
      buffer.writeln('      allow read, write: if false;');
      buffer.writeln('    }');
    }

    buffer
      ..writeln('  }')
      ..writeln('}');

    return buffer.toString();
  }

  String _emitPolicy(StorageAccessPolicy policy) {
    final buffer = StringBuffer();
    if (policy.description != null) {
      buffer.writeln('    // ${policy.description}');
    }
    buffer.writeln('    match /${policy.path.matchPath} {');

    for (final action in StoragePolicyAction.values) {
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

  String _actionName(StoragePolicyAction action) => switch (action) {
        StoragePolicyAction.read => 'read',
        StoragePolicyAction.write => 'write',
        StoragePolicyAction.create => 'create',
        StoragePolicyAction.update => 'update',
        StoragePolicyAction.delete => 'delete',
      };
}
