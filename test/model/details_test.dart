import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:face_gesture_detector/face_gesture_detector.dart';

void main() {
  group('FaceDetectedDetails', () {
    test('stores bounding box, confidence, pose, and distance', () {
      final details = FaceDetectedDetails(
        boundingBox: Rect.fromLTWH(10, 20, 100, 120),
        confidence: 0.95,
        pose: PoseAngles(pitch: 5.0, yaw: -2.0, roll: 0.0),
        distance: DistanceCategory.optimal,
      );

      expect(details.boundingBox, Rect.fromLTWH(10, 20, 100, 120));
      expect(details.confidence, 0.95);
      expect(details.pose.pitch, 5.0);
      expect(details.distance, DistanceCategory.optimal);
    });
  });

  group('QualityDetails', () {
    test('stores metrics and isSufficientForCapture', () {
      final details = QualityDetails(
        metrics: ImageQualityMetrics(brightness: 0.5, sharpness: 150.0),
        isSufficientForCapture: true,
      );

      expect(details.metrics.brightness, 0.5);
      expect(details.isSufficientForCapture, isTrue);
    });
  });

  group('DistanceDetails', () {
    test('stores category and bounding box ratio', () {
      final details = DistanceDetails(
        category: DistanceCategory.tooFar,
        boundingBoxRatio: 0.15,
      );

      expect(details.category, DistanceCategory.tooFar);
      expect(details.boundingBoxRatio, 0.15);
    });
  });

  group('PoseDetails', () {
    test('stores angles and exposes isFrontal', () {
      final frontal = PoseDetails(
        angles: PoseAngles(pitch: 0.0, yaw: 0.0, roll: 0.0),
      );
      expect(frontal.isFrontal, isTrue);

      final tilted = PoseDetails(
        angles: PoseAngles(pitch: 30.0, yaw: 0.0, roll: 0.0),
      );
      expect(tilted.isFrontal, isFalse);
    });
  });

  group('BlinkDetails', () {
    test('stores eye openness and blink duration', () {
      final details = BlinkDetails(
        leftEyeOpenness: 0.1,
        rightEyeOpenness: 0.15,
        blinkDuration: Duration(milliseconds: 250),
      );

      expect(details.leftEyeOpenness, 0.1);
      expect(details.rightEyeOpenness, 0.15);
      expect(details.blinkDuration, Duration(milliseconds: 250));
    });
  });

  group('SmileDetails', () {
    test('stores intensity and sustained duration', () {
      final details = SmileDetails(
        intensity: 0.8,
        sustainedFor: Duration(milliseconds: 500),
      );

      expect(details.intensity, 0.8);
      expect(details.sustainedFor, Duration(milliseconds: 500));
    });
  });

  group('MouthDetails', () {
    test('stores openness', () {
      final details = MouthDetails(openness: 0.6);

      expect(details.openness, 0.6);
    });
  });

  group('BrowDetails', () {
    test('stores intensity', () {
      final details = BrowDetails(intensity: 0.7);

      expect(details.intensity, 0.7);
    });
  });

  group('HeadTurnDetails', () {
    test('stores yaw angle, direction, and sustained duration', () {
      final details = HeadTurnDetails(
        yawAngle: 30.0,
        direction: HeadTurnDirection.left,
        sustainedFor: Duration(milliseconds: 450),
      );

      expect(details.yawAngle, 30.0);
      expect(details.direction, HeadTurnDirection.left);
      expect(details.sustainedFor, Duration(milliseconds: 450));
    });
  });

  group('HeadNodDetails', () {
    test('stores pitch angle, direction, and sustained duration', () {
      final details = HeadNodDetails(
        pitchAngle: -25.0,
        direction: HeadNodDirection.down,
        sustainedFor: Duration(milliseconds: 400),
      );

      expect(details.pitchAngle, -25.0);
      expect(details.direction, HeadNodDirection.down);
      expect(details.sustainedFor, Duration(milliseconds: 400));
    });
  });
}
