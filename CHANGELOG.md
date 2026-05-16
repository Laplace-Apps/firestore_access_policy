## 0.2.0

- [PolicyCondition] primitives: `Authenticated`, `And`, `Or`, `InMapKeys`, `FieldEquals`, `AuthUidEqualsField`, `CallHelper`, `RulesExpression`.
- [FirestoreRulesGenerator] emits `firestore.rules` from [FirestoreRulesFile].
- [StorageRulesGenerator] emits `storage.rules` from [StorageRulesFile].
- [AccessPolicy.rules] replaces string-only `permissions` for generation.

## 0.1.0

- Initial publishable package scaffold.
- Core policy types: [PolicyAction], [ResourcePath], [AccessPolicy].
