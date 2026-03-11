import 'package:face_gesture_detector/src/configuration/face_gesture_configuration.dart';
import 'package:face_gesture_detector/src/model/face_frame.dart';

/// Base class for all face gesture recognizers.
///
/// Each recognizer receives [FaceFrame] data and fires domain-specific
/// callbacks when a gesture is detected. Recognizers are stateful —
/// they track temporal patterns across frames.
///
/// Analogous to [GestureRecognizer] in Flutter's gesture system,
/// but operating on facial data instead of pointer events.
abstract class FaceGestureRecognizer {
  final FaceGestureConfiguration configuration;

  FaceGestureRecognizer(this.configuration);

  /// Process a new face frame from the native pipeline.
  ///
  /// Called by [RawFaceGestureDetector] for every non-skipped frame.
  void addFaceFrame(FaceFrame frame);

  /// Resets internal state to initial values.
  ///
  /// Called when the controller's reset() is invoked.
  void reset();

  /// Releases resources held by this recognizer.
  ///
  /// Called when the recognizer is removed from the active set
  /// or the widget is disposed.
  void dispose();
}
