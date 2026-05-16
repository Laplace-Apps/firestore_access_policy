# firestore_access_policy

[![pub package](https://img.shields.io/pub/v/firestore_access_policy.svg)](https://pub.dev/packages/firestore_access_policy)
[![CI](https://github.com/Laplace-Apps/firestore_access_policy/actions/workflows/ci.yml/badge.svg)](https://github.com/Laplace-Apps/firestore_access_policy/actions/workflows/ci.yml)

Define **who can read, create, update, and delete** Firestore and Storage resources in Dart, then **generate** `firestore.rules` and `storage.rules` from one source of truth.

## Install

```yaml
dependencies:
  firestore_access_policy: ^0.2.0
```

## Generate Firestore rules

```dart
import 'package:firestore_access_policy/firestore_access_policy.dart';

void main() {
  final rules = const FirestoreRulesGenerator().generate(
    FirestoreRulesFile(
      helpers: [
        const HelperFunction(
          name: 'isAuthenticated',
          body: 'return request.auth != null;',
        ),
      ],
      policies: [
        AccessPolicy(
          path: ResourcePath.parse('lists/{listId}'),
          rules: {
            PolicyAction.read: [
              PolicyRule(
                And([
                  Authenticated(),
                  InMapKeys('members'),
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

  // Write `rules` to firestore.rules (build script, CI, or manual)
}
```

## Generate Storage rules

```dart
final storageRules = const StorageRulesGenerator().generate(
  StorageRulesFile(
    policies: [
      StorageAccessPolicy(
        path: StorageResourcePath.parse('users/{userId}/{allPaths=**}'),
        rules: {
          StoragePolicyAction.read: [
            StoragePolicyRule(PathParamEquals('userId', 'request.auth.uid')),
          ],
          StoragePolicyAction.write: [
            StoragePolicyRule(PathParamEquals('userId', 'request.auth.uid')),
          ],
        },
      ),
    ],
  ),
);
```

## Policy conditions

| Type | Emits (example) |
|------|------------------|
| `Authenticated()` | `request.auth != null` |
| `AuthUidEqualsField('createdBy')` | `request.auth.uid == resource.data.createdBy` |
| `InMapKeys('members')` | `request.auth.uid in resource.data.members.keys()` |
| `FieldUnchanged('createdBy')` | immutable field check |
| `And` / `Or` | combined expressions |
| `CallHelper('fn', ['arg'])` | `fn(arg)` |
| `PathParamEquals('userId', 'request.auth.uid')` | Storage path params |
| `RulesExpression('...')` | raw Rules fragment |

Complex logic (member diffs, cross-collection `get()`, quotas) can use `RulesExpression` or `HelperFunction` until higher-level patterns ship.

## Roadmap

| Step | Status |
|------|--------|
| Policy model + conditions | **Done (0.2)** |
| Firestore + Storage emitters | **Done (0.2)** |
| Member-diff / parent-resource patterns | Planned |
| Rules unit-test generator + CLI | Planned |

## Example

See [`example/generate_rules_example.dart`](example/generate_rules_example.dart).

## Development

```bash
dart pub get
dart test
dart analyze
dart pub publish --dry-run
```

## Automated publishing (GitHub Actions → pub.dev)

Uses [pub.dev automated publishing](https://dart.dev/tools/pub/automated-publishing) with OIDC (no copied pub tokens).

### One-time setup on pub.dev

1. Open [firestore_access_policy admin](https://pub.dev/packages/firestore_access_policy/admin) (uploader or `laplaceapps.com` publisher admin).
2. **Automated publishing** → **Enable publishing from GitHub Actions**.
3. Set:
   - **Repository:** `Laplace-Apps/firestore_access_policy`
   - **Tag pattern:** `v{{version}}`

### Publish a new version

1. Bump `version:` in `pubspec.yaml` (e.g. `0.2.1`).
2. Commit and push to `main`.
3. Tag and push (version must match the tag):

```bash
git tag v0.2.1
git push origin v0.2.1
```

4. Check [GitHub Actions](https://github.com/Laplace-Apps/firestore_access_policy/actions) and the package [audit log](https://pub.dev/packages/firestore_access_policy/score/log) on pub.dev.

Workflow file: [`.github/workflows/publish.yml`](.github/workflows/publish.yml) (reusable workflow from `dart-lang/setup-dart`).

## License

MIT — see [LICENSE](LICENSE).
