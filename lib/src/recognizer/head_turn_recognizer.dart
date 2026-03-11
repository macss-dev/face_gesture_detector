import '../configuration/face_gesture_configuration.dart';
import '../model/details/head_turn_details.dart';
import '../model/face_frame.dart';
import 'face_gesture_recognizer.dart';

/// Callback when a sustained head turn is detected.
typedef HeadTurnCallback = void Function(HeadTurnDetails details);

/// Detects sustained head turns by monitoring the yaw angle against
/// a configurable threshold for a sustained duration.
///
/// Positive yaw → left turn, negative yaw → right turn.
class HeadTurnRecognizer extends FaceGestureRecognizer {
  HeadTurnRecognizer({
    required FaceGestureConfiguration configuration,
    required HeadTurnCallback onHeadTurnDetected,
  })  : _onHeadTurnDetected = onHeadTurnDetected,
        super(configuration);

  final HeadTurnCallback _onHeadTurnDetected;
  Duration? _turnStart;

  @override
  void addFaceFrame(FaceFrame frame) {
    final yaw = frame.poseAngles.yaw;
    final threshold = configuration.headTurnYawThreshold;

    if (yaw.abs() >= threshold) {
      _turnStart ??= frame.timestamp;

      final sustained = frame.timestamp - _turnStart!;
      if (sustained >= configuration.sustainedGestureDuration) {
        _onHeadTurnDetected(HeadTurnDetails(
          yawAngle: yaw,
          direction:
              yaw > 0 ? HeadTurnDirection.left : HeadTurnDirection.right,
          sustainedFor: sustained,
        ));
        _turnStart = null;
      }
    } else {
      _turnStart = null;
    }
  }

  @override
  void reset() {
    _turnStart = null;
  }

  @override
  void dispose() {
    // No resources to release.
  }
}
