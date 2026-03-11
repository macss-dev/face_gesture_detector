package dev.macss.face_gesture_detector

import java.util.concurrent.atomic.AtomicReference

/**
 * Single-slot backpressure buffer for camera frames.
 *
 * Designed for the producer-consumer pattern between the camera stream
 * (high frequency, ~30fps) and the ML inference pipeline (lower frequency,
 * ~10-15fps). Only the latest frame is kept — older frames are silently
 * discarded, preventing backpressure buildup.
 *
 * Thread-safe: uses [AtomicReference] for lock-free deposit/acquire.
 *
 * @param T The frame type being buffered.
 */
class SingleSlotFrameBuffer<T> {

    private val slot = AtomicReference<T>(null)

    /**
     * Deposits a frame into the buffer, replacing any previously stored frame.
     *
     * Non-blocking. The previous frame (if any) is silently discarded.
     */
    fun deposit(frame: T) {
        slot.set(frame)
    }

    /**
     * Acquires the latest frame and clears the slot atomically.
     *
     * @return The latest deposited frame, or null if the slot is empty.
     */
    fun acquire(): T? {
        return slot.getAndSet(null)
    }

    /** Returns true when no frame is stored in the slot. */
    val isEmpty: Boolean
        get() = slot.get() == null
}
