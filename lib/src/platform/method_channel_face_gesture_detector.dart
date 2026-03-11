import 'package:flutter/services.dart';

import 'package:face_gesture_detector/src/platform/face_detection_options.dart';
import 'package:face_gesture_detector/src/platform/face_gesture_detector_platform_interface.dart';

/// MethodChannel implementation of [FaceGestureDetectorPlatform].
///
/// Communicates with the native Android plugin via MethodChannel
/// for commands and EventChannel for the face frame stream.
class MethodChannelFaceGestureDetector extends FaceGestureDetectorPlatform {
  static const _methodChannel = MethodChannel('face_gesture_detector');
  static const _eventChannel = EventChannel('face_gesture_detector/frames');

  /// Cached broadcast stream from the EventChannel, created lazily.
  Stream<Map<String, dynamic>>? _frameStream;

  @override
  Future<void> startDetection(FaceDetectionOptions options) {
    return _methodChannel.invokeMethod('startDetection', options.toMap());
  }

  @override
  Future<void> stopDetection() {
    return _methodChannel.invokeMethod('stopDetection');
  }

  @override
  Stream<Map<String, dynamic>> get faceFrameStream {
    _frameStream ??= _eventChannel
        .receiveBroadcastStream()
        .map((event) => Map<String, dynamic>.from(event as Map));
    return _frameStream!;
  }
}
