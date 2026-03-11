/// A single 3D point from the MediaPipe 478-landmark face mesh.
///
/// Coordinates are normalized to [0.0, 1.0] relative to the image dimensions.
/// The z coordinate indicates depth relative to the face center plane.
class FaceLandmark {
  final double x;
  final double y;
  final double z;

  const FaceLandmark({
    required this.x,
    required this.y,
    required this.z,
  });
}

/// Classification of the user's distance from the camera,
/// derived from the face bounding box ratio relative to the frame.
enum DistanceCategory { tooFar, tooClose, optimal }

/// Classification of the ambient brightness,
/// derived from the Y channel of the camera frame.
enum BrightnessCategory { tooDark, tooBright, optimal }
