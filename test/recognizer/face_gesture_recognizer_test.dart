import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:face_gesture_detector/face_gesture_detector.dart';

/// Minimal concrete implementation for testing the abstract contract.
class _TestRecognizer extends FaceGestureRecognizer {
  int addFaceFrameCount = 0;
  int resetCount = 0;
  bool isDisposed = false;

  _TestRecognizer(super.configuration);

  @override
  void addFaceFrame(FaceFrame frame) => addFaceFrameCount++;

  @override
  void reset() => resetCount++;

  @override
  void dispose() => isDisposed = true;
}

void main() {
  FaceFrame _syntheticFrame({bool isFaceDetected = true}) {
    return FaceFrame(
      timestamp: Duration.zero,
      isFaceDetected: isFaceDetected,
      faceConfidence: 0.9,
      faceBoundingBox: Rect.fromLTWH(50, 60, 200, 250),
      poseAngles: PoseAngles(pitch: 0, yaw: 0, roll: 0),
      blendshapes: {},
      landmarks: null,
      quality: ImageQualityMetrics(brightness: 0.5, sharpness: 100),
    );
  }

  group('FaceGestureRecognizer', () {
    test('abstract contract requires addFaceFrame, reset, and dispose', () {
      final config = FaceGestureConfiguration();
      final recognizer = _TestRecognizer(config);

      recognizer.addFaceFrame(_syntheticFrame());
      expect(recognizer.addFaceFrameCount, 1);

      recognizer.reset();
      expect(recognizer.resetCount, 1);

      recognizer.dispose();
      expect(recognizer.isDisposed, isTrue);
    });

    test('stores the configuration', () {
      final config = FaceGestureConfiguration(blinkThreshold: 0.6);
      final recognizer = _TestRecognizer(config);

      expect(recognizer.configuration.blinkThreshold, 0.6);
    });
  });
}
