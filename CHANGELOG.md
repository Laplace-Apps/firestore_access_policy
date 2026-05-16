## 0.3.0

- [RulesOutputTarget] + [RulesFileWriter]: write to custom paths; default [RulesWriteIfExists.fail] avoids overwriting `firestore.rules`.
- [RulesGeneration] orchestrates generate + write for Firestore and Storage.
- [MemberDiffPatterns] and [ParentResourcePatterns] for common collaborative rules.
- [RulesTestGenerator] emits a test file skeleton.
- CLI: `dart run firestore_access_policy:generate_rules` (`--firestore-out`, `--stdin`, `--if-exists`).

## 0.2.0

- [PolicyCondition] primitives: `Authenticated`, `And`, `Or`, `InMapKeys`, `FieldEquals`, `AuthUidEqualsField`, `CallHelper`, `RulesExpression`.
- [FirestoreRulesGenerator] emits `firestore.rules` from [FirestoreRulesFile].
- [StorageRulesGenerator] emits `storage.rules` from [StorageRulesFile].
- [AccessPolicy.rules] replaces string-only `permissions` for generation.

## 0.1.0

- Initial publishable package scaffold.
- Core policy types: [PolicyAction], [ResourcePath], [AccessPolicy].
