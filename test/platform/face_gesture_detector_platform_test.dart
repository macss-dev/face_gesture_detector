import 'package:flutter_test/flutter_test.dart';
import 'package:face_gesture_detector/face_gesture_detector.dart';

void main() {
  group('FaceGestureDetectorPlatform', () {
    test('instance returns MethodChannelFaceGestureDetector by default', () {
      expect(
        FaceGestureDetectorPlatform.instance,
        isA<MethodChannelFaceGestureDetector>(),
      );
    });
  });
}
