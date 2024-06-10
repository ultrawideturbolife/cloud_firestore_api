## 0.0.10

* **⚠️ Breaking:** Updated cloud_firestore to 5.0.0 see breaking changes here https://pub.dev/packages/cloud_firestore/changelog.

## 0.0.9+1

* **✨ New:** Removed the writable error logging to avoid sensitive data being logged.

## 0.0.9

* **✨ New:** Add the option to add `GetOptions` to a `FirestoreApi`.

## 0.0.8+3

* **✨ New:** Add `collection` and `doc` helper methods to `FirestoreApi` for easier access to collections and documents.

## 0.0.8+2

* **🐛️ Bugfix:** Fix bug where using transaction would result in unexpected DocumentReference error.

## 0.0.8+1

* **✨ New:** Added `runTransaction` helper method.

## 0.0.8

* **⚠️ Breaking:** Renamed `create`, `update` and `delete` methods to `createDoc`, `updateDoc` and `deleteDoc` in order to avoid inheritance problems with certain packages.
* **✨ New:** Added support for using a `Transaction` in `createDoc`, `updateDoc` and `deleteDoc`.

## 0.0.7+1

* **✨ New:** Updated readme.

## 0.0.7

* **⚠️ Breaking:** Renamed FirestoreAPI to FirestoreApi.

## 0.0.6+3

* **✨ New:** Added `InvalidJsonException` class for handling invalid JSON received from APIs. It includes fields for the associated `id`, `path`, `api`, and problematic `data`.

## 0.0.6+2

* **✨ New:** Added `T Function(Map<String, dynamic> json)? fromJsonError` method to FirestoreApi: This new method allows users to specify a default object to return in case data parsing fails, improving error handling and increasing resilience in the data retrieval process.

## 0.0.6+1

* **✨ New:** Enhance logging for better tracking of the cause when encountering serialization and deserialization failures.

## 0.0.6

* **⚠️ Breaking:** Rename local document reference fields to DocumentReference instead of reference.

## 0.0.5

* **✨ New:** Added support for adding local `DocumentReference` to your DTO's. Much the like local id, this will add a local `DocumentReference` to your data and remove it again when saving to firestore. This way you can keep your database clean but still have access to the local id and reference as often needed.

## 0.0.4

* **✨ New:** Added improved support for collection group queries. All regular methods now perform distinct collection group logic if `FirestoreAPI.isCollectionGroup` (in constructor) is true. Keep in mind that methods that work with specific document ids will require you to provide a `collectionPathOverride` due to Firestore limitations.

## 0.0.3+1

* **🐛️ Bugfix:** Fixed bug where search term search with numbers enables was not returning the right results.

## 0.0.3

* **✨ New:** Added option to also search for number equivalent of search term if possible by setting `doSearchNumberEquivalent` to true in `findBySearchTerm` and `findBySearchTermWithConverter` methods.
* **⚠️ Breaking:** Updates search functionality to also search field that start with given search term and renamed `SearchTermType.string` to `SearchTermType.startsWith` and renamed `SearchTermType.array` to `SearchTermType.arrayContains`.

## 0.0.2+1

* **🐛️ Bugfix:** Fixed bug where collection path was treated as a function instead of String.

## 0.0.2

* **⚠️ Breaking:** Added lazy collection path support, collection path is now a callback so you may use dynamic id's in the path if needed and the API will stay in sync.
* **✨ New:** Added support for collection group queries with `FirestoreAPI._isCollectionGroup`.z

## 0.0.1+5

* Fixed bug where feedback response required for Writeable.isValid method required generic specifications.

## 0.0.1+4

* Update example project and other small changes.

## 0.0.1+3

* Remove unused import.

## 0.0.1+2

* Add default example project.

## 0.0.1+1

* Update readme.

## 0.0.1

* Initial release.
