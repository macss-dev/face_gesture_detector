import 'package:face_gesture_detector/src/configuration/face_gesture_configuration.dart';
import 'package:face_gesture_detector/src/model/face_frame.dart';
import 'package:face_gesture_detector/src/recognizer/face_gesture_recognizer.dart';

/// Callback signature for raw frame passthrough.
typedef FaceFrameCallback = void Function(FaceFrame frame);

/// Simplest recognizer — passes every frame directly to its callback.
///
/// Intended for power users who need access to every processed FaceFrame
/// without any filtering or gesture interpretation.
class RawFrameRecognizer extends FaceGestureRecognizer {
  final FaceFrameCallback onFaceFrame;

  RawFrameRecognizer({
    required FaceGestureConfiguration configuration,
    required this.onFaceFrame,
  }) : super(configuration);

  @override
  void addFaceFrame(FaceFrame frame) => onFaceFrame(frame);

  @override
  void reset() {
    // No state to reset — stateless passthrough.
  }

  @override
  void dispose() {
    // No resources to release.
  }
}
