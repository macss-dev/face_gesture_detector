import 'package:face_gesture_detector/src/configuration/face_gesture_configuration.dart';
import 'package:face_gesture_detector/src/model/details/pose_details.dart';
import 'package:face_gesture_detector/src/model/face_frame.dart';
import 'package:face_gesture_detector/src/model/pose_angles.dart';
import 'package:face_gesture_detector/src/recognizer/face_gesture_recognizer.dart';

/// Callback signature for pose change events.
typedef PoseChangedCallback = void Function(PoseDetails details);

/// Recognizes significant changes in head pose angles.
///
/// Only fires [onPoseChanged] when pitch, yaw, or roll change
/// beyond a minimum delta from the last reported values — preventing
/// noise from minor natural head movement.
class PoseRecognizer extends FaceGestureRecognizer {
  final PoseChangedCallback onPoseChanged;

  /// Minimum angle change (degrees) required to trigger a new event.
  static const _minimumDelta = 5.0;

  PoseAngles? _previousAngles;

  PoseRecognizer({
    required FaceGestureConfiguration configuration,
    required this.onPoseChanged,
  }) : super(configuration);

  @override
  void addFaceFrame(FaceFrame frame) {
    final angles = frame.poseAngles;

    if (_previousAngles == null || _hasSignificantChange(angles)) {
      _previousAngles = angles;
      onPoseChanged(PoseDetails(angles: angles));
    }
  }

  bool _hasSignificantChange(PoseAngles current) {
    final prev = _previousAngles!;
    return (current.pitch - prev.pitch).abs() >= _minimumDelta ||
        (current.yaw - prev.yaw).abs() >= _minimumDelta ||
        (current.roll - prev.roll).abs() >= _minimumDelta;
  }

  @override
  void reset() {
    _previousAngles = null;
  }

  @override
  void dispose() {
    // No resources to release.
  }
}
