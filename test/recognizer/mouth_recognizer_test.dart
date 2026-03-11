import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:face_gesture_detector/face_gesture_detector.dart';

FaceFrame _frame({required Duration timestamp, double jawOpen = 0.0}) {
  return FaceFrame(
    timestamp: timestamp,
    isFaceDetected: true,
    faceConfidence: 0.9,
    faceBoundingBox: Rect.fromLTWH(50, 60, 200, 250),
    poseAngles: PoseAngles(pitch: 0, yaw: 0, roll: 0),
    blendshapes: {FaceBlendshape.jawOpen: jawOpen},
    landmarks: null,
    quality: ImageQualityMetrics(brightness: 0.5, sharpness: 100),
  );
}

void main() {
  group('MouthRecognizer', () {
    late List<MouthDetails> events;
    late MouthRecognizer recognizer;

    setUp(() {
      events = [];
      recognizer = MouthRecognizer(
        configuration: FaceGestureConfiguration(
          mouthOpenThreshold: 0.15,
          sustainedGestureDuration: Duration(milliseconds: 400),
        ),
        onMouthOpened: events.add,
      );
    });

    test('fires when jawOpen exceeds threshold for sustained duration', () {
      recognizer.addFaceFrame(_frame(timestamp: Duration.zero, jawOpen: 0.3));
      recognizer.addFaceFrame(
        _frame(timestamp: Duration(milliseconds: 200), jawOpen: 0.25),
      );
      expect(events, isEmpty);

      recognizer.addFaceFrame(
        _frame(timestamp: Duration(milliseconds: 400), jawOpen: 0.35),
      );
      expect(events, hasLength(1));
      expect(events.first.openness, 0.35);
    });

    test('does not fire when below threshold', () {
      recognizer.addFaceFrame(_frame(timestamp: Duration.zero, jawOpen: 0.05));
      recognizer.addFaceFrame(
        _frame(timestamp: Duration(milliseconds: 400), jawOpen: 0.05),
      );

      expect(events, isEmpty);
    });

    test('resets timer when value drops below threshold', () {
      recognizer.addFaceFrame(_frame(timestamp: Duration.zero, jawOpen: 0.3));
      recognizer.addFaceFrame(
        _frame(timestamp: Duration(milliseconds: 200), jawOpen: 0.3),
      );
      recognizer.addFaceFrame(
        _frame(timestamp: Duration(milliseconds: 300), jawOpen: 0.05),
      );
      recognizer.addFaceFrame(
        _frame(timestamp: Duration(milliseconds: 400), jawOpen: 0.3),
      );
      recognizer.addFaceFrame(
        _frame(timestamp: Duration(milliseconds: 600), jawOpen: 0.3),
      );
      expect(events, isEmpty);

      recognizer.addFaceFrame(
        _frame(timestamp: Duration(milliseconds: 800), jawOpen: 0.3),
      );
      expect(events, hasLength(1));
    });

    test('reset clears sustained tracking', () {
      recognizer.addFaceFrame(_frame(timestamp: Duration.zero, jawOpen: 0.3));
      recognizer.addFaceFrame(
        _frame(timestamp: Duration(milliseconds: 200), jawOpen: 0.3),
      );
      recognizer.reset();

      recognizer.addFaceFrame(
        _frame(timestamp: Duration(milliseconds: 300), jawOpen: 0.3),
      );
      expect(events, isEmpty);
    });
  });
}
