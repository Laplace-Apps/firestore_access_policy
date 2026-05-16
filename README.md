# firestore_access_policy

[![pub package](https://img.shields.io/pub/v/firestore_access_policy.svg)](https://pub.dev/packages/firestore_access_policy)
[![CI](https://github.com/Laplace-Apps/firestore_access_policy/actions/workflows/ci.yml/badge.svg)](https://github.com/Laplace-Apps/firestore_access_policy/actions/workflows/ci.yml)

Define **who can read, create, update, and delete** Firestore and Storage resources in Dart, then **generate** `firestore.rules` and `storage.rules` from one source of truth.

## Install

```yaml
dependencies:
  firestore_access_policy: ^0.3.0
```

## Generate rules (in memory)

```dart
final text = const FirestoreRulesGenerator().generate(firestoreRulesFile);
```

## Write to a custom file (won't overwrite by default)

Use a **different path** than your hand-maintained `firestore.rules`. Default behaviour is **fail if the file exists**:

```dart
const generation = RulesGeneration();

await generation.writeFirestore(
  myRulesFile,
  const RulesOutputTarget(
    path: 'firestore.generated.rules', // not firestore.rules
  ),
);

await generation.writeStorage(
  myStorageRulesFile,
  const RulesOutputTarget(path: 'storage.generated.rules'),
);
```

| `RulesWriteIfExists` | Behaviour |
|----------------------|-----------|
| `fail` (default) | Throws if file exists — protects `firestore.rules` |
| `skip` | Leaves existing file unchanged |
| `overwrite` | Replaces file |

## Patterns (member diff, parent group)

```dart
FirestoreRulesFile(
  helpers: [
    ...MemberDiffPatterns.standardListMemberHelpers(),
    ParentResourcePatterns.groupMemberByIdHelper(),
  ],
  policies: [
    AccessPolicy(
      path: ResourcePath.parse('lists/{listId}'),
      rules: {
        PolicyAction.update: [
          PolicyRule(
            And([
              InMapKeys('members'),
              MemberDiffPatterns.allowedMemberMapUpdate(),
            ]),
          ),
        ],
      },
    ),
  ],
);
```

## CLI

Pipe generated text to a safe output path:

```bash
dart run tool/my_policies.dart | dart run firestore_access_policy:generate_rules \
  --firestore-out=firestore.generated.rules --stdin
```

See `dart run firestore_access_policy:generate_rules --help`.

## Rules test skeleton

```dart
const RulesTestGenerator().generate(
  packageName: 'my_app',
  policies: catalog,
);
```

Produces a `test/` file with cases to wire to [Firebase Rules unit tests](https://firebase.google.com/docs/rules/unit-tests).

## Roadmap

| Step | Status |
|------|--------|
| Policy model + conditions | Done |
| Firestore + Storage emitters | Done |
| Safe custom output paths | Done (0.3) |
| Member-diff / parent-resource patterns | Done (0.3) |
| Rules test generator + CLI | Done (0.3) |
| Full NoteTogether parity / emulator harness | Future |

## Automated publishing

Tag `v0.3.0` on `main` after bumping `pubspec.yaml` — see [dart.dev automated publishing](https://dart.dev/tools/pub/automated-publishing) (`v{{version}}` on pub.dev).

## License

MIT — see [LICENSE](LICENSE).
