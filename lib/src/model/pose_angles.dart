/// Euler angles derived from the 4×4 facial transformation matrix.
///
/// Produced by the native layer's EulerAngleCalculator.
/// Positive pitch = looking up, positive yaw = turned to user's left,
/// positive roll = tilted to user's right.
class PoseAngles {
  final double pitch;
  final double yaw;
  final double roll;

  const PoseAngles({
    required this.pitch,
    required this.yaw,
    required this.roll,
  });

  /// Whether the face is approximately frontal (both yaw and pitch within ±15°).
  ///
  /// Roll is excluded — a tilted head can still be frontal for capture purposes.
  bool get isFrontal => yaw.abs() < 15.0 && pitch.abs() < 15.0;
}
