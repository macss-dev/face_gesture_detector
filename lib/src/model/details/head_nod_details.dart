/// Direction of a detected head nod (pitch axis).
enum HeadNodDirection { up, down }

/// Details emitted when a sustained head nod is detected.
///
/// A head nod is recognized when pitch exceeds the configured threshold
/// (default ±20°) for the sustained gesture duration.
class HeadNodDetails {
  final double pitchAngle;
  final HeadNodDirection direction;
  final Duration sustainedFor;

  const HeadNodDetails({
    required this.pitchAngle,
    required this.direction,
    required this.sustainedFor,
  });
}
