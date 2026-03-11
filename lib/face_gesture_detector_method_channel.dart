import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'face_gesture_detector_platform_interface.dart';

/// An implementation of [FaceGestureDetectorPlatform] that uses method channels.
class MethodChannelFaceGestureDetector extends FaceGestureDetectorPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('face_gesture_detector');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
