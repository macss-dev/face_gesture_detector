import 'package:flutter_test/flutter_test.dart';
import 'package:face_gesture_detector/face_gesture_detector.dart';
import 'package:face_gesture_detector/face_gesture_detector_platform_interface.dart';
import 'package:face_gesture_detector/face_gesture_detector_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFaceGestureDetectorPlatform
    with MockPlatformInterfaceMixin
    implements FaceGestureDetectorPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FaceGestureDetectorPlatform initialPlatform = FaceGestureDetectorPlatform.instance;

  test('$MethodChannelFaceGestureDetector is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFaceGestureDetector>());
  });

  test('getPlatformVersion', () async {
    FaceGestureDetector faceGestureDetectorPlugin = FaceGestureDetector();
    MockFaceGestureDetectorPlatform fakePlatform = MockFaceGestureDetectorPlatform();
    FaceGestureDetectorPlatform.instance = fakePlatform;

    expect(await faceGestureDetectorPlugin.getPlatformVersion(), '42');
  });
}
