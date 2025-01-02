# 🔥 Cloud Firestore API

This package aims to provide a powerful and flexible base class for managing Firestore collections in your Flutter applications. By extending the `FirestoreApi` class, you can create custom API classes for your specific data models and collections with ease.

Main features include:

- 🛠️ All basic CRUD operations and stream methods.
- 🔎 Convenient methods for searching/querying contents of fields and arrays of documents.
- ⏰ Automatic creation and updating of create and update fields (not mandatory).
- 📦 Batching for each method.
- 📝 Extensive logging and error handling.
- ✉️ Type-safe response handling with TurboResponse.
- 🦾 All methods are available with or without data converters.
- 🏘️ All methods work with collection groups as well.
- 💡 Able to save local id and documentReference access of your documents without adding them to your online versions.

# ❤️‍🔥 FirestoreApi Explained

The `FirestoreApi` constructor has several parameters that allow you to customize the behavior and functionality of the `FirestoreAPI` class for your specific use case. Here's an explanation of each parameter along with an example using a custom **`TasksAPI`** class:

1. **`firebaseFirestore`**: A required instance of **`FirebaseFirestore`** from the **`cloud_firestore`** package. This is the main object that you'll use to interact with your Firestore database.
2. **`collectionPath`**: A required function that returns the path of the Firestore collection as a string. This is where the data for the specific API will be stored and retrieved. This is a callback so you can change this dynamically in the callback.
3. **`fromJson`**: An optional function that takes a JSON map as input and returns an instance of your DTO class. This function is called when converting the JSON data fetched from Firestore back into your DTO object.
4. **`toJson`**: An optional function that takes a value of type **`T`** as input and returns a JSON map. This function is used to convert your DTO object into a map that can be stored in Firestore. However, this package works with a class called `**Writeable**` to create and update documents. The `**toJson**` is only called when calling native `**cloud_firestore**` methods.
5. **`fromJsonError`**: An optional function that takes a JSON map as input and returns an instance of your DTO class. This function is called when there is an error in deserializing the JSON data fetched from Firestore. It allows you to handle errors and provide a default DTO object when the JSON is invalid or the conversion fails.
6. **`tryAddLocalId`**: An optional boolean value that indicates if the local ID should be added to the document when creating or updating it. Set it to **`true`** if you want to include the local ID in your documents so you can tell your DTO to always expect it and always have access to the ID locally.
7. **`idFieldName`**: An optional string that sets the field name for the local ID in your Firestore documents. Used when `**tryAddLocalId**` is true.
8. **`tryAddLocalDocumentReference`**: An optional boolean value that indicates if the local **`DocumentReference`** should be added to the document when creating or updating it. Set it to **`true`** if you want to include the local **`DocumentReference`** in your documents so you can tell your DTO to always expect it and always have access to the `**DocumentReference**` locally.
9. **`documentReferenceFieldName`**: An optional string that sets the field name for the local `**DocumentReference**` in your Firestore documents. Used when `**tryAddLocalDocumentReference**` is true.
10. **`config`**: An optional **`TurboConfig`** object that allows you to configure the user feedback messages for various CRUD operations.
11. **`firestoreLogger`**: An optional **`FirestoreLogger`** object that can be used to log debug info, success, warning, value, and error messages related to the **`FirestoreAPI`**. This is an abstract class that you can inherit so you can pass the logging into your own system.
12. **`createdFieldName`**: An optional string that sets the field name for the 'created' timestamp in your Firestore documents. Whether to add the field to your document when creating a document is specified in the `**create**` method.
13. **`updatedFieldName`**: An optional string that sets the field name for the 'updated' timestamp in your Firestore documents. Whether to add the field to your document when creating a document is specified in the `**create**` and **`update`** methods.
14. **`isCollectionGroup`**: An optional boolean value that indicates if the API should work with a Firestore collection group. Set it to **`true`** if you are dealing with a collection group and all methods will work the same way as they do when dealing with regular collections.

### ✏️ TaskApi Example

Here's an example of a custom **`TasksAPI`** class that uses these parameters:

```dart
class TasksApi extends FirestoreApi<TaskDTO> {
  TasksAPI({required FirebaseFirestore firebaseFirestore})
      : super(
    firebaseFirestore: firebaseFirestore,
    collectionPath: () => 'tasks',
    toJson: TaskDTO.toJson,
    fromJson: TaskDTO.fromJson,
    fromJsonError: TaskDTO.fromJsonError,
    tryAddLocalId: true,
    config: TurboConfig(
      singularForm: 'task',
      pluralForm: 'tasks',
    ),
    firestoreLogger: FirestoreLogger(),
    createdFieldName: 'created',
    updatedFieldName: 'updated',
    idFieldName: 'id',
    documentReferenceFieldName: 'documentReference',
    isCollectionGroup: false,
    tryAddLocalDocumentReference: true,
  );
}
```

### ✏️ TaskDto Example

Here's an example of the `TaskDto` that is mentioned in the previous `TaskApi` example.

```dart
class TaskDto {
  final String id;
  final String title;
  final String description;
  final DateTime created;
  final DateTime updated;
  final DocumentReference? documentReference;

  TaskDto({
    required this.id,
    required this.title,
    required this.description,
    required this.created,
    required this.updated,
    this.documentReference,
  });

  // Convert TaskDTO to a JSON map
  static Map<String, dynamic> toJson(TaskDTO task) {
    return {
      'id': task.id,
      'title': task.title,
      'description': task.description,
      'created': task.created.toUtc(),
      'updated': task.updated.toUtc(),
      'documentReference': task.documentReference,
    };
  }

  // Convert JSON map to TaskDTO
  static TaskDTO fromJson(Map<String, dynamic> json) {
    return TaskDTO(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      created: (json['created'] as Timestamp).toDate(),
      updated: (json['updated'] as Timestamp).toDate(),
      documentReference: json['documentReference'] as DocumentReference?,
    );
  }

  // Handle invalid JSON data and return a default TaskDTO object
  static TaskDTO fromJsonError(Map<String, dynamic> json) {
    return TaskDTO(
      id: '',
      title: 'Unknown',
      description: 'An unknown error occurred while fetching this task',
      created: DateTime.now(),
      updated: DateTime.now(),
      documentReference: null,
    );
  }
}
```

# 🗣 TurboResponse

The `TurboResponse` class provides a type-safe way to handle operation results in your application. It's a sealed class with two variants:
- `Success<T>`: Represents a successful operation with an optional result of type `T`
- `Fail<T>`: Represents a failed operation with an error object

Each response includes:
- `title`: A title describing the operation result
- `message`: A detailed message about the operation result
- For `Success`: A result of type `T` (can be void)
- For `Fail`: An error object describing what went wrong

Here's how to use TurboResponse in your code:

```dart
// Example of handling a TurboResponse
Future<void> handleTaskCreation(TaskDTO task) async {
  final response = await tasksApi.createDoc(data: task);

  // Pattern matching with if-case
  if (response case Success(:final result)) {
    print('Task created successfully: ${result.id}');
  } else {
    print('Failed to create task');
  }

  // Or using when method
  response.when(
    success: (result) => print('Task created successfully: ${result.id}'),
    failure: (error) => print('Failed to create task: $error'),
  );
}

// Example of handling a void response
Future<void> handleTaskDeletion(String taskId) async {
  final response = await tasksApi.deleteDoc(id: taskId);

  if (response case Success()) {
    print('Task deleted successfully');
  } else if (response case Fail(:final error)) {
    print('Failed to delete task: $error');
  }
}

// Example of handling a list response
Future<void> handleTaskSearch(String searchTerm) async {
  final response = await tasksApi.findBySearchTermWithConverter(
    searchTerm: searchTerm,
    searchField: 'title',
  );

  if (response case Success(:final result)) {
    print('Found ${result.length} tasks');
    for (final task in result) {
      print('- ${task.title}');
    }
  } else {
    print('Search failed');
  }
}
```

# 🔄 Migration Guide

## Migrating from FeedbackResponse to TurboResponse

If you're upgrading from a previous version that used `FeedbackResponse`, here's how to migrate to `TurboResponse`:

1. **Update Dependencies**
   ```yaml
   dependencies:
     turbo_response: ^1.0.0 # Add this
   ```

2. **Update Configuration**
   ```dart
   // Old
   feedbackConfig: FeedbackConfig()

   // New
   config: TurboConfig(
     singularForm: 'item',
     pluralForm: 'items',
   )
   ```

3. **Update Response Handling**
   ```dart
   // Old
   response.fold(
     ifSuccess: (response) => print(response.result),
     ifError: (response) => print(response.message),
   );

   // New - Option 1: Pattern Matching
   if (response case Success(:final result)) {
     print(result);
   } else if (response case Fail(:final error)) {
     print(error);
   }

   // New - Option 2: When Method
   response.when(
     success: (result) => print(result),
     failure: (error) => print(error),
   );
   ```

4. **Key Differences**
   - `TurboResponse` is more type-safe with sealed classes
   - Error handling is more explicit with dedicated error objects
   - Pattern matching support for better flow control
   - Simpler message configuration with singular/plural forms
   - No more feedback levels or types (use your own UI feedback system)

5. **Best Practices**
   - Always specify generic types for better type safety
   - Use pattern matching for cleaner code
   - Handle both success and failure cases
   - Provide meaningful error messages in your config
   - Use singular/plural forms for better user feedback

# 🔎 Find Methods

[Rest of the existing documentation...]
