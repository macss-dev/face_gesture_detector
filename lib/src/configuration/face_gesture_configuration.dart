/// Threshold and behavior configuration for the face gesture detector.
///
/// Default values are calibrated for standard liveness flows based on
/// thresholds documented in the face verification and PAD research literature.
/// Override individual values to tune detection sensitivity.
class FaceGestureConfiguration {
  // ── Detection ─────────────────────────────────────

  /// Minimum confidence to consider a face detected. Range: 0.0–1.0.
  final double faceDetectionConfidence;

  // ── Distance ──────────────────────────────────────

  /// Bounding box ratio below which the face is classified as too far.
  final double minDistanceRatio;

  /// Bounding box ratio above which the face is classified as too close.
  final double maxDistanceRatio;

  // ── Gesture thresholds ────────────────────────────

  /// Yaw angle (degrees) beyond which a head turn is recognized.
  final double headTurnYawThreshold;

  /// Pitch angle (degrees) beyond which a head nod is recognized.
  final double headNodPitchThreshold;

  /// Eye blink blendshape value below which the eye is considered closed.
  final double blinkThreshold;

  /// Average mouth smile blendshape value above which a smile is recognized.
  final double smileThreshold;

  /// browInnerUp blendshape value above which a brow raise is recognized.
  final double browRaisedThreshold;

  /// jawOpen blendshape value above which the mouth is considered open.
  final double mouthOpenThreshold;

  // ── Gesture temporality ───────────────────────────

  /// Duration a gesture must be sustained before the callback fires.
  final Duration sustainedGestureDuration;

  // ── Performance ───────────────────────────────────

  /// Number of native frames to skip between processed frames.
  /// 0 = process every frame, 2 = process 1 out of 3.
  final int frameSkipCount;

  /// Whether to include the full 478-landmark mesh in FaceFrame.
  /// Disabled by default to reduce memory (~8KB per frame).
  final bool includeLandmarks;

  const FaceGestureConfiguration({
    this.faceDetectionConfidence = 0.5,
    this.minDistanceRatio = 0.20,
    this.maxDistanceRatio = 0.60,
    this.headTurnYawThreshold = 25.0,
    this.headNodPitchThreshold = 20.0,
    this.blinkThreshold = 0.35,
    this.smileThreshold = 0.5,
    this.browRaisedThreshold = 0.5,
    this.mouthOpenThreshold = 0.15,
    this.sustainedGestureDuration = const Duration(milliseconds: 400),
    this.frameSkipCount = 2,
    this.includeLandmarks = false,
  });
}
