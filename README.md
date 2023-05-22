# 🔥 Cloud Firestore API

This package aims to provide a powerful and flexible base class for managing Firestore collections in your Flutter applications. By extending the `FirestoreApi` class, you can create custom API classes for your specific data models and collections with ease.

Main features include:

- 🛠️ All basic CRUD operations and stream methods.
- 🔎 Convenient methods for searching/querying contents of fields and arrays of documents.
- ⏰ Automatic creation and updating of create and update fields (not mandatory).
- 📦 Batching for each method.
- 📝 Extensive logging and error handling.
- ✉️ User feedback messages to show to the user (not mandatory).
- 🦾 All methods are available with or without data converters.
- 🏘️ All methods work with collection groups as well.
- 💡 Able to save local id and documentReference access of your documents without adding them to your online versions.

# ❤️‍🔥 FirestoreApi Explained

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
10. **`feedbackConfig`**: An optional **`FeedbackConfig`** object that allows you to configure the user feedback messages for various CRUD operations.
11. **`firestoreLogger`**: An optional **`FirestoreLogger`** object that can be used to log debug info, success, warning, value, and error messages related to the **`FirestoreAPI`**. This is an abstract class that you can inherit so you can pass the logging into your own system.
12. **`createdFieldName`**: An optional string that sets the field name for the 'created' timestamp in your Firestore documents. Whether to add the field to your document when creating a document is specified in the `**create**` method.
13. **`updatedFieldName`**: An optional string that sets the field name for the 'updated' timestamp in your Firestore documents. Whether to add the field to your document when creating a document is specified in the `**create**` and **`update`** methods.
14. **`isCollectionGroup`**: An optional boolean value that indicates if the API should work with a Firestore collection group. Set it to **`true`** if you are dealing with a collection group and all methods will work the same way as they do when dealing with regular collections.

### ✏️ TaskApi Example

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
    feedbackConfig: FeedbackConfig(),
    firestoreLogger: FirestoreLogger(),
    createdFieldName: 'created',
    updatedFieldName: 'updated',
    idFieldName: 'id',
    documentReferenceFieldName: 'documentReference',
    isCollectionGroup: false,
    tryAddLocalDocumentReference: true,
  );
```

### ✏️ TaskDto Example

Here’s an example of the `TaskDto` that is mentioned in the previous `TaskApi` example.

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

# 🗣️ Feedback Response

The **`FeedbackResponse`** object is a versatile and customizable way to handle the results of various operations in your application. It encapsulates the outcome of an operation and provides useful information regarding its success, error, or other feedback levels. It can also hold additional data related to the operation, like the result of a Firestore query.

Here's a breakdown of the **`FeedbackResponse`** object:

1. **FeedbackLevel**: This is an enum representing the level of feedback for the response, such as success, info, warning, or error. It helps to categorize the type of outcome from the operation.
2. **FeedbackType**: This is another enum representing how the feedback should be presented to the user, e.g., as a notification, dialog, or no feedback at all.
3. **Title and Message**: These optional fields can hold strings to provide more information about the operation's outcome. They can be used, for example, in a UI to display a message or a title to the user.
4. **Result**: This is an optional field that can store the actual result of the operation, such as a fetched document or a list of documents from Firestore.
5. **Factory methods**: The **`FeedbackResponse`** class provides several factory methods, such as **`success`**, **`successNone`**, **`info`**, **`warning`**, **`error`**, and **`errorNone`**, which help create specific instances of **`FeedbackResponse`** based on the desired feedback level and type.
6. **isSuccess**: This is a getter that returns a boolean value indicating if the feedback level is either success or info.
7. **copyWith**: This method allows you to create a new **`FeedbackResponse`** object based on an existing one, but with some fields changed. It's useful when you need to create a new response based on an existing one but with minor modifications.
8. **fold**: This method provides a way to execute one of two provided callbacks depending on whether the **`isSuccess`** property is true or false. It simplifies handling different cases of success and error in the code.

When using a **`FeedbackResponse`**, you can examine its properties to determine the outcome of the operation, and you can use the **`fold`** method to handle success and error cases more concisely. You can also use the factory methods to create new **`FeedbackResponse`** objects with specific feedback levels and types, which can then be passed to your UI to display appropriate messages or notifications to the user.

Here's an example of how you might use a **`FeedbackResponse`** object when fetching a document:

```dart
class FeedbackService {
  void showFeedback(FeedbackResponse response) {
    switch (response.feedbackType) {
      case FeedbackType.notification:
        _showNotification(response);
        break;
      case FeedbackType.dialog:
        _showDialog(response);
        break;
      case FeedbackType.none:
        break;
    }
  }

  void _showNotification(FeedbackResponse response) {
    print('Showing notification: ${response.title} - ${response.message}');
  }

  void _showDialog(FeedbackResponse response) {
    print('Showing dialog: ${response.title} - ${response.message}');
  }
}

void main() async {
  TasksAPI tasksApi = TasksAPI();
  FeedbackService feedbackService = FeedbackService();

  FeedbackResponse<TaskDTO> response = await tasksApi.findTaskByIdWithConverter('taskId123');

  response.fold(
    ifSuccess: (successfulResponse) {
      // Handle success.
      TaskDTO task = successfulResponse.result!;
      print('Task fetched successfully: ${task.title}');

      // Show success feedback.
      feedbackService.showFeedback(successfulResponse);
    },
    ifError: (errorResponse) {
      // Handle error.
      print('Failed to fetch the task: ${errorResponse.message}');

      // Show error feedback.
      feedbackService.showFeedback(errorResponse);
    },
  );
}
```

In this example, we've created a **`FeedbackService`** class with a **`showFeedback`** method that displays the appropriate feedback based on the **`FeedbackType`** of the **`FeedbackResponse`**. Inside the **`main`** function, we instantiate the **`FeedbackService`** and use it to show feedback based on the response from the **`findTaskByIdWithConverter`** method.

# 🔎 Find Methods

The Firestore API provides a set of powerful methods for finding documents in your Firestore collections. These methods offer various ways to retrieve documents based on their unique identifiers, along with the option to use converters for custom data handling. With these find methods, you can easily fetch documents from Firestore, handle errors, and provide appropriate feedback to the users.

In this section, we will explore the different find methods available in the Firestore API, their usage, and how they can be combined with custom converters and the FeedbackResponse system for seamless data retrieval and user experience.

### 👀 Find by id

The `**findByIdWithConverter**` method fetches a document from the Firestore collection with the given document ID and applies a converter function (provided as a parameter) to convert the raw JSON data into a custom Dart object (in this case, a **`TaskDTO`**). It returns a **`FeedbackResponse`** object containing the converted data as an instance of the custom Dart object.

Example usage with **`TasksAPI`**:

```dart
class TasksAPI extends FirestoreAPI<TaskDTO> {
  // constructor and other methods

  Future<FeedbackResponse<TaskDTO>> findTaskByIdWithConverter(String taskId) async {
    return await findByIdWithConverter(id: taskId);
  }
}
```

In this example, the **`findTaskByIdWithConverter`** method uses the **`findByIdWithConverter`** method to fetch a task with the provided **`taskId`**. The returned data is automatically converted into a **`TaskDTO`** object using the provided converter function (in this case, **`TaskDTO.fromJson`**) and wrapped in a **`FeedbackResponse`** object.

The `**findById**` method is similar to **`findByIdWithConverter`**, but it doesn't apply a converter function to the fetched data. Instead, it returns a **`FeedbackResponse`** object containing the raw JSON data as a **`Map<String, dynamic>`**.

Using the same **`TasksAPI`** example, if you wanted to fetch a task without converting it to a **`TaskDTO`** object, you could use the **`findById`** method like this:

```dart
class TasksAPI extends FirestoreAPI<TaskDTO> {
  // constructor and other methods

  Future<FeedbackResponse<Map<String, dynamic>>> findTaskById(String taskId) async {
    return await findById(id: taskId);
  }
}
```

In this example, the **`findTaskById`** method uses the **`findById`** method to fetch a task with the provided **`taskId`**. The returned data is wrapped in a **`FeedbackResponse`** object containing the raw JSON data as a **`Map<String, dynamic>`**.

In summary, the **`findByIdWithConverter`** method is used when you want to fetch a document and convert it into a custom Dart object automatically, whereas the **`findById`** method is used when you want to fetch a document and receive the raw JSON data without applying any conversion. Both methods return a **`FeedbackResponse`** object, which provides information on the success or failure of the request.

### 🔦 Find by Search Term

The **`findBySearchTermWithConverter`** method is used to search for documents in a Firestore collection based on a specific search term, field, and search term type. The method returns a **`FeedbackResponse<List<T>>`**, where **`T`** is the type of the data model you're working with. This method uses a converter to handle data conversion between Firestore and your data model.

Here's an explanation of the method parameters:

- **`searchTerm`**: The term you want to search for in the specified field.
- **`searchField`**: The field you want to search in.
- **`searchTermType`**: The type of the search term (e.g., string, array).
- **`doSearchNumberEquivalent`**: Whether to search for a numeric equivalent of the search term if it's a valid number.
- **`limit`**: An optional parameter to limit the number of results returned.

Now, let's see an example using **`TaskDto`** and **`TaskApi`**.

```dart
class TaskDto {
  // Task properties go here
}

class TaskApi extends FirestoreApi<TaskDto> {
  TaskApi()
      : super(
            // Initialization parameters go here
          );

  // Additional TaskApi methods go here
}

void main() async {
  final taskApi = TaskApi();

  final searchTerm = 'Sample Task';
  final searchField = 'title';
  final searchTermType = SearchTermType.String;

  final response = await taskApi.findBySearchTermWithConverter(
    searchTerm: searchTerm,
    searchField: searchField,
    searchTermType: searchTermType,
  );

  response.fold(
    ifSuccess: (result) {
      FeedbackService.showSuccess('Tasks found', 'The following tasks were found:');
      for (var task in result.result) {
        print(task);
      }
    },
    ifError: (errorResponse) {
      FeedbackService.showError('Error', 'Failed to fetch tasks.');
    },
  );
}
```

The **`findBySearchTermWithConverter`** method searches for tasks with the given search term in the specified field, using the specified search term type. It returns a **`FeedbackResponse<List<TaskDto>>`**, which can then be handled using the **`fold`** method to show success or error feedback using the **`FeedbackService`**.

The difference between the **`findBySearchTermWithConverter`** and the non-converter variant (**`findBySearchTerm`**) is that the non-converter variant returns raw data in the form of **`FeedbackResponse<List<Map<String, dynamic>>>`** without converting the data to your custom data model. The non-converter variant requires you to handle the conversion manually, while the converter variant takes care of it automatically using the provided converter functions.

### 🕵️‍♀️ Find by query

The **`findByQueryWithConverter`** method is used to search for documents in a Firestore collection by providing a custom query. The method returns a **`FeedbackResponse<List<T>>`**, where **`T`** is the type of the data model you're working with. This method uses a converter to handle data conversion between Firestore and your data model.

Here's an explanation of the method parameters:

- **`collectionReferenceQuery`**: A function that takes a **`CollectionReference`** and returns a **`Query`** object with the desired query constraints.
- **`whereDescription`**: A string description of the query's conditions for logging purposes.

Now, let's see an example using **`TaskDto`** and **`TaskApi`**.

```dart
class TaskDto {
  // Task properties go here
}

class TaskApi extends FirestoreApi<TaskDto> {
  TaskApi()
      : super(
            // Initialization parameters go here
          );

  // Additional TaskApi methods go here
}

void main() async {
  final taskApi = TaskApi();

  final dueDate = DateTime.now().add(Duration(days: 7));

  final response = await taskApi.findByQueryWithConverter(
    collectionReferenceQuery: (collectionReference) {
      return collectionReference.where('dueDate', isLessThanOrEqualTo: dueDate);
    },
    whereDescription: 'dueDate is less than or equal to $dueDate',
  );

  response.fold(
    ifSuccess: (result) {
      FeedbackService.showSuccess('Tasks found', 'The following tasks were found:');
      for (var task in result.result) {
        print(task);
      }
    },
    ifError: (errorResponse) {
      FeedbackService.showError('Error', 'Failed to fetch tasks.');
    },
  );
}

```

The **`findByQueryWithConverter`** method searches for tasks with a custom query, in this case, tasks with a **`dueDate`** less than or equal to a specified date. It returns a **`FeedbackResponse<List<TaskDto>>`**, which can then be handled using the **`fold`** method to show success or error feedback using the **`FeedbackService`**.

The difference between the **`findByQueryWithConverter`** and the non-converter variant (**`findByQuery`**) is that the non-converter variant returns raw data in the form of **`FeedbackResponse<List<Map<String, dynamic>>>`** without converting the data to your custom data model. The non-converter variant requires you to handle the conversion manually, while the converter variant takes care of it automatically using the provided converter functions.

### 👻 Find all

The **`findAllWithConverter`** method is used to fetch all documents from a Firestore collection. The method returns a **`FeedbackResponse<List<T>>`**, where **`T`** is the type of the data model you're working with. This method uses a converter to handle data conversion between Firestore and your data model.

Here's an example using **`TaskDto`** and **`TaskApi`**.

```dart
class TaskDto {
  // Task properties go here
}

class TaskApi extends FirestoreApi<TaskDto> {
  TaskApi()
      : super(
            // Initialization parameters go here
          );

  // Additional TaskApi methods go here
}

void main() async {
  final taskApi = TaskApi();

  final response = await taskApi.findAllWithConverter();

  response.fold(
    ifSuccess: (result) {
      FeedbackService.showSuccess('Tasks found', 'The following tasks were found:');
      for (var task in result.result) {
        print(task);
      }
    },
    ifError: (errorResponse) {
      FeedbackService.showError('Error', 'Failed to fetch tasks.');
    },
  );
}

```

The **`findAllWithConverter`** method fetches all tasks from the Firestore collection and returns a **`FeedbackResponse<List<TaskDto>>`**. The response can then be handled using the **`fold`** method to show success or error feedback using the **`FeedbackService`**.

The difference between the **`findAllWithConverter`** and the non-converter variant (**`findAll`**) is that the non-converter variant returns raw data in the form of **`FeedbackResponse<List<Map<String, dynamic>>>`** without converting the data to your custom data model. The non-converter variant requires you to handle the conversion manually, while the converter variant takes care of it automatically using the provided converter functions.

### 💧 Streams and other find methods

- **`findCollectionWithConverter`** and **`findCollection`**:
    - **`findCollectionWithConverter`**: Retrieves a collection as type **`T`** using the specified **`_fromJson`** and **`_toJson`** methods for conversion. Example usage:

        ```dart
        final collection = firestoreApi.findCollectionWithConverter<T>();
        ```

    - **`findCollection`**: Retrieves a collection as a Map. Example usage:

        ```dart
        final collection = firestoreApi.findCollection();
        ```

- **`findDocRefWithConverter`** and **`findDocRef`**:
    - **`findDocRefWithConverter`**: Retrieves a document reference as type **`T`** using the specified **`_fromJson`** and **`_toJson`** methods for conversion. Example usage:

        ```dart
        final docRef = firestoreApi.findDocRefWithConverter<T>(id: 'doc_id');
        ```

    - **`findDocRef`**: Retrieves a document reference as a Map. Example usage:

        ```dart
        final docRef = firestoreApi.findDocRef(id: 'doc_id');
        ```

- **`findDocSnapshotWithConverter`** and **`findDocSnapshot`**:
    - **`findDocSnapshotWithConverter`**: Retrieves a document snapshot as type **`T`** using the specified **`_fromJson`** and **`_toJson`** methods for conversion. Example usage:

        ```dart
        final docSnapshot = await firestoreApi.findDocSnapshotWithConverter<T>(id: 'doc_id');
        ```

    - **`findDocSnapshot`**: Retrieves a document snapshot as a Map. Example usage:

        ```dart
        final docSnapshot = await firestoreApi.findDocSnapshot(id: 'doc_id');
        ```

- **`findStreamWithConverter`** and **`findStream`**:
    - **`findStreamWithConverter`**: Retrieves a stream of a list of type **`T`** using the specified **`_fromJson`** and **`_toJson`** methods for conversion. Example usage:

        ```dart
        final stream = firestoreApi.findStreamWithConverter<T>();
        ```

    - **`findStream`**: Retrieves a stream of a list of Maps. Example usage:

        ```dart
        final stream = firestoreApi.findStream();d
        ```

- **`findStreamByQueryWithConverter`** vs **`findStreamByQuery`**:
    - **`findStreamByQueryWithConverter`**: Retrieves a stream of a list of type **`T`** based on the given **`collectionReferenceQuery`** and **`whereDescription`**, using the specified **`_fromJson`** and **`_toJson`** methods for conversion. Example usage:

        ```dart
        final stream = firestoreApi.findStreamByQueryWithConverter<T>(
          collectionReferenceQuery: (collection) => collection.where('field', isEqualTo: 'value'),
          whereDescription: "field == value",
        );
        ```

    - **`findStreamByQuery`**: Retrieves a stream of a list of Maps based on the given **`collectionReferenceQuery`** and **`whereDescription`**. Example usage:

        ```dart
        final stream = firestoreApi.findStreamByQuery(
          collectionReferenceQuery: (collection) => collection.where('field', isEqualTo: 'value'),
          whereDescription: "field == value",
        );
        ```

- **`findDocStreamWithConverter`** and **`findDocStream`**:
    - **`findDocStreamWithConverter`**: Retrieves a document stream as type **`T`** using the specified **`_fromJson`** and **`_toJson`** methods for conversion. Example usage:

        ```dart
        final docStream = firestoreApi.findDocStreamWithConverter<T>(id: 'doc_id');
        ```

    - **`findDocStream`**: Retrieves a document stream as a Map. Example usage:

        ```dart
        final docStream = firestoreApi.findDocStream(id: 'doc_id');
        ```


# ✍️ Writeable

The **`Writeable`** class is an abstract class designed to represent a data object that can be written to Firestore. By creating custom classes that extend **`Writeable`**, developers can ensure that their data models are compatible with the Firestore API while also providing a clear structure for their code. The main functionalities of the **`Writeable`** class include:

1. **`toJson()`**: This method should be overridden in the custom class that extends **`Writeable`**. It is responsible for converting the data object into a JSON-like structure that can be written to Firestore.
2. **`isValidResponse()`**: This method returns a **`FeedbackResponse`** object that provides information about the validity of the data object, including a success flag, title, and message. It is typically called internally by the **`create`** and **`update`** methods in the API to ensure that the data is valid before attempting to write it to Firestore.

Here is an example of a custom **`UpdateTaskRequest`** class that extends the **`Writeable`** class:

```dart
class UpdateTaskRequest extends Writeable {
  final String title;
  final String description;
  final bool isCompleted;

  UpdateTaskRequest({required this.title, required this.description, this.isCompleted = false});

  @override
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
    };
  }

  @override
  FeedbackResponse isValidResponse() {
    if (title.isNotEmpty && description.isNotEmpty) {
      return FeedbackResponse.successNone();
    } else {
      return FeedbackResponse.error(
        title: 'Invalid Task',
        message: 'Task title and description cannot be empty.',
      );
    }
  }
}
```

In this example, a **`Task`** object is considered valid if its **`title`** and **`description`** are not empty. The **`toJson`** method converts the **`Task`** object into a JSON-like structure suitable for Firestore. When using the **`create`** or **`update`** methods in the API, the `UpdateTaskRequest` class can now be passed as a **`Writeable`** object.

# 🪄 Create and Update methods

We provide custom **`create`** and **`update`** methods designed to simplify working with Firestore. The **`create`** method allows you to create a new document based on a **`Writeable`** object, while the **`update`** method enables you to modify existing documents using a similar approach. Both methods offer additional features, such as support for batch operations, automatic handling of timestamp fields, merge and mergeFields options, and collection path overrides for collection groups.

### 🦄 Creating and batch creating

The **`create`** method is designed to create or update a document in a Firestore collection based on the given **`Writeable`** object. It provides options for setting a custom ID, using a **`WriteBatch`** object, and controlling the creation and update timestamps. Additionally, you can use the **`merge`** and **`mergeFields`** options to control the update behavior. If the **`create`** method is called with a **`WriteBatch`**, it delegates the write operation to the **`batchCreate`** method.

Here's a step-by-step explanation of the **`create`** method:

1. Check if the **`Writeable`** object is valid using **`isValidResponse()`**.
2. If valid, determine the document reference based on the provided **`id`** and **`collectionPathOverride`**.
3. If a **`WriteBatch`** is provided, call the **`batchCreate`** method and commit the batch after the last operation is added.
4. If no **`WriteBatch`** is provided, convert the **`Writeable`** object to JSON and set the appropriate timestamps based on **`createTimeStampType`** and **`updateTimeStampType`**.
5. Update or create the document in Firestore using **`documentReference.set()`** with the specified **`SetOptions`**.

The **`batchCreate`** method is similar to the **`create`** method but is specifically designed to work with a **`WriteBatch`** object. It adds the write operation to the provided or newly created **`WriteBatch`** without committing it. This allows you to perform multiple create or update operations in a single transaction.

Here's an example using an `**p**` and **`TaskApi`**:

```dart
class UpdateTaskRequest extends Writeable {
  final String title;
  final String description;
  final bool isCompleted;

  UpdateTaskRequest({required this.title, required this.description, this.isCompleted = false});

  @override
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
    };
  }

  @override
  FeedbackResponse isValidResponse() {
    if (title.isNotEmpty && description.isNotEmpty) {
      return FeedbackResponse.successNone();
    } else {
      return FeedbackResponse.error(
        title: 'Invalid Task',
        message: 'Task title and description cannot be empty.',
      );
    }
  }
}

class TaskDto implements Writeable {
  // Your TaskDto implementation
}

class TaskApi extends FirestoreApi<TaskDto> {
  TaskApi()
      : super(
            // Initialization parameters go here
          );

  // Additional TaskApi methods go here
}

void main() async {
  TaskApi taskApi = TaskApi();
  TaskDto taskDto = TaskDto(/* Your TaskDto data */);

  // Create a new task document using the create method
  FeedbackResponse<DocumentReference> response = await taskApi.createDoc(writeable: taskDto);
  if (response.isSuccess) {
    print('Task document created successfully with ID: ${response.result!.id}');
  } else {
    print('Failed to create task document: ${response.message}');
  }

  // Update an existing task document
  String taskId = 'your-task-id'; // Replace with your actual task ID
  UpdateTaskRequest updateRequest = UpdateTaskRequest(title: 'New Title', description: 'New Description');
  FeedbackResponse<void> updateResponse = await taskApi.updateDoc(id: taskId, writeable: updateRequest);
  if (updateResponse.isSuccess) {
    print('Task document updated successfully');
  } else {
    print('Failed to update task document: ${updateResponse.message}');
  }

  // Create a WriteBatch
  WriteBatch writeBatch = FirebaseFirestore.instance.batch();

  // Add multiple tasks to the WriteBatch using the batchCreate method
  TaskDto taskDto2 = TaskDto(/* Your TaskDto data */);
  TaskDto taskDto3 = TaskDto(/* Your TaskDto data */);

  await taskApi.batchCreate(writeable: taskDto2, writeBatch: writeBatch);
  await taskApi.batchCreate(writeable: taskDto3, writeBatch: writeBatch);

  // Commit the WriteBatch
  await writeBatch.commit();
  print('WriteBatch committed successfully');
}
```

The main difference between the **`create`** and **`batchCreate`** methods is that the **`create`** method directly commits the data to Firestore, while the **`batchCreate`** method adds the data to a Firestore **`WriteBatch`**. The **`WriteBatch`** can be committed later to perform multiple writes in a single transaction.

### **🚀 Updating and batch updating**

The **`update`** method is designed to update an existing document in a Firestore collection based on the given **`Writeable`** object and document **`id`**. It provides options for using a **`WriteBatch`** object and controlling the update timestamps. Additionally, you can use the **`merge`** and **`mergeFields`** options to control the update behavior. If the **`update`** method is called with a **`WriteBatch`**, it delegates the write operation to the **`batchUpdate`** method.

Here's a step-by-step explanation of the **`update`** method:

1. Check if the **`Writeable`** object is valid using **`isValidResponse()`**.
2. If valid, determine the document reference based on the provided **`id`** and **`collectionPathOverride`**.
3. If a **`WriteBatch`** is provided, call the **`batchUpdate`** method and commit the batch after the last operation is added.
4. If no **`WriteBatch`** is provided, convert the **`Writeable`** object to JSON and set the appropriate timestamps based on **`updateTimeStampType`**.
5. Update the document in Firestore using **`documentReference.updateDoc()`** with the specified **`UpdateOptions`**.

The **`batchUpdate`** method is similar to the **`update`** method but is specifically designed to work with a **`WriteBatch`** object. It adds the update operation to the provided or newly created **`WriteBatch`** without committing it. This allows you to perform multiple update operations in a single transaction.

Here's an example using **`UpdateTaskRequest`** and **`TaskApi`**:

```dart
class UpdateTaskRequest extends Writeable {
  final String title;
  final String description;
  final bool isCompleted;

  UpdateTaskRequest({required this.title, required this.description, this.isCompleted = false});

  @override
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
    };
  }

  @override
  FeedbackResponse isValidResponse() {
    if (title.isNotEmpty && description.isNotEmpty) {
      return FeedbackResponse.successNone();
    } else {
      return FeedbackResponse.error(
        title: 'Invalid Task',
        message: 'Task title and description cannot be empty.',
      );
    }
  }
}

class TaskDto implements Writeable {
  // Your TaskDto implementation
}

class TaskApi extends FirestoreApi<TaskDto> {
  TaskApi()
      : super(
            // Initialization parameters go here
          );

  // Additional TaskApi methods go here
}

void main() async {
  TaskApi taskApi = TaskApi();
  String taskId = 'your-task-id'; // Replace with your actual task ID
  UpdateTaskRequest updateRequest =
      UpdateTaskRequest(title: 'New Title', description: 'New Description');

  // Update a task document using the update method
  FeedbackResponse<void> updateResponse =
      await taskApi.updateDoc(id: taskId, writeable: updateRequest);
  if (updateResponse.isSuccess) {
    print('Task document updated successfully');
  } else {
    print('Failed to update task document: ${updateResponse.message}');
  }

// Create a WriteBatch
  WriteBatch writeBatch = FirebaseFirestore.instance.batch();

// Update multiple tasks in the WriteBatch using the batchUpdate method
  String taskId2 = 'your-task-id-2'; // Replace with your actual task ID
  String taskId3 = 'your-task-id-3'; // Replace with your actual task ID
  UpdateTaskRequest updateRequest2 =
      UpdateTaskRequest(title: 'New Title 2', description: 'New Description 2');
  UpdateTaskRequest updateRequest3 =
      UpdateTaskRequest(title: 'New Title 3', description: 'New Description 3', isCompleted: true);

  await taskApi.batchUpdate(id: taskId2, writeable: updateRequest2, writeBatch: writeBatch);
  await taskApi.batchUpdate(id: taskId3, writeable: updateRequest3, writeBatch: writeBatch);

// Commit the WriteBatch
  await writeBatch.commit();
  print('WriteBatch committed successfully');
}
```

The main difference between the **`update`** and **`batchUpdate`** methods is that the **`update`** method directly commits the data to Firestore, while the **`batchUpdate`** method adds the data to a Firestore **`WriteBatch`**. The **`WriteBatch`** can be committed later to perform multiple updates in a single transaction.

### **🗑️ Delete and batch delete**

The **`delete`** method is designed to delete a document in a Firestore collection based on the given **`id`**. It provides options for using a **`WriteBatch`** object and overriding the **`collectionPath`**. If the **`delete`** method is called with a **`WriteBatch`**, it delegates the delete operation to the **`batchDelete`** method.

Here's a step-by-step explanation of the **`delete`** method:

1. Check if the **`collectionPathOverride`** is provided or not.
2. If a **`WriteBatch`** is provided, call the **`batchDelete`** method and commit the batch after the last operation is added.
3. If no **`WriteBatch`** is provided, determine the document reference based on the provided **`id`** and **`collectionPathOverride`**.
4. Delete the document in Firestore using **`documentReference.deleteDoc()`**.

The **`batchDelete`** method is similar to the **`delete`** method but is specifically designed to work with a **`WriteBatch`** object. It adds the delete operation to the provided or newly created **`WriteBatch`** without committing it. This allows you to perform multiple delete operations in a single transaction.

Here's an example using **`TaskApi`**:

```dart
class TaskApi extends FirestoreApi<TaskDto> {
  TaskApi()
      : super(
            // Initialization parameters go here
          );

  // Additional TaskApi methods go here
}

void main() async {
  TaskApi taskApi = TaskApi();

  // Delete a task document using the delete method
  String taskId = 'your-task-id'; // Replace with your actual task ID
  FeedbackResponse<void> deleteResponse = await taskApi.deleteDoc(id: taskId);
  if (deleteResponse.isSuccess) {
    print('Task document deleted successfully');
  } else {
    print('Failed to delete task document: ${deleteResponse.message}');
  }

  // Create a WriteBatch
  WriteBatch writeBatch = FirebaseFirestore.instance.batch();

  // Add multiple task deletions to the WriteBatch using the batchDelete method
  String taskId2 = 'your-task-id-2'; // Replace with your actual task ID
  String taskId3 = 'your-task-id-3'; // Replace with your actual task ID

  await taskApi.batchDelete(id: taskId2, writeBatch: writeBatch);
  await taskApi.batchDelete(id: taskId3, writeBatch: writeBatch);

  // Commit the WriteBatch
  await writeBatch.commit();
  print('WriteBatch committed successfully');
}
```

The main difference between the **`delete`** and **`batchDelete`** methods is that the **`delete`** method directly commits the deletion to Firestore, while the **`batchDelete`** method adds the deletion to a Firestore **`WriteBatch`**. The **`WriteBatch`** can be committed later to perform multiple deletions in a single transaction.

### 🦿 Combining create, update and delete batch methods

The `FirestoreAPI` package allows you to combine **`create`**, **`update`**, and **`delete`** operations in a single **`WriteBatch`**, providing a powerful way to perform multiple write operations in a single transaction. This ensures that all changes are atomic, meaning that either all operations succeed or none do, ensuring data consistency in your Firestore database. Combining these batch operations reduces the number of network calls and improves the overall efficiency of your application. By using **`batchCreate`**, **`batchUpdate`**, and **`batchDelete`** methods in conjunction with a **`WriteBatch`** object, you can easily manage complex scenarios that involve creating, updating, and deleting multiple documents at once, providing a robust and scalable solution for your data manipulation needs.

# ❌ Deserialization Errors

The **`fromJsonError`** is a method that allows you to handle errors when deserializing a JSON object into your desired data transfer object (DTO). It serves as a custom error handling mechanism when converting the JSON data into a Dart object. This method is provided as a parameter when initializing the FirestoreAPI or its subclasses.

Here's an example of how to use **`fromJsonError`** with a custom DTO:

- Create a custom DTO class that extends a base DTO class. In this example, we'll use **`TaskDTO`**.

```dart
class TaskDto extends BaseDto {
  final String id;
  final String title;
  final String description;
  final bool isComplete;

  TaskDto({
    required this.id,
    required this.title,
    required this.description,
    required this.isComplete,
  });

  factory TaskDto.fromJson(Map<String, dynamic> json) {
    return TaskDto(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      isComplete: json['isComplete'],
    );
  }

  static TaskDto fromJsonError(Map<String, dynamic> json) {
    // Custom error handling when JSON is invalid or conversion fails
    return TaskDto(
      id: json['id'] ?? 'Invalid ID',
      title: json['title'] ?? 'Invalid Title',
      description: json['description'] ?? 'Invalid Description',
      isComplete: json['isComplete'] ?? false,
    );
  }
}
```

- Now, when creating an instance of your custom FirestoreAPI class (e.g., **`TasksAPI`**), you can pass the **`fromJsonError`** method as a parameter:

```dart
class TasksApi extends FirestoreApi<TaskDto> {
  TasksApi({required FirebaseFirestore firebaseFirestore})
      : super(
          firebaseFirestore: firebaseFirestore,
          collectionPath: () => 'tasks',
          fromJsonError: TaskDto.fromJsonError,
        );
}
```

In this example, if the JSON object received from Firestore contains invalid data or fails to convert into a **`TaskDTO`** object, the **`fromJsonError`** method will be called to handle the error and provide a default **`TaskDTO`** object with values indicating the errors.
