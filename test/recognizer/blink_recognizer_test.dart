import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:face_gesture_detector/face_gesture_detector.dart';

FaceFrame _frame({
  required Duration timestamp,
  double eyeBlinkLeft = 0.0,
  double eyeBlinkRight = 0.0,
}) {
  return FaceFrame(
    timestamp: timestamp,
    isFaceDetected: true,
    faceConfidence: 0.9,
    faceBoundingBox: Rect.fromLTWH(50, 60, 200, 250),
    poseAngles: PoseAngles(pitch: 0, yaw: 0, roll: 0),
    blendshapes: {
      FaceBlendshape.eyeBlinkLeft: eyeBlinkLeft,
      FaceBlendshape.eyeBlinkRight: eyeBlinkRight,
    },
    landmarks: null,
    quality: ImageQualityMetrics(brightness: 0.5, sharpness: 100),
  );
}

void main() {
  group('BlinkRecognizer', () {
    late List<BlinkDetails> blinkEvents;
    late BlinkRecognizer recognizer;

    setUp(() {
      blinkEvents = [];
      recognizer = BlinkRecognizer(
        configuration: FaceGestureConfiguration(blinkThreshold: 0.35),
        onBlinkDetected: blinkEvents.add,
      );
    });

    test('detects complete open→closed→open blink cycle', () {
      // Eyes open (blendshape < threshold means open; > threshold means closed)
      recognizer.addFaceFrame(_frame(
        timestamp: Duration(milliseconds: 0),
        eyeBlinkLeft: 0.1,
        eyeBlinkRight: 0.1,
      ));

      // Eyes closed
      recognizer.addFaceFrame(_frame(
        timestamp: Duration(milliseconds: 100),
        eyeBlinkLeft: 0.8,
        eyeBlinkRight: 0.8,
      ));

      // Eyes open again → blink complete
      recognizer.addFaceFrame(_frame(
        timestamp: Duration(milliseconds: 250),
        eyeBlinkLeft: 0.1,
        eyeBlinkRight: 0.1,
      ));

      expect(blinkEvents, hasLength(1));
      expect(blinkEvents.first.blinkDuration, Duration(milliseconds: 150));
    });

    test('does not fire on incomplete cycle (open→closed only)', () {
      recognizer.addFaceFrame(_frame(
        timestamp: Duration(milliseconds: 0),
        eyeBlinkLeft: 0.1,
        eyeBlinkRight: 0.1,
      ));

      recognizer.addFaceFrame(_frame(
        timestamp: Duration(milliseconds: 100),
        eyeBlinkLeft: 0.8,
        eyeBlinkRight: 0.8,
      ));

      // Eyes stay closed — no blink event
      expect(blinkEvents, isEmpty);
    });

    test('does not fire when cycle is too slow (>500ms)', () {
      recognizer.addFaceFrame(_frame(
        timestamp: Duration(milliseconds: 0),
        eyeBlinkLeft: 0.1,
        eyeBlinkRight: 0.1,
      ));

      recognizer.addFaceFrame(_frame(
        timestamp: Duration(milliseconds: 100),
        eyeBlinkLeft: 0.8,
        eyeBlinkRight: 0.8,
      ));

      // Eyes reopen but too late
      recognizer.addFaceFrame(_frame(
        timestamp: Duration(milliseconds: 700),
        eyeBlinkLeft: 0.1,
        eyeBlinkRight: 0.1,
      ));

      expect(blinkEvents, isEmpty);
    });

    test('reports eye openness values in details', () {
      recognizer.addFaceFrame(_frame(
        timestamp: Duration(milliseconds: 0),
        eyeBlinkLeft: 0.1,
        eyeBlinkRight: 0.15,
      ));
      recognizer.addFaceFrame(_frame(
        timestamp: Duration(milliseconds: 100),
        eyeBlinkLeft: 0.8,
        eyeBlinkRight: 0.9,
      ));
      recognizer.addFaceFrame(_frame(
        timestamp: Duration(milliseconds: 200),
        eyeBlinkLeft: 0.05,
        eyeBlinkRight: 0.1,
      ));

      expect(blinkEvents, hasLength(1));
      expect(blinkEvents.first.leftEyeOpenness, 0.05);
      expect(blinkEvents.first.rightEyeOpenness, 0.1);
    });

    test('detects consecutive blinks', () {
      // First blink
      recognizer.addFaceFrame(_frame(
        timestamp: Duration(milliseconds: 0),
        eyeBlinkLeft: 0.1, eyeBlinkRight: 0.1,
      ));
      recognizer.addFaceFrame(_frame(
        timestamp: Duration(milliseconds: 100),
        eyeBlinkLeft: 0.8, eyeBlinkRight: 0.8,
      ));
      recognizer.addFaceFrame(_frame(
        timestamp: Duration(milliseconds: 200),
        eyeBlinkLeft: 0.1, eyeBlinkRight: 0.1,
      ));

      // Second blink
      recognizer.addFaceFrame(_frame(
        timestamp: Duration(milliseconds: 500),
        eyeBlinkLeft: 0.8, eyeBlinkRight: 0.8,
      ));
      recognizer.addFaceFrame(_frame(
        timestamp: Duration(milliseconds: 600),
        eyeBlinkLeft: 0.1, eyeBlinkRight: 0.1,
      ));

      expect(blinkEvents, hasLength(2));
    });

    test('reset clears blink tracking state', () {
      recognizer.addFaceFrame(_frame(
        timestamp: Duration(milliseconds: 0),
        eyeBlinkLeft: 0.1, eyeBlinkRight: 0.1,
      ));
      recognizer.addFaceFrame(_frame(
        timestamp: Duration(milliseconds: 100),
        eyeBlinkLeft: 0.8, eyeBlinkRight: 0.8,
      ));

      recognizer.reset();

      // After reset, the next open event doesn't complete a cycle
      recognizer.addFaceFrame(_frame(
        timestamp: Duration(milliseconds: 200),
        eyeBlinkLeft: 0.1, eyeBlinkRight: 0.1,
      ));

      expect(blinkEvents, isEmpty);
    });
  });
}
