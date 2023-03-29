/// Represents exceptions that occur when the JSON received from an API is invalid.
///
/// The exception stores additional information about the invalid JSON, such as
/// the associated [id], the [path] where the API call was made, the [api] which
/// returned the invalid JSON, and the [data] containing the problematic JSON.
class InvalidJsonException implements Exception {
  const InvalidJsonException({
    required this.id,
    required this.path,
    required this.api,
    required this.data,
  });

  final String id;
  final String path;
  final String api;
  final Map<String, dynamic> data;
  @override
  String toString() {
    return 'InvalidJsonException{id: $id, path: $path, api: $api, data: $data}';
  }
}
