import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:face_gesture_detector/face_gesture_detector.dart';

FaceFrame _frame({required Duration timestamp, double pitch = 0.0}) {
  return FaceFrame(
    timestamp: timestamp,
    isFaceDetected: true,
    faceConfidence: 0.9,
    faceBoundingBox: Rect.fromLTWH(50, 60, 200, 250),
    poseAngles: PoseAngles(pitch: pitch, yaw: 0, roll: 0),
    blendshapes: {},
    landmarks: null,
    quality: ImageQualityMetrics(brightness: 0.5, sharpness: 100),
  );
}

void main() {
  group('HeadNodRecognizer', () {
    late List<HeadNodDetails> events;
    late HeadNodRecognizer recognizer;

    setUp(() {
      events = [];
      recognizer = HeadNodRecognizer(
        configuration: FaceGestureConfiguration(
          headNodPitchThreshold: 20.0,
          sustainedGestureDuration: Duration(milliseconds: 400),
        ),
        onHeadNodDetected: events.add,
      );
    });

    test(
      'fires up nod when pitch exceeds +threshold for sustained duration',
      () {
        recognizer.addFaceFrame(_frame(timestamp: Duration.zero, pitch: 25));
        recognizer.addFaceFrame(
          _frame(timestamp: Duration(milliseconds: 200), pitch: 22),
        );
        expect(events, isEmpty);

        recognizer.addFaceFrame(
          _frame(timestamp: Duration(milliseconds: 400), pitch: 28),
        );
        expect(events, hasLength(1));
        expect(events.first.direction, HeadNodDirection.up);
        expect(events.first.sustainedFor, Duration(milliseconds: 400));
      },
    );

    test(
      'fires down nod when pitch exceeds -threshold for sustained duration',
      () {
        recognizer.addFaceFrame(_frame(timestamp: Duration.zero, pitch: -25));
        recognizer.addFaceFrame(
          _frame(timestamp: Duration(milliseconds: 400), pitch: -22),
        );

        expect(events, hasLength(1));
        expect(events.first.direction, HeadNodDirection.down);
      },
    );

    test('does not fire when pitch is within threshold', () {
      recognizer.addFaceFrame(_frame(timestamp: Duration.zero, pitch: 10));
      recognizer.addFaceFrame(
        _frame(timestamp: Duration(milliseconds: 400), pitch: 12),
      );

      expect(events, isEmpty);
    });

    test('resets timer when pitch drops back within threshold', () {
      recognizer.addFaceFrame(_frame(timestamp: Duration.zero, pitch: 25));
      recognizer.addFaceFrame(
        _frame(timestamp: Duration(milliseconds: 200), pitch: 25),
      );

      // Returns to center
      recognizer.addFaceFrame(
        _frame(timestamp: Duration(milliseconds: 300), pitch: 5),
      );

      // Nods again — timer restarts
      recognizer.addFaceFrame(
        _frame(timestamp: Duration(milliseconds: 400), pitch: 25),
      );
      recognizer.addFaceFrame(
        _frame(timestamp: Duration(milliseconds: 600), pitch: 25),
      );
      expect(events, isEmpty);

      recognizer.addFaceFrame(
        _frame(timestamp: Duration(milliseconds: 800), pitch: 25),
      );
      expect(events, hasLength(1));
    });

    test('reports pitch angle of triggering frame', () {
      recognizer.addFaceFrame(_frame(timestamp: Duration.zero, pitch: 30));
      recognizer.addFaceFrame(
        _frame(timestamp: Duration(milliseconds: 400), pitch: 35),
      );

      expect(events.first.pitchAngle, 35);
    });

    test('reset clears sustained tracking', () {
      recognizer.addFaceFrame(_frame(timestamp: Duration.zero, pitch: 25));
      recognizer.addFaceFrame(
        _frame(timestamp: Duration(milliseconds: 200), pitch: 25),
      );

      recognizer.reset();

      recognizer.addFaceFrame(
        _frame(timestamp: Duration(milliseconds: 300), pitch: 25),
      );
      expect(events, isEmpty);
    });
  });
}
