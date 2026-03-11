# 5. StatelessWidget Facade, StatefulWidget Lifecycle

Date: 2026-03-10

## Status

Accepted

## Context

Flutter's `GestureDetector` is a `StatelessWidget` that delegates to `RawGestureDetector` (a `StatefulWidget`). The facade holds no state — it only translates declarative configuration (callbacks) into a `Map<Type, GestureRecognizerFactory>`. The StatefulWidget manages the actual lifecycle: instantiating recognizers, subscribing to pointer events, and cleaning up on dispose.

FaceGestureDetector faces the same split between configuration and lifecycle, but with additional complexity: camera stream subscription, native pipeline management, and EventChannel subscription.

Options considered:
1. **Single StatefulWidget** — simpler to implement, but mixes configuration with lifecycle in one class
2. **StatelessWidget facade + StatefulWidget lifecycle** — follows the GestureDetector pattern exactly

## Decision

We adopt the two-widget pattern:

- `FaceGestureDetector` — `StatelessWidget`. Translates callbacks into `Map<Type, FaceGestureRecognizerFactory>`. Contains zero state, zero lifecycle, zero subscriptions. This is the public API.
- `RawFaceGestureDetector` — `StatefulWidget`. Manages camera stream subscription, native pipeline lifecycle, recognizer instantiation/destruction, and FaceFrame distribution. This is the lifecycle engine.

## Consequences

- The public API (`FaceGestureDetector`) is trivially understandable: callbacks in, widget out
- Advanced developers can use `RawFaceGestureDetector` directly to register custom recognizer maps
- The facade's `build` method is pure transformation — easy to test, reason about, and review
- All lifecycle complexity is concentrated in one place (`RawFaceGestureDetector._State`)
- Two classes instead of one adds a small amount of indirection — justified by separation of concerns
