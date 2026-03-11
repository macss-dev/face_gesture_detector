import '../configuration/face_gesture_configuration.dart';
import '../model/face_blendshape.dart';
import '../model/face_frame.dart';
import '../model/details/smile_details.dart';
import 'face_gesture_recognizer.dart';

/// Callback when a sustained smile is detected.
typedef SmileCallback = void Function(SmileDetails details);

/// Detects a sustained smile by averaging mouthSmileLeft and mouthSmileRight
/// and comparing against a configurable threshold for a sustained duration.
class SmileRecognizer extends FaceGestureRecognizer {
  SmileRecognizer({
    required FaceGestureConfiguration configuration,
    required SmileCallback onSmileDetected,
  }) : _onSmileDetected = onSmileDetected,
       super(configuration);

  final SmileCallback _onSmileDetected;
  Duration? _smileStart;

  @override
  void addFaceFrame(FaceFrame frame) {
    final left = frame.blendshapes[FaceBlendshape.mouthSmileLeft] ?? 0.0;
    final right = frame.blendshapes[FaceBlendshape.mouthSmileRight] ?? 0.0;
    final intensity = (left + right) / 2.0;

    if (intensity >= configuration.smileThreshold) {
      _smileStart ??= frame.timestamp;

      final sustained = frame.timestamp - _smileStart!;
      if (sustained >= configuration.sustainedGestureDuration) {
        _onSmileDetected(
          SmileDetails(intensity: intensity, sustainedFor: sustained),
        );
        // Reset so it can fire again on the next sustained window.
        _smileStart = null;
      }
    } else {
      _smileStart = null;
    }
  }

  @override
  void reset() {
    _smileStart = null;
  }

  @override
  void dispose() {
    // No resources to release.
  }
}
