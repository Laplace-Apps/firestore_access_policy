/// CRUD-style operations that map to Firestore `allow` clauses.
enum PolicyAction {
  /// `allow read` — get and list on a path.
  read,

  /// `allow create` — new document at this path.
  create,

  /// `allow update` — existing document at this path.
  update,

  /// `allow delete` — remove document at this path.
  delete,
}
