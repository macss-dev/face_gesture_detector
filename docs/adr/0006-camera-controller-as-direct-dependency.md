# 6. CameraController as Direct Dependency

Date: 2026-03-10

## Status

Accepted

## Context

FaceGestureDetector needs a source of camera frames. The question is whether to accept `CameraController` directly or define a `FrameSource` abstraction.

Arguments for abstraction (`FrameSource` interface):
- Decouples the plugin from the `camera` package
- Supports alternative frame sources (video files, custom cameras) from day one

Arguments for direct dependency (`CameraController`):
- Today, the `camera` package is the only viable frame source for Flutter on Android
- An abstraction without a second concrete implementation violates R-TEC-03: "Abstractions are earned, not anticipated"
- A premature abstraction risks designing an interface that doesn't fit the second implementation when it arrives
- Accepting `CameraController` directly is the simplest and most discoverable API for developers

## Decision

V1 accepts `CameraController` from the `camera` package directly as a constructor parameter.

The `FrameSource` abstraction is deferred to V3 (Extensibility), when concrete experience with the plugin and user feedback will reveal the right interface shape.

## Consequences

- V1 has a direct dependency on the `camera` package — acceptable since it's the endorsed camera plugin for Android
- The API is immediately familiar to any Flutter developer who has used the camera package
- No speculative abstraction code is written or maintained in V1
- When V3 introduces `FrameSource`, the migration path is straightforward: `CameraController` becomes `CameraControllerFrameSource` implementing the new interface, and `FaceGestureDetector` accepts `FrameSource` instead
- Until V3, developers needing custom frame sources can use `RawFaceGestureDetector` and manage frame dispatch manually
