import '../configuration/face_gesture_configuration.dart';
import '../model/details/mouth_details.dart';
import '../model/face_blendshape.dart';
import '../model/face_frame.dart';
import 'face_gesture_recognizer.dart';

/// Callback when a sustained mouth opening is detected.
typedef MouthOpenedCallback = void Function(MouthDetails details);

/// Detects sustained mouth opening by monitoring the jawOpen blendshape
/// against a configurable threshold for a sustained duration.
class MouthRecognizer extends FaceGestureRecognizer {
  MouthRecognizer({
    required FaceGestureConfiguration configuration,
    required MouthOpenedCallback onMouthOpened,
  })  : _onMouthOpened = onMouthOpened,
        super(configuration);

  final MouthOpenedCallback _onMouthOpened;
  Duration? _mouthStart;

  @override
  void addFaceFrame(FaceFrame frame) {
    final openness =
        frame.blendshapes[FaceBlendshape.jawOpen] ?? 0.0;

    if (openness >= configuration.mouthOpenThreshold) {
      _mouthStart ??= frame.timestamp;

      final sustained = frame.timestamp - _mouthStart!;
      if (sustained >= configuration.sustainedGestureDuration) {
        _onMouthOpened(MouthDetails(openness: openness));
        _mouthStart = null;
      }
    } else {
      _mouthStart = null;
    }
  }

  @override
  void reset() {
    _mouthStart = null;
  }

  @override
  void dispose() {
    // No resources to release.
  }
}
