# firestore_access_policy

[![pub package](https://img.shields.io/pub/v/firestore_access_policy.svg)](https://pub.dev/packages/firestore_access_policy)
[![CI](https://github.com/Laplace-Apps/firestore_access_policy/actions/workflows/ci.yml/badge.svg)](https://github.com/Laplace-Apps/firestore_access_policy/actions/workflows/ci.yml)

Define **who can read, create, update, and delete** Firestore documents in Dart, then generate `firestore.rules` (and tests) from one source of truth.

Designed for production apps with membership maps, parent resources (e.g. group → list), field immutability, and member-diff rules. Patterns are informed by collaborative apps such as [NoteTogether](https://github.com/Laplace-Apps/top_secret_app).

## Status

Early development. Roadmap:

| Step | Focus |
|------|--------|
| **1** | Package scaffold + core policy types (this release) |
| 2 | Conditions & access primitives (auth, owner, map membership) |
| 3 | Rules language emitter |
| 4 | Patterns: parent resource, member diff, quotas |
| 5 | Rules unit-test generator + CLI |
| 6 | Reference example (lists / groups) |

## Install

```yaml
dependencies:
  firestore_access_policy: ^0.1.0
```

## Quick start

```dart
import 'package:firestore_access_policy/firestore_access_policy.dart';

final listPolicy = AccessPolicy(
  path: ResourcePath.parse('lists/{listId}'),
  description: 'Collaborative list documents',
  permissions: {
    PolicyAction.read: 'list member or parent group member',
    PolicyAction.create: 'authenticated creator with valid schema',
    PolicyAction.update: 'list member with allowed member-map diff',
    PolicyAction.delete: 'createdBy only',
  },
);
```

Step 1 defines the **policy model** only. Rule generation arrives in later steps.

## Development

```bash
dart pub get
dart test
dart analyze
dart pub publish --dry-run
```

## Related work

- [firebase_rules](https://pub.dev/packages/firebase_rules) — type-safe Rules DSL that mirrors the Rules language closely.
- **firestore_access_policy** — higher-level **access policies** (CRUD matrix, membership, relations) that emit Rules.

## License

MIT — see [LICENSE](LICENSE).
