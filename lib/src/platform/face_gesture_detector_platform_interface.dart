import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:face_gesture_detector/src/platform/face_detection_options.dart';
import 'package:face_gesture_detector/src/platform/method_channel_face_gesture_detector.dart';

/// The platform interface for face gesture detection.
///
/// Defines the Dart↔Native contract that platform-specific implementations
/// must fulfill. Uses [PlatformInterface] for token verification to prevent
/// accidental direct implementation (should extend, not implement).
abstract class FaceGestureDetectorPlatform extends PlatformInterface {
  FaceGestureDetectorPlatform() : super(token: _token);

  static final Object _token = Object();

  static FaceGestureDetectorPlatform _instance =
      MethodChannelFaceGestureDetector();

  /// The current platform implementation.
  ///
  /// Defaults to [MethodChannelFaceGestureDetector].
  static FaceGestureDetectorPlatform get instance => _instance;

  /// Override the default platform implementation (for testing or federation).
  static set instance(FaceGestureDetectorPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Initializes the native face detection engine with the given [options].
  ///
  /// On Android: starts MediaPipe FaceLandmarker with GPU delegate.
  Future<void> startDetection(FaceDetectionOptions options) {
    throw UnimplementedError('startDetection() has not been implemented.');
  }

  /// Stops the native face detection engine and releases resources.
  Future<void> stopDetection() {
    throw UnimplementedError('stopDetection() has not been implemented.');
  }

  /// Stream of face frame maps emitted by the native pipeline.
  ///
  /// Each map is deserialized into a [FaceFrame] on the Dart side.
  Stream<Map<String, dynamic>> get faceFrameStream {
    throw UnimplementedError('faceFrameStream has not been implemented.');
  }
}
