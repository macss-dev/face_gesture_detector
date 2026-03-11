import 'package:flutter_test/flutter_test.dart';
import 'package:face_gesture_detector/face_gesture_detector.dart';

void main() {
  group('FaceGestureDetectorPlatform', () {
    test('instance returns a default implementation', () {
      expect(
        FaceGestureDetectorPlatform.instance,
        isA<FaceGestureDetectorPlatform>(),
      );
    });

    test('contract methods throw UnimplementedError by default', () {
      final platform = FaceGestureDetectorPlatform.instance;
      final options = FaceDetectionOptions.fromConfiguration(
        FaceGestureConfiguration(),
      );

      expect(
        () => platform.startDetection(options),
        throwsUnimplementedError,
      );
      expect(
        () => platform.stopDetection(),
        throwsUnimplementedError,
      );
      expect(
        () => platform.faceFrameStream,
        throwsUnimplementedError,
      );
    });
  });
}
