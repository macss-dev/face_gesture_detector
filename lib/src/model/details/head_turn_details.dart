/// Direction of a detected head turn (yaw axis).
enum HeadTurnDirection { left, right }

/// Details emitted when a sustained head turn is detected.
///
/// A head turn is recognized when yaw exceeds the configured threshold
/// (default ±25°) for the sustained gesture duration.
class HeadTurnDetails {
  final double yawAngle;
  final HeadTurnDirection direction;
  final Duration sustainedFor;

  const HeadTurnDetails({
    required this.yawAngle,
    required this.direction,
    required this.sustainedFor,
  });
}
