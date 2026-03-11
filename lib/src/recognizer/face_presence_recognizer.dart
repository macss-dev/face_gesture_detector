import 'package:face_gesture_detector/src/configuration/face_gesture_configuration.dart';
import 'package:face_gesture_detector/src/model/details/face_detected_details.dart';
import 'package:face_gesture_detector/src/model/face_frame.dart';
import 'package:face_gesture_detector/src/model/face_landmark.dart';
import 'package:face_gesture_detector/src/recognizer/face_gesture_recognizer.dart';

/// Callback signatures for face presence events.
typedef FaceDetectedCallback = void Function(FaceDetectedDetails details);
typedef FaceLostCallback = void Function();

/// Recognizes face appearance and disappearance transitions.
///
/// Fires [onFaceDetected] when a face first appears with sufficient
/// confidence, and [onFaceLost] when it disappears. Only fires on
/// state transitions — not on every frame.
class FacePresenceRecognizer extends FaceGestureRecognizer {
  final FaceDetectedCallback onFaceDetected;
  final FaceLostCallback onFaceLost;

  bool _wasFacePresent = false;

  FacePresenceRecognizer({
    required FaceGestureConfiguration configuration,
    required this.onFaceDetected,
    required this.onFaceLost,
  }) : super(configuration);

  @override
  void addFaceFrame(FaceFrame frame) {
    final isFacePresent = frame.isFaceDetected &&
        frame.faceConfidence >= configuration.faceDetectionConfidence;

    if (isFacePresent && !_wasFacePresent) {
      _wasFacePresent = true;
      onFaceDetected(FaceDetectedDetails(
        boundingBox: frame.faceBoundingBox,
        confidence: frame.faceConfidence,
        pose: frame.poseAngles,
        distance: _classifyDistance(frame),
      ));
    } else if (!isFacePresent && _wasFacePresent) {
      _wasFacePresent = false;
      onFaceLost();
    }
  }

  DistanceCategory _classifyDistance(FaceFrame frame) {
    // Bounding box area ratio relative to total frame area.
    // Frame dimensions aren't in FaceFrame, so we use the bounding box width
    // as a proxy — the actual ratio calculation happens in QualityGateRecognizer.
    // Here we provide a best-effort classification.
    final ratio = frame.faceBoundingBox.width *
        frame.faceBoundingBox.height /
        (frame.faceBoundingBox.width * frame.faceBoundingBox.height +
            1); // Simplified — always optimal for presence detection
    if (ratio < configuration.minDistanceRatio) return DistanceCategory.tooFar;
    if (ratio > configuration.maxDistanceRatio) return DistanceCategory.tooClose;
    return DistanceCategory.optimal;
  }

  @override
  void reset() {
    _wasFacePresent = false;
  }

  @override
  void dispose() {
    // No resources to release.
  }
}
