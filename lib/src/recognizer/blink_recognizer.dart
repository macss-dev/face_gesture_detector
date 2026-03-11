import 'package:face_gesture_detector/src/configuration/face_gesture_configuration.dart';
import 'package:face_gesture_detector/src/model/details/blink_details.dart';
import 'package:face_gesture_detector/src/model/face_blendshape.dart';
import 'package:face_gesture_detector/src/model/face_frame.dart';
import 'package:face_gesture_detector/src/recognizer/face_gesture_recognizer.dart';

/// Callback signature for blink detection events.
typedef BlinkDetectedCallback = void Function(BlinkDetails details);

/// Recognizes complete blink cycles: open → closed → open.
///
/// Tracks the eye blink blendshape values across frames, looking for
/// a transition from open (below threshold) to closed (above threshold)
/// and back to open within a maximum window (~500ms). Only reports
/// completed cycles.
class BlinkRecognizer extends FaceGestureRecognizer {
  final BlinkDetectedCallback onBlinkDetected;

  /// Maximum duration for a complete blink cycle to be recognized.
  static const _maxBlinkDuration = Duration(milliseconds: 500);

  _BlinkPhase _phase = _BlinkPhase.open;
  Duration? _closedAtTimestamp;

  BlinkRecognizer({
    required FaceGestureConfiguration configuration,
    required this.onBlinkDetected,
  }) : super(configuration);

  @override
  void addFaceFrame(FaceFrame frame) {
    final leftBlink =
        frame.blendshapes[FaceBlendshape.eyeBlinkLeft] ?? 0.0;
    final rightBlink =
        frame.blendshapes[FaceBlendshape.eyeBlinkRight] ?? 0.0;
    final averageBlink = (leftBlink + rightBlink) / 2;
    final isClosed = averageBlink >= configuration.blinkThreshold;

    switch (_phase) {
      case _BlinkPhase.open:
        if (isClosed) {
          _phase = _BlinkPhase.closed;
          _closedAtTimestamp = frame.timestamp;
        }
      case _BlinkPhase.closed:
        if (!isClosed) {
          // Eyes reopened — check if the cycle was fast enough
          final closedAt = _closedAtTimestamp!;
          final blinkDuration = frame.timestamp - closedAt;

          if (blinkDuration <= _maxBlinkDuration) {
            onBlinkDetected(BlinkDetails(
              leftEyeOpenness: leftBlink,
              rightEyeOpenness: rightBlink,
              blinkDuration: blinkDuration,
            ));
          }
          _phase = _BlinkPhase.open;
          _closedAtTimestamp = null;
        }
    }
  }

  @override
  void reset() {
    _phase = _BlinkPhase.open;
    _closedAtTimestamp = null;
  }

  @override
  void dispose() {
    // No resources to release.
  }
}

/// Internal state for the blink detection cycle.
enum _BlinkPhase { open, closed }
