# 3. No Gesture Arena for Facial Gestures

Date: 2026-03-10

## Status

Accepted

## Context

Flutter's `GestureDetector` uses a `GestureArena` to disambiguate competing touch gestures. When a pointer touches the screen, multiple recognizers (tap, drag, long-press) observe the same pointer. Since a single touch can only be one gesture, the arena ensures only one recognizer wins.

The question is whether FaceGestureDetector needs an analogous arena for facial gestures.

Key observation: **facial gestures are concurrent, not competitive.**
- A user can blink AND turn their head simultaneously
- A smile does not compete with a head turn
- Raised eyebrows do not cancel a blink
- Each recognizer observes an independent dimension of the face (eye openness, mouth shape, head orientation, brow position)

In the touch system, one pointer → one gesture (disambiguation needed). In the face system, one face → many simultaneous gestures (no disambiguation needed).

## Decision

FaceGestureDetector does **not** implement a gesture arena.

All active recognizers receive every `FaceFrame` and operate independently. There is no arbitration mechanism.

Each recognizer handles its own temporal logic internally (thresholds, sustained duration, debouncing) without an external arbiter.

## Consequences

- The recognizer architecture is simpler: no arena protocol, no accept/reject lifecycle
- All recognizers can fire simultaneously for the same frame — which is the correct behavior for facial gestures
- Adding a new recognizer requires no changes to existing recognizers or coordination logic
- If a future domain requires disambiguation (e.g. distinguishing a deliberate wink from a blink), it can be handled within a single specialized recognizer rather than an arena
- This is a deliberate departure from the GestureDetector pattern, justified by the fundamentally different nature of the input domain
