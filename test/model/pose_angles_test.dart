import 'package:flutter_test/flutter_test.dart';
import 'package:face_gesture_detector/face_gesture_detector.dart';

void main() {
  group('PoseAngles', () {
    test('stores pitch, yaw, and roll', () {
      final angles = PoseAngles(pitch: 10.0, yaw: -5.0, roll: 2.0);

      expect(angles.pitch, 10.0);
      expect(angles.yaw, -5.0);
      expect(angles.roll, 2.0);
    });

    test('isFrontal returns true when yaw and pitch are within ±15°', () {
      expect(
        PoseAngles(pitch: 0.0, yaw: 0.0, roll: 0.0).isFrontal,
        isTrue,
      );
      expect(
        PoseAngles(pitch: 14.9, yaw: -14.9, roll: 45.0).isFrontal,
        isTrue,
        reason: 'roll does not affect frontality',
      );
    });

    test('isFrontal returns false when yaw exceeds ±15°', () {
      expect(
        PoseAngles(pitch: 0.0, yaw: 15.1, roll: 0.0).isFrontal,
        isFalse,
      );
      expect(
        PoseAngles(pitch: 0.0, yaw: -16.0, roll: 0.0).isFrontal,
        isFalse,
      );
    });

    test('isFrontal returns false when pitch exceeds ±15°', () {
      expect(
        PoseAngles(pitch: 15.1, yaw: 0.0, roll: 0.0).isFrontal,
        isFalse,
      );
      expect(
        PoseAngles(pitch: -20.0, yaw: 5.0, roll: 0.0).isFrontal,
        isFalse,
      );
    });

    test('isFrontal boundary: exactly ±15° is not frontal', () {
      // Strict less-than per architecture: yaw.abs() < 15.0
      expect(
        PoseAngles(pitch: 15.0, yaw: 0.0, roll: 0.0).isFrontal,
        isFalse,
      );
      expect(
        PoseAngles(pitch: 0.0, yaw: 15.0, roll: 0.0).isFrontal,
        isFalse,
      );
    });
  });

  group('ImageQualityMetrics', () {
    test('stores brightness and sharpness', () {
      final metrics = ImageQualityMetrics(brightness: 0.5, sharpness: 150.0);

      expect(metrics.brightness, 0.5);
      expect(metrics.sharpness, 150.0);
    });
  });
}
