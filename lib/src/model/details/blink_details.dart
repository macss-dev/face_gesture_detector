/// Details emitted when a complete blink cycle is detected.
///
/// A blink is defined as an open→closed→open transition of both eyes
/// completed within the configured time window (~500ms).
class BlinkDetails {
  final double leftEyeOpenness;
  final double rightEyeOpenness;
  final Duration blinkDuration;

  const BlinkDetails({
    required this.leftEyeOpenness,
    required this.rightEyeOpenness,
    required this.blinkDuration,
  });
}
