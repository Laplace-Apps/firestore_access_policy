import 'package:firestore_access_policy/firestore_access_policy.dart';

/// Example: build `firestore.rules` and `storage.rules` from Dart policies.
void main() {
  final firestoreRules = const FirestoreRulesGenerator().generate(
    FirestoreRulesFile(
      headerComment: 'Example — firestore_access_policy',
      helpers: [
        const HelperFunction(
          name: 'isAuthenticated',
          body: 'return request.auth != null;',
        ),
      ],
      policies: [
        AccessPolicy(
          path: ResourcePath.parse('lists/{listId}'),
          description: 'List documents',
          rules: {
            PolicyAction.read: [
              PolicyRule(
                And([
                  Authenticated(),
                  Or([
                    InMapKeys('members'),
                    CallHelper('userCanAccessListData', ['resource.data']),
                  ]),
                ]),
              ),
            ],
            PolicyAction.delete: [
              PolicyRule(AuthUidEqualsField('createdBy')),
            ],
          },
        ),
      ],
    ),
  );

  final storageRules = const StorageRulesGenerator().generate(
    StorageRulesFile(
      policies: [
        StorageAccessPolicy(
          path: StorageResourcePath.parse('users/{userId}/{allPaths=**}'),
          description: 'User-owned files',
          rules: {
            StoragePolicyAction.read: [
              StoragePolicyRule(
                PathParamEquals('userId', 'request.auth.uid'),
              ),
            ],
            StoragePolicyAction.write: [
              StoragePolicyRule(
                PathParamEquals('userId', 'request.auth.uid'),
              ),
            ],
          },
        ),
      ],
    ),
  );

  // ignore: avoid_print
  print('=== firestore.rules ===\n$firestoreRules');
  // ignore: avoid_print
  print('=== storage.rules ===\n$storageRules');
}
