# face_gesture_detector

A Flutter widget that translates camera frames and MediaPipe facial landmarks into high-level semantic callbacks — exactly as `GestureDetector` translates pointer events into touch gestures.

## Features

- **FaceGestureDetector** — Declarative facade with nullable callbacks per gesture family
- **RawFaceGestureDetector** — Power-user widget for custom recognizer maps
- **10 recognizers** — Presence, Quality, Pose, Blink, Smile, Mouth, Brow, HeadTurn, HeadNod, RawFrame
- **Temporal logic** — Sustained-duration thresholds, cycle detection, state-transition filtering
- **FaceGestureDetectorController** — Imperative pause / resume / reset
- **Configurable** — All thresholds and durations via `FaceGestureConfiguration`
- **Native Android** — MediaPipe Face Landmarker with GPU delegate, single-slot backpressure, Euler angle extraction

## Quick Start

```dart
import 'package:camera/camera.dart';
import 'package:face_gesture_detector/face_gesture_detector.dart';

// Minimal: presence detection only
FaceGestureDetector(
  configuration: FaceGestureConfiguration(),
  cameraController: cameraController,
  onFaceDetected: (details) => print('Face found: ${details.confidence}'),
  onFaceLost: () => print('Face lost'),
  child: CameraPreview(cameraController),
)

// Full: all gesture families
FaceGestureDetector(
  configuration: FaceGestureConfiguration(
    blinkThreshold: 0.35,
    smileThreshold: 0.5,
    headTurnYawThreshold: 25.0,
    sustainedGestureDuration: Duration(milliseconds: 400),
    frameSkipCount: 2,
  ),
  cameraController: cameraController,
  controller: detectorController,
  onFaceDetected: (d) => handleFace(d),
  onFaceLost: () => handleLost(),
  onBlinkDetected: (d) => handleBlink(d),
  onSmileDetected: (d) => handleSmile(d),
  onHeadTurnDetected: (d) => handleTurn(d),
  onHeadNodDetected: (d) => handleNod(d),
  onBrowRaised: (d) => handleBrow(d),
  onMouthOpened: (d) => handleMouth(d),
  onPoseChanged: (d) => handlePose(d),
  onDistanceChanged: (d) => handleDistance(d),
  onQualityChanged: (d) => handleQuality(d),
  onFaceFrame: (frame) => handleRawFrame(frame),
  child: CameraPreview(cameraController),
)
```

## Architecture

Five-layer stack following Flutter's gesture system analogy:

| Layer | Class | Role |
|-------|-------|------|
| 1 | `FaceGestureDetector` | Facade — callbacks → recognizer map |
| 2 | `RawFaceGestureDetector` | Lifecycle — stream, recognizer management |
| 3 | Recognizers (`BlinkRecognizer`, etc.) | Temporal gesture logic |
| 4 | `FaceGestureDetectorPlatform` | Platform interface |
| 5 | Native (Kotlin + MediaPipe) | Camera + ML processing |

See [doc/architecture.md](doc/architecture.md) for full details.

## Status

> **v0.2.3** — Full end-to-end face gesture detection on Android with release build support.

- [x] Data model with 52 blendshapes, landmarks, pose angles
- [x] Platform interface (MethodChannel + EventChannel + processFrame)
- [x] 10 recognizers with full test coverage
- [x] Layer 2 widget with frame routing, recognizer diff, controller
- [x] Layer 1 facade with callback-to-recognizer mapping
- [x] Native Android — MediaPipe Face Landmarker (LIVE_STREAM + GPU delegate)
- [x] Camera integration — `cameraController` parameter wires the full pipeline
- [x] Example app — live camera preview with real-time gesture detection
- [x] Release build — ProGuard rules, sensor orientation compensation
- [ ] Native iOS
