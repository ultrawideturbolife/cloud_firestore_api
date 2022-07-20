import 'package:feedback_response/feedback_response.dart';

/// Used to abstract Firestore write requests to the [FirestoreAPI].
abstract class Writeable {
  /// Indicates whether a request is valid.
  FeedbackResponse<E> isValidResponse<E>() => FeedbackResponse.successNone();

  /// Method used for serializing data to a Map format so Firestore may write it.
  Map<String, dynamic> toJson();
}
