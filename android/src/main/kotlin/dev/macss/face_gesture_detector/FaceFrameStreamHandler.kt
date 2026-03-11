package dev.macss.face_gesture_detector

import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.EventChannel

/**
 * EventChannel.StreamHandler that emits FaceFrame maps to Dart.
 *
 * Ensures all emissions happen on the main (UI) thread.
 */
class FaceFrameStreamHandler : EventChannel.StreamHandler {

    private var eventSink: EventChannel.EventSink? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    /** Emit a FaceFrame map to Dart. Thread-safe — posts to main looper. */
    fun emit(frameMap: Map<String, Any?>) {
        mainHandler.post {
            eventSink?.success(frameMap)
        }
    }
}
