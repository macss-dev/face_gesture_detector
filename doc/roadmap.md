# FaceGestureDetector — Roadmap

> Incremental delivery plan from a working Android plugin to a multi-platform ecosystem.
> Each version delivers shippable value. No version depends on speculative requirements.

---

## V1 — Core Plugin (Android)

**Goal:** A working `FaceGestureDetector` widget that translates camera frames into facial gesture callbacks on Android.

### Scope

| Area | Deliverable |
|------|------------|
| **Widget** | `FaceGestureDetector` (StatelessWidget facade) + `RawFaceGestureDetector` (StatefulWidget lifecycle) |
| **Recognizers** | FacePresence, QualityGate, Pose, Blink, Smile, HeadTurn, HeadNod, Brow, RawFrame |
| **Data model** | `FaceFrame`, `PoseAngles`, `ImageQualityMetrics`, `FaceBlendshape` enum, all Details objects |
| **Configuration** | `FaceGestureConfiguration` with calibrated defaults |
| **Controller** | `FaceGestureDetectorController` (pause, resume, reset) |
| **Platform** | `FaceGestureDetectorPlatform` (abstract) + `MethodChannelFaceGestureDetector` |
| **Native (Android)** | `FaceLandmarkerEngine` (MediaPipe LIVE_STREAM, GPU delegate), `FaceFrameStreamHandler`, `SingleSlotFrameBuffer`, `FrameDecoder`, `EulerAngleCalculator` |
| **Integration** | Platform Channel: CameraImage bytes cross Dart↔Native boundary |
| **Testing** | Unit tests for all recognizers (synthetic FaceFrames), widget tests for callback→recognizer mapping, integration test on device |
| **Platform** | Android only (min SDK 24) |

### Key Constraints

- Frames cross the Dart↔Native boundary (~1.4MB per frame at 720p)
- Frame skipping (default: process 1 out of 3) keeps throughput at ~10-15fps
- MediaPipe LIVE_STREAM mode handles additional frame dropping internally
- `CameraController` from the `camera` package is the only supported frame source

### Exit Criteria

- [x] Developer can wrap `CameraPreview` with `FaceGestureDetector` and receive callbacks — *completed in v0.2.0: `cameraController` parameter wires the full pipeline*
- [x] Null callbacks produce zero recognizer overhead — callbacks-as-subscription implemented; `null` callback = recognizer not created
- [x] All quality gates from PAD state-of-the-art have a corresponding callback — brightness, sharpness, distance, pose, eyes, mouth all mapped
- [x] Recognizers are unit-testable with synthetic FaceFrames (no device required) — 117 Dart unit tests pass with synthetic data
- [x] Example app demonstrates a complete liveness challenge flow — *completed in v0.2.0: live camera, face detection indicator, all gesture callbacks in event log*

---

## V2 — Performance Optimization

**Goal:** Eliminate the Dart↔Native frame copy overhead without changing the public API.

### Scope

| Area | Deliverable |
|------|------------|
| **Native optimization** | CameraX ImageAnalysis shared analyzer: the native side hooks into the same CameraX instance used by the camera plugin, processing frames without them ever crossing the Dart↔Native boundary |
| **Performance metrics** | Expose `processingFps`, `averageLatencyMs`, `droppedFrameCount` via controller |
| **Adaptive frame rate** | Dynamically adjust frame skip count based on device processing capacity |

### Key Insight

The camera plugin on Android uses CameraX internally. V2's native layer accesses the same CameraX pipeline and attaches an `ImageAnalysis` use case. Frames flow from CameraX → MediaPipe entirely on the native side (zero-copy). The Dart side only receives the lightweight FaceFrame (~2KB) via EventChannel — same as V1.

### API Impact

**None.** The public API (`FaceGestureDetector`, `RawFaceGestureDetector`, all callbacks and Details objects) remains identical. The optimization is entirely internal to the platform implementation.

### Exit Criteria

- [ ] Frame data no longer crosses Dart↔Native boundary
- [ ] Processing latency reduced by ≥40% compared to V1
- [ ] `FaceGestureDetectorController` exposes real-time performance metrics
- [ ] All V1 tests still pass without modification

---

## V3 — Extensibility

**Goal:** Enable advanced use cases and third-party integrations without forking the plugin.

### Scope

| Area | Deliverable |
|------|------------|
| **FrameSource abstraction** | `FrameSource` interface: allows frame sources other than `CameraController` (e.g. video files, custom camera implementations) |
| **Custom recognizers** | Documented API for creating and registering custom `FaceGestureRecognizer` subclasses via `RawFaceGestureDetector` |
| **FaceChallengeController** | Optional helper that implements standard challenge flows (frontal → turn left → turn right → done) as a state machine, so apps don't have to build this from scratch |
| **Best frame capture** | `captureBestFrame()` on the controller: returns the highest-quality FaceFrame from the last N frames based on quality metrics |

### Key Principle

Extensibility is **earned, not anticipated** (R-TEC-03). These abstractions are only introduced when V1 and V2 have proven the concrete implementations they generalize.

### API Impact

- New: `FrameSource` abstract class (V1's `CameraController` support becomes `CameraControllerFrameSource`)
- New: `FaceChallengeController` (optional, separate class)
- New: `captureBestFrame()` on `FaceGestureDetectorController`
- `RawFaceGestureDetector` already supports custom recognizers — V3 adds documentation and examples

### Exit Criteria

- [ ] At least one non-CameraController FrameSource demonstrated (e.g. video file)
- [ ] A custom recognizer example is documented and tested
- [ ] FaceChallengeController implements full oval→gates→capture→challenge flow
- [ ] Best frame capture selects the highest-quality frame reliably

---

## V4 — Multi-Platform

**Goal:** Extend FaceGestureDetector to iOS and potentially Web.

### Scope

| Area | Deliverable |
|------|------------|
| **iOS** | `FaceGestureDetectorIOS` platform implementation using Apple Vision framework or MediaPipe iOS |
| **Web** | Evaluate MediaPipe Web maturity. If viable: `FaceGestureDetectorWeb` platform implementation |
| **Federated structure** | Split into `face_gesture_detector` (Dart), `face_gesture_detector_android`, `face_gesture_detector_ios`, `face_gesture_detector_web` |

### Key Constraints

- The Federated Plugin pattern (Layer 4) was designed from V1 to enable this
- iOS and Web implementations must pass the same Dart-side test suite
- Platform-specific behavior differences must be documented

### Exit Criteria

- [ ] iOS implementation passes all recognizer tests
- [ ] Federated packages published independently
- [ ] Platform differences documented in API docs

---

## Version Dependencies

```
V1 (Core)
 │
 ├──▶ V2 (Performance)     — no API changes, internal optimization
 │
 ├──▶ V3 (Extensibility)   — new abstractions justified by V1/V2 experience
 │
 └──▶ V4 (Multi-platform)  — leverages Federated Plugin pattern from V1
```

V2, V3, and V4 can be developed in parallel after V1 ships. V3's `FrameSource` abstraction benefits from V2's native optimization but does not require it.
