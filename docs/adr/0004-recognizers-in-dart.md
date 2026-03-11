# 4. Gesture Recognizers Live in Dart

Date: 2026-03-10

## Status

Accepted

## Context

The processing pipeline splits into two phases:

1. **Heavy phase** — Frame → landmarks + blendshapes + transformation matrix (ML inference, 10-30ms per frame on GPU)
2. **Light phase** — FaceFrame → recognize gestures → fire callbacks (state machines and threshold comparisons, <1ms per frame)

The question is where the light phase (gesture recognition) should execute: native (Kotlin) or Dart.

Arguments for native:
- Avoids one more EventChannel round-trip
- Could reduce latency by a few milliseconds

Arguments for Dart:
- The data that recognizers process (~2KB per FaceFrame) is trivial to transfer
- Recognizers are pure business logic (state machines, thresholds, temporal windows) — not ML
- Dart recognizers are unit-testable without a device or emulator
- Developers can create custom recognizers in Dart
- The <1ms processing cost makes the location irrelevant for performance

## Decision

Gesture recognizers live in **Dart**.

The native side is responsible only for ML inference: frames in, FaceFrame out. The Dart side is responsible for all gesture recognition logic.

## Consequences

- Every recognizer is unit-testable by feeding it synthetic FaceFrames — no device, no camera, no MediaPipe
- Developers can subclass `FaceGestureRecognizer` and register custom recognizers via `RawFaceGestureDetector`
- The native layer is a pure data producer with no business logic — simpler to implement and maintain
- An EventChannel transfer of ~2KB per frame is negligible compared to the MethodChannel transfer of ~1.4MB for the input frame
- If profiling reveals that the EventChannel round-trip is a bottleneck (unlikely at 10-15fps), individual recognizers could be moved native — but this is not anticipated
