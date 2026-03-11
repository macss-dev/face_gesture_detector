package dev.macss.face_gesture_detector

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/**
 * Flutter plugin that processes camera frames through MediaPipe Face Landmarker
 * and emits FaceFrame maps to Dart via EventChannel.
 */
class FaceGestureDetectorPlugin : FlutterPlugin, MethodCallHandler {

    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private val streamHandler = FaceFrameStreamHandler()

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel = MethodChannel(binding.binaryMessenger, "face_gesture_detector")
        methodChannel.setMethodCallHandler(this)

        eventChannel = EventChannel(binding.binaryMessenger, "face_gesture_detector/frames")
        eventChannel.setStreamHandler(streamHandler)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "startDetection" -> {
                // TODO M3.6-M3.7: initialize FaceLandmarkerEngine
                result.success(null)
            }
            "stopDetection" -> {
                // TODO M3.6-M3.7: stop engine, release resources
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
    }
}
