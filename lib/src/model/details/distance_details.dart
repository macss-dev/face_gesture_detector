import 'package:face_gesture_detector/src/model/face_landmark.dart';

/// Details emitted when the user's distance category changes.
///
/// The category is derived from the face bounding box ratio relative
/// to the frame: < minDistanceRatio = tooFar, > maxDistanceRatio = tooClose.
class DistanceDetails {
  final DistanceCategory category;
  final double boundingBoxRatio;

  const DistanceDetails({
    required this.category,
    required this.boundingBoxRatio,
  });
}
