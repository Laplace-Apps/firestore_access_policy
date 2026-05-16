import 'package:firestore_access_policy/firestore_access_policy.dart';
import 'package:test/test.dart';

void main() {
  group('ResourcePath', () {
    test('parse splits segments and exposes parameters', () {
      final path = ResourcePath.parse('lists/{listId}');
      expect(path.matchPath, 'lists/{listId}');
      expect(path.parameters, ['listId']);
    });

    test('empty path throws', () {
      expect(() => ResourcePath.parse(''), throwsFormatException);
    });
  });

  group('AccessPolicy', () {
    test('tracks configured CRUD actions from rules', () {
      final policy = AccessPolicy(
        path: ResourcePath.parse('lists/{listId}'),
        rules: {
          PolicyAction.read: [PolicyRule(const Authenticated())],
          PolicyAction.delete: [
            PolicyRule(AuthUidEqualsField('createdBy')),
          ],
        },
      );

      expect(policy.allows(PolicyAction.read), isTrue);
      expect(policy.allows(PolicyAction.update), isFalse);
      expect(
        policy.configuredActions,
        containsAll([PolicyAction.read, PolicyAction.delete]),
      );
    });
  });
}
