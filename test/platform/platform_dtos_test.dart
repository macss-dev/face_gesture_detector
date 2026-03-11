import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:face_gesture_detector/face_gesture_detector.dart';

void main() {
  group('FaceDetectionOptions', () {
    test('serializes from default configuration', () {
      final options = FaceDetectionOptions.fromConfiguration(
        FaceGestureConfiguration(),
      );
      final map = options.toMap();

      expect(map['faceDetectionConfidence'], 0.5);
      expect(map['frameSkipCount'], 2);
      expect(map['includeLandmarks'], isFalse);
    });

    test('serializes custom configuration values', () {
      final options = FaceDetectionOptions.fromConfiguration(
        FaceGestureConfiguration(
          faceDetectionConfidence: 0.8,
          frameSkipCount: 0,
          includeLandmarks: true,
        ),
      );
      final map = options.toMap();

      expect(map['faceDetectionConfidence'], 0.8);
      expect(map['frameSkipCount'], 0);
      expect(map['includeLandmarks'], isTrue);
    });
  });

  group('FrameData', () {
    test('stores bytes, dimensions, and rotation', () {
      final bytes = Uint8List.fromList([1, 2, 3, 4]);
      final frame = FrameData(
        bytes: bytes,
        width: 640,
        height: 480,
        rotation: 90,
      );

      expect(frame.bytes, bytes);
      expect(frame.width, 640);
      expect(frame.height, 480);
      expect(frame.rotation, 90);
    });
  });
}
