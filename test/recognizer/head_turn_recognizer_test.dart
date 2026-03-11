import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:face_gesture_detector/face_gesture_detector.dart';

FaceFrame _frame({
  required Duration timestamp,
  double yaw = 0.0,
}) {
  return FaceFrame(
    timestamp: timestamp,
    isFaceDetected: true,
    faceConfidence: 0.9,
    faceBoundingBox: Rect.fromLTWH(50, 60, 200, 250),
    poseAngles: PoseAngles(pitch: 0, yaw: yaw, roll: 0),
    blendshapes: {},
    landmarks: null,
    quality: ImageQualityMetrics(brightness: 0.5, sharpness: 100),
  );
}

void main() {
  group('HeadTurnRecognizer', () {
    late List<HeadTurnDetails> events;
    late HeadTurnRecognizer recognizer;

    setUp(() {
      events = [];
      recognizer = HeadTurnRecognizer(
        configuration: FaceGestureConfiguration(
          headTurnYawThreshold: 25.0,
          sustainedGestureDuration: Duration(milliseconds: 400),
        ),
        onHeadTurnDetected: events.add,
      );
    });

    test('fires left turn when yaw exceeds +threshold for sustained duration', () {
      recognizer.addFaceFrame(_frame(timestamp: Duration.zero, yaw: 30));
      recognizer.addFaceFrame(_frame(timestamp: Duration(milliseconds: 200), yaw: 28));
      expect(events, isEmpty);

      recognizer.addFaceFrame(_frame(timestamp: Duration(milliseconds: 400), yaw: 32));
      expect(events, hasLength(1));
      expect(events.first.direction, HeadTurnDirection.left);
      expect(events.first.sustainedFor, Duration(milliseconds: 400));
    });

    test('fires right turn when yaw exceeds -threshold for sustained duration', () {
      recognizer.addFaceFrame(_frame(timestamp: Duration.zero, yaw: -30));
      recognizer.addFaceFrame(_frame(timestamp: Duration(milliseconds: 400), yaw: -28));

      expect(events, hasLength(1));
      expect(events.first.direction, HeadTurnDirection.right);
    });

    test('does not fire when yaw is within threshold', () {
      recognizer.addFaceFrame(_frame(timestamp: Duration.zero, yaw: 10));
      recognizer.addFaceFrame(_frame(timestamp: Duration(milliseconds: 400), yaw: 12));

      expect(events, isEmpty);
    });

    test('resets timer when yaw drops back within threshold', () {
      recognizer.addFaceFrame(_frame(timestamp: Duration.zero, yaw: 30));
      recognizer.addFaceFrame(_frame(timestamp: Duration(milliseconds: 200), yaw: 30));

      // Returns to center
      recognizer.addFaceFrame(_frame(timestamp: Duration(milliseconds: 300), yaw: 5));

      // Turns again — timer restarts
      recognizer.addFaceFrame(_frame(timestamp: Duration(milliseconds: 400), yaw: 30));
      recognizer.addFaceFrame(_frame(timestamp: Duration(milliseconds: 600), yaw: 30));
      expect(events, isEmpty);

      recognizer.addFaceFrame(_frame(timestamp: Duration(milliseconds: 800), yaw: 30));
      expect(events, hasLength(1));
    });

    test('reports yaw angle of triggering frame', () {
      recognizer.addFaceFrame(_frame(timestamp: Duration.zero, yaw: 35));
      recognizer.addFaceFrame(_frame(timestamp: Duration(milliseconds: 400), yaw: 40));

      expect(events.first.yawAngle, 40);
    });

    test('reset clears sustained tracking', () {
      recognizer.addFaceFrame(_frame(timestamp: Duration.zero, yaw: 30));
      recognizer.addFaceFrame(_frame(timestamp: Duration(milliseconds: 200), yaw: 30));

      recognizer.reset();

      recognizer.addFaceFrame(_frame(timestamp: Duration(milliseconds: 300), yaw: 30));
      expect(events, isEmpty);
    });
  });
}
