## 0.0.3

* **✨ New:** Added option to also search for number equivalent of search term if possible by setting `doSearchNumberEquivalent` to true in `findBySearchTerm` and `findBySearchTermWithConverter` methods.
* **⚠️ Breaking:** Updates search functionality to also search field that start with given search term and renamed `SearchTermType.string` to `SearchTermType.startsWith` and renamed `SearchTermType.array` to `SearchTermType.arrayContains`.

## 0.0.2+1

* **🐛️ Bugfix:** Fixed bug where collection path was treated as a function instead of String.

## 0.0.2

* **⚠️ Breaking:** Added lazy collection path support, collection path is now a callback so you may use dynamic id's in the path if needed and the API will stay in sync.
* **✨ New:** Added support for collection group queries with `FirestoreAPI._isCollectionGroup`.

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
