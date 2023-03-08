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
