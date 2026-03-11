import 'package:face_gesture_detector/src/platform/face_gesture_detector_platform_interface.dart';

/// MethodChannel implementation of [FaceGestureDetectorPlatform].
///
/// Communicates with the native Android plugin via MethodChannel
/// for commands and EventChannel for the face frame stream.
class MethodChannelFaceGestureDetector extends FaceGestureDetectorPlatform {}
