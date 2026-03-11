import 'package:face_gesture_detector/src/model/pose_angles.dart';

/// Details emitted when the head pose changes beyond the configured delta.
///
/// Delegates [isFrontal] to the underlying [PoseAngles] for convenience.
class PoseDetails {
  final PoseAngles angles;

  const PoseDetails({required this.angles});

  /// Whether the face is approximately frontal (pitch and yaw within ±15°).
  bool get isFrontal => angles.isFrontal;
}
