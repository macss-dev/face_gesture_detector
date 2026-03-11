import 'dart:typed_data';

import 'package:face_gesture_detector/src/configuration/face_gesture_configuration.dart';

/// Options sent to the native platform when starting face detection.
///
/// Serialized from [FaceGestureConfiguration] — only includes the fields
/// needed by the native layer (thresholds are applied in Dart recognizers).
class FaceDetectionOptions {
  final double faceDetectionConfidence;
  final int frameSkipCount;
  final bool includeLandmarks;

  const FaceDetectionOptions({
    required this.faceDetectionConfidence,
    required this.frameSkipCount,
    required this.includeLandmarks,
  });

  /// Extracts the native-relevant options from a full configuration.
  factory FaceDetectionOptions.fromConfiguration(
    FaceGestureConfiguration config,
  ) {
    return FaceDetectionOptions(
      faceDetectionConfidence: config.faceDetectionConfidence,
      frameSkipCount: config.frameSkipCount,
      includeLandmarks: config.includeLandmarks,
    );
  }

  /// Serializes to the Map format expected by the platform MethodChannel.
  Map<String, dynamic> toMap() {
    return {
      'faceDetectionConfidence': faceDetectionConfidence,
      'frameSkipCount': frameSkipCount,
      'includeLandmarks': includeLandmarks,
    };
  }
}

/// Raw camera frame data sent to the native platform for processing.
///
/// Contains the image bytes (YUV420 on Android), frame dimensions,
/// and the camera sensor rotation relative to the device orientation.
class FrameData {
  final Uint8List bytes;
  final int width;
  final int height;
  final int rotation;

  const FrameData({
    required this.bytes,
    required this.width,
    required this.height,
    required this.rotation,
  });
}
