import '../configuration/face_gesture_configuration.dart';
import '../model/details/brow_details.dart';
import '../model/face_blendshape.dart';
import '../model/face_frame.dart';
import 'face_gesture_recognizer.dart';

/// Callback when a sustained brow raise is detected.
typedef BrowRaisedCallback = void Function(BrowDetails details);

/// Detects sustained brow raises by monitoring the browInnerUp blendshape
/// against a configurable threshold for a sustained duration.
class BrowRecognizer extends FaceGestureRecognizer {
  BrowRecognizer({
    required FaceGestureConfiguration configuration,
    required BrowRaisedCallback onBrowRaised,
  })  : _onBrowRaised = onBrowRaised,
        super(configuration);

  final BrowRaisedCallback _onBrowRaised;
  Duration? _browStart;

  @override
  void addFaceFrame(FaceFrame frame) {
    final intensity =
        frame.blendshapes[FaceBlendshape.browInnerUp] ?? 0.0;

    if (intensity >= configuration.browRaisedThreshold) {
      _browStart ??= frame.timestamp;

      final sustained = frame.timestamp - _browStart!;
      if (sustained >= configuration.sustainedGestureDuration) {
        _onBrowRaised(BrowDetails(intensity: intensity));
        _browStart = null;
      }
    } else {
      _browStart = null;
    }
  }

  @override
  void reset() {
    _browStart = null;
  }

  @override
  void dispose() {
    // No resources to release.
  }
}
