package dev.macss.face_gesture_detector

import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.util.concurrent.Executors

/**
 * Flutter plugin that processes camera frames through MediaPipe Face Landmarker
 * and emits FaceFrame maps to Dart via EventChannel.
 *
 * Data flow:
 *   processFrame() → SingleSlotFrameBuffer → background executor →
 *   FrameDecoder → FaceLandmarkerEngine → FaceFrameStreamHandler → Dart
 */
class FaceGestureDetectorPlugin : FlutterPlugin, MethodCallHandler {

    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private lateinit var applicationContext: Context

    private val streamHandler = FaceFrameStreamHandler()
    private val frameBuffer = SingleSlotFrameBuffer<RawFrame>()

    private var engine: FaceLandmarkerEngine? = null
    private var backgroundExecutor = Executors.newSingleThreadExecutor()
    private var isRunning = false

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        applicationContext = binding.applicationContext

        methodChannel = MethodChannel(binding.binaryMessenger, "face_gesture_detector")
        methodChannel.setMethodCallHandler(this)

        eventChannel = EventChannel(binding.binaryMessenger, "face_gesture_detector/frames")
        eventChannel.setStreamHandler(streamHandler)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "startDetection" -> handleStartDetection(call, result)
            "stopDetection" -> handleStopDetection(result)
            "processFrame" -> handleProcessFrame(call, result)
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        stopEngine()
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
    }

    private fun handleStartDetection(call: MethodCall, result: Result) {
        val confidence = (call.argument<Double>("faceDetectionConfidence") ?: 0.5).toFloat()
        val includeLandmarks = call.argument<Boolean>("includeLandmarks") ?: false

        engine = FaceLandmarkerEngine(applicationContext) { frameMap ->
            streamHandler.emit(frameMap)
        }
        engine?.initialize(confidence, includeLandmarks)
        isRunning = true

        result.success(null)
    }

    private fun handleStopDetection(result: Result) {
        stopEngine()
        result.success(null)
    }

    /**
     * Receives a raw camera frame from Dart, deposits it in the buffer,
     * and kicks off background decoding + inference.
     *
     * The buffer drops older frames if inference is still processing,
     * preventing backpressure buildup from 30fps camera input.
     */
    private fun handleProcessFrame(call: MethodCall, result: Result) {
        if (!isRunning) {
            result.success(null)
            return
        }

        val bytes = call.argument<ByteArray>("bytes")
        val width = call.argument<Int>("width")
        val height = call.argument<Int>("height")

        if (bytes == null || width == null || height == null) {
            result.success(null)
            return
        }

        val timestamp = call.argument<Long>("timestamp") ?: System.currentTimeMillis()

        frameBuffer.deposit(RawFrame(bytes, width, height, timestamp))
        scheduleProcessing()

        // Return immediately — processing happens on the background executor.
        result.success(null)
    }

    /** Submits a task to drain the buffer and process the latest frame. */
    private fun scheduleProcessing() {
        backgroundExecutor.submit {
            val rawFrame = frameBuffer.acquire() ?: return@submit
            val mpImage = FrameDecoder.decode(rawFrame.bytes, rawFrame.width, rawFrame.height)
            engine?.detectAsync(mpImage, rawFrame.timestampMs)
        }
    }

    private fun stopEngine() {
        isRunning = false
        engine?.close()
        engine = null
    }
}

/**
 * Raw camera frame data received from Dart's processFrame call.
 *
 * Stored in [SingleSlotFrameBuffer] until the background executor
 * picks it up for decoding and inference.
 */
private data class RawFrame(
    val bytes: ByteArray,
    val width: Int,
    val height: Int,
    val timestampMs: Long,
)
