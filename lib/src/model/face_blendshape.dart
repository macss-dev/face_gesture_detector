/// The 52 MediaPipe face blendshapes, ARKit-compatible.
///
/// Each value represents a facial action unit coefficient (0.0–1.0)
/// produced by the native FaceLandmarker. Grouped by anatomical region:
/// brow (5), cheek (3), eye (14), jaw (4), mouth (23), nose (2), neutral (1).
///
/// These map 1:1 to the MediaPipe FaceLandmarker blendshape output indices.
enum FaceBlendshape {
  // ── Brow (5) ──────────────────────────────────────
  browDownLeft,
  browDownRight,
  browInnerUp,
  browOuterUpLeft,
  browOuterUpRight,

  // ── Cheek (3) ─────────────────────────────────────
  cheekPuff,
  cheekSquintLeft,
  cheekSquintRight,

  // ── Eye (14) ──────────────────────────────────────
  eyeBlinkLeft,
  eyeBlinkRight,
  eyeLookDownLeft,
  eyeLookDownRight,
  eyeLookInLeft,
  eyeLookInRight,
  eyeLookOutLeft,
  eyeLookOutRight,
  eyeLookUpLeft,
  eyeLookUpRight,
  eyeSquintLeft,
  eyeSquintRight,
  eyeWideLeft,
  eyeWideRight,

  // ── Jaw (4) ───────────────────────────────────────
  jawForward,
  jawLeft,
  jawOpen,
  jawRight,

  // ── Mouth (23) ────────────────────────────────────
  mouthClose,
  mouthDimpleLeft,
  mouthDimpleRight,
  mouthFrownLeft,
  mouthFrownRight,
  mouthFunnel,
  mouthLeft,
  mouthLowerDownLeft,
  mouthLowerDownRight,
  mouthPressLeft,
  mouthPressRight,
  mouthPucker,
  mouthRight,
  mouthRollLower,
  mouthRollUpper,
  mouthShrugLower,
  mouthShrugUpper,
  mouthSmileLeft,
  mouthSmileRight,
  mouthStretchLeft,
  mouthStretchRight,
  mouthUpperUpLeft,
  mouthUpperUpRight,

  // ── Nose (2) ──────────────────────────────────────
  noseSneerLeft,
  noseSneerRight,

  // ── Neutral (1) ───────────────────────────────────
  neutral,
}
