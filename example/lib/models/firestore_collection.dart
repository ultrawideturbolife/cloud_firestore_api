/// Enum representing Firestore collection paths.
enum FirestoreCollection {
  /// Collection for tasks.
  tasks('tasks');

  const FirestoreCollection(this.path);

  /// The path of the collection in Firestore.
  final String path;
}
