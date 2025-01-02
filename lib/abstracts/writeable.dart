import 'package:turbo_response/turbo_response.dart';

/// Used to abstract Firestore write requests to the [FirestoreAPI].
abstract class Writeable {
  /// Indicates whether a request is valid.
  ///
  /// Returns a [TurboResponse] indicating success or failure.
  /// - Returns [TurboResponse.emptySuccess] if the request is valid
  /// - Returns [TurboResponse.fail] with error details if invalid
  TurboResponse<void> isValidResponse() => TurboResponse.emptySuccess();

  /// Method used for serializing data to a Map format so Firestore may write it.
  Map<String, dynamic> toJson();
}
