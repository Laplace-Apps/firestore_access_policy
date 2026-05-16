/// Storage Security Rules `allow` actions.
enum StoragePolicyAction {
  /// `allow read`.
  read,

  /// `allow write` (create, update, delete).
  write,

  /// `allow create`.
  create,

  /// `allow update`.
  update,

  /// `allow delete`.
  delete,
}
