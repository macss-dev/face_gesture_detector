# 2. Platform Channel Over Native CameraX

Date: 2026-03-10

## Status

Accepted

## Context

FaceGestureDetector needs to process camera frames through MediaPipe on the native side. Three integration paths were evaluated:

**Option A — Platform Channel:** The developer provides a `CameraController`. The widget subscribes to its image stream, sends YUV420 frames to native via MethodChannel, MediaPipe processes them, and results return via EventChannel. Frames (~1.4MB at 720p) cross the Dart↔Native boundary each time.

**Option B — Native CameraX auto-contained:** The plugin manages the camera internally via CameraX, bypassing Flutter's camera plugin entirely. Frames flow from CameraX → MediaPipe natively (zero-copy). The preview is surfaced via a Texture widget.

**Option C — Pure processor (no widget):** FaceGestureDetector is not a widget but a controller that the developer manually feeds with frames.

Key forces:
- GestureDetector does not own the touchscreen; it translates events from hardware provided externally — this is the guiding analogy
- The camera plugin already copies frames from native to Dart; sending them back is redundant
- At 10-15fps (sufficient for facial gestures), the Platform Channel overhead is ~14MB/s — manageable on modern devices
- MediaPipe LIVE_STREAM mode already drops frames when busy, providing natural backpressure

## Decision

We choose **Option A (Platform Channel)** for V1.

1. It preserves the GestureDetector analogy: the widget does not own the hardware
2. It provides the simplest API: the developer provides their CameraController and receives callbacks
3. It decouples the plugin from the camera implementation
4. The performance overhead is acceptable at the target frame rate (10-15fps)
5. A clear optimization path exists for V2: the native side hooks into the same CameraX pipeline used by the camera plugin, eliminating the Dart↔Native frame copy — without changing the public API

## Consequences

- Frames cross the Dart↔Native boundary redundantly in V1 (~1.4MB per processed frame)
- Frame skipping is essential to keep the throughput manageable (default: process 1 out of 3 frames)
- The public API is stable from V1 — the V2 optimization is invisible to consumers
- The plugin works with any camera source that produces `CameraImage`, not just the default camera plugin
- Option B remains viable as a V2 internal optimization, not a public API change
