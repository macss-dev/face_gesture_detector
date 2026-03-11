import 'dart:ui';

import 'package:face_gesture_detector/src/model/face_landmark.dart';
import 'package:face_gesture_detector/src/model/pose_angles.dart';

/// Details emitted when a face is detected or lost.
///
/// Provides the bounding box, detection confidence, current pose,
/// and distance classification for the detected face.
class FaceDetectedDetails {
  final Rect boundingBox;
  final double confidence;
  final PoseAngles pose;
  final DistanceCategory distance;

  const FaceDetectedDetails({
    required this.boundingBox,
    required this.confidence,
    required this.pose,
    required this.distance,
  });
}
