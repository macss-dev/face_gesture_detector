import 'package:flutter_test/flutter_test.dart';
import 'package:face_gesture_detector/face_gesture_detector.dart';

void main() {
  group('FaceGestureConfiguration', () {
    test('default constructor has calibrated values', () {
      final config = FaceGestureConfiguration();

      // Detection
      expect(config.faceDetectionConfidence, 0.5);

      // Distance
      expect(config.minDistanceRatio, 0.05);
      expect(config.maxDistanceRatio, 0.40);

      // Gesture thresholds
      expect(config.headTurnYawThreshold, 25.0);
      expect(config.headNodPitchThreshold, 20.0);
      expect(config.blinkThreshold, 0.35);
      expect(config.smileThreshold, 0.5);
      expect(config.browRaisedThreshold, 0.5);
      expect(config.mouthOpenThreshold, 0.15);

      // Temporality
      expect(config.sustainedGestureDuration, Duration(milliseconds: 400));

      // Performance
      expect(config.frameSkipCount, 2);
      expect(config.includeLandmarks, isFalse);
    });

    test('custom values override defaults', () {
      final config = FaceGestureConfiguration(
        faceDetectionConfidence: 0.8,
        blinkThreshold: 0.5,
        frameSkipCount: 0,
        includeLandmarks: true,
        sustainedGestureDuration: Duration(milliseconds: 200),
      );

      expect(config.faceDetectionConfidence, 0.8);
      expect(config.blinkThreshold, 0.5);
      expect(config.frameSkipCount, 0);
      expect(config.includeLandmarks, isTrue);
      expect(config.sustainedGestureDuration, Duration(milliseconds: 200));

      // Non-overridden values remain at defaults
      expect(config.minDistanceRatio, 0.05);
      expect(config.headTurnYawThreshold, 25.0);
    });
  });
}
