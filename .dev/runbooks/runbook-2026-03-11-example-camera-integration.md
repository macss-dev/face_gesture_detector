# RUNBOOK – Example App Real Camera Integration (v0.2.0)

## Objective

Wire the full end-to-end pipeline so the example app shows a **live camera preview**, sends frames to the native MediaPipe engine, receives `FaceFrame` results, and fires gesture callbacks in real time. This closes the V1 exit criteria and graduates the package from `0.1.x-dev` to `0.2.0`.

## Scope

**In:**
- Wire `RawFaceGestureDetector` to call `startDetection`, `processFrame`, `stopDetection`, and listen to `faceFrameStream`
- Accept a camera image stream source in the widget layer (via `CameraController` from the `camera` package, per ADR-0006)
- Update example app: real `CameraController`, `CameraPreview`, permissions, lifecycle
- Integration test on physical device confirming face detection + callback firing
- Version bump to `0.2.0`, update CHANGELOG and README

**Out:**
- CameraX zero-copy optimization (V2)
- `FrameSource` abstraction (V3)
- `FaceChallengeController` (V3)
- iOS / Web (V4)
- UI polish beyond functional demo

## Context

- Module: `face_gesture_detector`
- Location: `d:\source\macss-dev\face_gesture_detector`
- Architecture: 5-layer (Facade → Lifecycle → Recognizers → Platform Interface → Kotlin/MediaPipe)
- Current state: All 5 layers implemented and unit-tested. Native processes frames correctly (verified with integration tests). **Gap:** `RawFaceGestureDetector` does not subscribe to the platform stream or send frames. Example app uses a placeholder instead of a real camera.
- Dependencies: `camera` (pub.dev) for `CameraController` + `CameraPreview`
- Physical device: Samsung (min SDK 24)
- Methodology: **Test Driven Development (TDD)**

### Architecture Gap Analysis

```
Current flow (broken):
  CameraController → ??? → RawFaceGestureDetector.dispatchFrame()

Target flow:
  CameraController.startImageStream()
    → onImage callback
      → platform.processFrame(FrameData)  ← send bytes to native
    
  platform.faceFrameStream
    → FaceFrame.fromMap(map)
      → RawFaceGestureDetector.dispatchFrame(frame)
        → all active recognizers
          → callbacks to developer
```

### Key Design Decisions (pre-existing)

- ADR-0002: Platform Channel — frames cross Dart↔Native boundary (V1 approach)
- ADR-0006: CameraController as direct dependency (no FrameSource abstraction until V3)
- ADR-0004: Recognizers in Dart — native only does ML inference

## Decisions Log

- 2026-03-11: `RawFaceGestureDetector` will manage the full pipeline lifecycle (camera stream subscription, processFrame calls, faceFrameStream listener, startDetection/stopDetection)
- 2026-03-11: `FaceGestureDetector` facade gains a `cameraController` parameter (required) — matches architecture.md §4.4 examples
- 2026-03-11: CameraImage planes → NV21 byte concatenation for processFrame (camera package on Android provides YUV420 planes)
- 2026-03-11: Example app uses front camera, 720p resolution, portrait lock

## Execution Plan (TDD Checklist)

Each step follows the Red-Green-Refactor cycle. **Commit after each step passes all tests.**

---

### Step 1: Add `camera` dependency to the plugin

- [ ] Add `camera: ^0.11.1` (or latest stable) to `pubspec.yaml` dependencies
- [ ] Export needed types if necessary from barrel file
- [ ] Verify `flutter pub get` succeeds and existing 117 tests still pass
- [ ] `git commit -m "M11.1: add camera dependency"`

---

### Step 2: Wire `RawFaceGestureDetector` to platform layer

> This is the core integration step. The widget must manage the full lifecycle.

- [ ] Write failing test: `RawFaceGestureDetector` with a mock platform — verify it calls `startDetection` on init, `stopDetection` on dispose, subscribes to `faceFrameStream`, and calls `dispatchFrame` for each emitted map
- [ ] Implement in `RawFaceGestureDetectorState`:
  - `initState`: call `platform.startDetection(options)`, subscribe to `platform.faceFrameStream`, deserialize via `FaceFrame.fromMap`, call `dispatchFrame`
  - `dispose`: cancel stream subscription, call `platform.stopDetection()`
  - Handle controller pause/resume: pause = cancel subscription + stopDetection; resume = restart
- [ ] Refactor if needed — ensure existing widget tests still pass (they may need mock platform injection)
- [ ] `git commit -m "M11.2: wire RawFaceGestureDetector to platform lifecycle"`

---

### Step 3: Add CameraController parameter and frame dispatch

> `RawFaceGestureDetector` subscribes to CameraController.startImageStream and sends frames.

- [ ] Write failing test: widget with mock CameraController — verify `processFrame()` is called when image stream emits a CameraImage
- [ ] Add `CameraController` parameter to `RawFaceGestureDetector` and `FaceGestureDetector`
- [ ] Implement CameraImage → FrameData conversion (concatenate YUV420 planes → bytes, extract width/height/sensorOrientation)
- [ ] In `initState` (after startDetection): `cameraController.startImageStream((image) => platform.processFrame(...))` 
- [ ] In `dispose`: `cameraController.stopImageStream()`
- [ ] Refactor if needed
- [ ] `git commit -m "M11.3: CameraController frame dispatch via processFrame"`

---

### Step 4: Update FaceGestureDetector facade

- [ ] Write failing test: `FaceGestureDetector` requires `cameraController` parameter, passes it through to `RawFaceGestureDetector`
- [ ] Add `cameraController` as required parameter to `FaceGestureDetector`
- [ ] Update existing widget tests to provide a mock `CameraController`
- [ ] Verify all existing tests pass (117 Dart + any new)
- [ ] `git commit -m "M11.4: add cameraController to FaceGestureDetector facade"`

---

### Step 5: Update example app with real camera

- [ ] Add `camera` dependency to `example/pubspec.yaml`
- [ ] Add camera permission to `example/android/app/src/main/AndroidManifest.xml`
- [ ] Rewrite `example/lib/main.dart`:
  - Initialize `CameraController` (front camera, 720p)
  - Show `CameraPreview` as child of `FaceGestureDetector`
  - Pass `cameraController` to `FaceGestureDetector`
  - Handle async init, loading state, error state
  - Keep event log UI
- [ ] `git commit -m "M11.5: example app with real camera integration"`

---

### Step 6: Integration test on physical device

- [ ] Update `example/integration_test/plugin_integration_test.dart`:
  - Test: initialize camera, start detection, verify faceFrameStream emits at least 1 FaceFrame within 5 seconds
  - Test: face callbacks fire when a face is in front of the camera
- [ ] Run on physical device: `flutter test integration_test/ -d <device_id>`
- [ ] Verify all tests pass
- [ ] `git commit -m "M11.6: integration test with real camera on device"`

---

### Step 7: Version bump, docs, publish

- [ ] Bump `pubspec.yaml` version to `0.2.0`
- [ ] Update `CHANGELOG.md` with v0.2.0 entry (camera integration, real-time detection)
- [ ] Update `README.md`: remove "dev" language, add real usage example with CameraController
- [ ] Update `docs/roadmap.md`: mark remaining V1 exit criteria as complete
- [ ] Run `dart pub publish --dry-run` — verify 0 warnings
- [ ] Run `flutter test` — verify all tests pass
- [ ] `git commit -m "M11.7: v0.2.0 — real camera integration, docs update"`
- [ ] `dart pub publish`

---

## Constraints

- Must NOT break existing 117 Dart unit tests or 14 Android JVM unit tests
- Must NOT change the native Android layer (M3 is complete and stable)
- Must NOT introduce `FrameSource` abstraction (that's V3 per ADR-0006)
- Camera permission must be requested at runtime (Android 6+)
- `CameraController` must be initialized externally by the developer (the widget does NOT own the camera — per the GestureDetector analogy)
- Frame rate must stay at ~10-15fps via existing frame skipping logic

## Validation

- [ ] Example app shows live camera preview on physical device
- [ ] Face detected callback fires when a face is visible
- [ ] Face lost callback fires when the face leaves the frame
- [ ] Blink/smile/head turn callbacks fire with appropriate gestures
- [ ] Event log in the example app populates in real time
- [ ] Pausing via controller stops detection, resuming restarts it
- [ ] `dart pub publish --dry-run` shows 0 warnings
- [ ] All existing tests still pass (117 Dart + 14 JVM + integration)

## Rollback / Safety

- All changes are on a feature branch; main is untouched until PR merge
- Native layer is NOT modified — rollback scope is Dart only
- If camera integration causes issues, the placeholder example still works

## Blockers / Open Questions

- **CameraImage format on Android:** Need to verify that `camera` package on Android emits YUV420 (NV21) planes that match what `FrameDecoder.kt` expects. If not, may need a thin conversion.
- **Camera permission handling:** Should the widget handle permission requests, or should the developer handle it before creating the widget? → Developer handles it (consistent with GestureDetector analogy — the widget does not own the hardware).
- **CameraController lifecycle:** The developer creates and disposes the CameraController. The widget only subscribes/unsubscribes to the image stream. This must be clearly documented.
