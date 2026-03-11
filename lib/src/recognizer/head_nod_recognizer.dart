import '../configuration/face_gesture_configuration.dart';
import '../model/details/head_nod_details.dart';
import '../model/face_frame.dart';
import 'face_gesture_recognizer.dart';

/// Callback when a sustained head nod is detected.
typedef HeadNodCallback = void Function(HeadNodDetails details);

/// Detects sustained head nods by monitoring the pitch angle against
/// a configurable threshold for a sustained duration.
///
/// Positive pitch → nod up, negative pitch → nod down.
class HeadNodRecognizer extends FaceGestureRecognizer {
  HeadNodRecognizer({
    required FaceGestureConfiguration configuration,
    required HeadNodCallback onHeadNodDetected,
  }) : _onHeadNodDetected = onHeadNodDetected,
       super(configuration);

  final HeadNodCallback _onHeadNodDetected;
  Duration? _nodStart;

  @override
  void addFaceFrame(FaceFrame frame) {
    final pitch = frame.poseAngles.pitch;
    final threshold = configuration.headNodPitchThreshold;

    if (pitch.abs() >= threshold) {
      _nodStart ??= frame.timestamp;

      final sustained = frame.timestamp - _nodStart!;
      if (sustained >= configuration.sustainedGestureDuration) {
        _onHeadNodDetected(
          HeadNodDetails(
            pitchAngle: pitch,
            direction: pitch > 0 ? HeadNodDirection.up : HeadNodDirection.down,
            sustainedFor: sustained,
          ),
        );
        _nodStart = null;
      }
    } else {
      _nodStart = null;
    }
  }

  @override
  void reset() {
    _nodStart = null;
  }

  @override
  void dispose() {
    // No resources to release.
  }
}
