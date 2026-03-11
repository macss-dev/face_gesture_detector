import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'face_gesture_detector_method_channel.dart';

abstract class FaceGestureDetectorPlatform extends PlatformInterface {
  /// Constructs a FaceGestureDetectorPlatform.
  FaceGestureDetectorPlatform() : super(token: _token);

  static final Object _token = Object();

  static FaceGestureDetectorPlatform _instance = MethodChannelFaceGestureDetector();

  /// The default instance of [FaceGestureDetectorPlatform] to use.
  ///
  /// Defaults to [MethodChannelFaceGestureDetector].
  static FaceGestureDetectorPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FaceGestureDetectorPlatform] when
  /// they register themselves.
  static set instance(FaceGestureDetectorPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
