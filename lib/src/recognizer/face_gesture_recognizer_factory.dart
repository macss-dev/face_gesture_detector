import 'face_gesture_recognizer.dart';

/// Factory that creates a [FaceGestureRecognizer] instance.
///
/// Used by [RawFaceGestureDetector] to lazily instantiate recognizers.
/// Each recognizer type provides its own factory subclass.
abstract class FaceGestureRecognizerFactory<T extends FaceGestureRecognizer> {
  /// Creates a recognizer instance.
  T create();
}
