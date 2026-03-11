import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:face_gesture_detector/face_gesture_detector.dart';

FaceFrame _frame({
  required Duration timestamp,
  double smileLeft = 0.0,
  double smileRight = 0.0,
}) {
  return FaceFrame(
    timestamp: timestamp,
    isFaceDetected: true,
    faceConfidence: 0.9,
    faceBoundingBox: Rect.fromLTWH(50, 60, 200, 250),
    poseAngles: PoseAngles(pitch: 0, yaw: 0, roll: 0),
    blendshapes: {
      FaceBlendshape.mouthSmileLeft: smileLeft,
      FaceBlendshape.mouthSmileRight: smileRight,
    },
    landmarks: null,
    quality: ImageQualityMetrics(brightness: 0.5, sharpness: 100),
  );
}

void main() {
  group('SmileRecognizer', () {
    late List<SmileDetails> smileEvents;
    late SmileRecognizer recognizer;

    setUp(() {
      smileEvents = [];
      recognizer = SmileRecognizer(
        configuration: FaceGestureConfiguration(
          smileThreshold: 0.5,
          sustainedGestureDuration: Duration(milliseconds: 400),
        ),
        onSmileDetected: smileEvents.add,
      );
    });

    test('fires when smile exceeds threshold for sustained duration', () {
      recognizer.addFaceFrame(
        _frame(
          timestamp: Duration(milliseconds: 0),
          smileLeft: 0.7,
          smileRight: 0.7,
        ),
      );
      // Still smiling, not enough time yet
      recognizer.addFaceFrame(
        _frame(
          timestamp: Duration(milliseconds: 200),
          smileLeft: 0.8,
          smileRight: 0.8,
        ),
      );
      expect(smileEvents, isEmpty);

      // Now sustained for 400ms
      recognizer.addFaceFrame(
        _frame(
          timestamp: Duration(milliseconds: 400),
          smileLeft: 0.75,
          smileRight: 0.75,
        ),
      );
      expect(smileEvents, hasLength(1));
      expect(smileEvents.first.sustainedFor, Duration(milliseconds: 400));
    });

    test('does not fire on single frame above threshold', () {
      recognizer.addFaceFrame(
        _frame(
          timestamp: Duration(milliseconds: 0),
          smileLeft: 0.8,
          smileRight: 0.8,
        ),
      );

      expect(smileEvents, isEmpty);
    });

    test('resets duration timer when smile drops below threshold', () {
      recognizer.addFaceFrame(
        _frame(
          timestamp: Duration(milliseconds: 0),
          smileLeft: 0.7,
          smileRight: 0.7,
        ),
      );
      recognizer.addFaceFrame(
        _frame(
          timestamp: Duration(milliseconds: 200),
          smileLeft: 0.7,
          smileRight: 0.7,
        ),
      );

      // Smile drops
      recognizer.addFaceFrame(
        _frame(
          timestamp: Duration(milliseconds: 300),
          smileLeft: 0.2,
          smileRight: 0.2,
        ),
      );

      // Smile resumes — timer should restart
      recognizer.addFaceFrame(
        _frame(
          timestamp: Duration(milliseconds: 400),
          smileLeft: 0.7,
          smileRight: 0.7,
        ),
      );
      recognizer.addFaceFrame(
        _frame(
          timestamp: Duration(milliseconds: 600),
          smileLeft: 0.7,
          smileRight: 0.7,
        ),
      );

      // Only 200ms since restart, not enough
      expect(smileEvents, isEmpty);

      // Now sustained 400ms since restart at 400ms
      recognizer.addFaceFrame(
        _frame(
          timestamp: Duration(milliseconds: 800),
          smileLeft: 0.7,
          smileRight: 0.7,
        ),
      );
      expect(smileEvents, hasLength(1));
    });

    test('reports intensity as average of both smile blendshapes', () {
      recognizer.addFaceFrame(
        _frame(
          timestamp: Duration(milliseconds: 0),
          smileLeft: 0.6,
          smileRight: 0.8,
        ),
      );
      recognizer.addFaceFrame(
        _frame(
          timestamp: Duration(milliseconds: 400),
          smileLeft: 0.6,
          smileRight: 0.8,
        ),
      );

      expect(smileEvents, hasLength(1));
      expect(smileEvents.first.intensity, 0.7);
    });

    test('reset clears sustained tracking', () {
      recognizer.addFaceFrame(
        _frame(
          timestamp: Duration(milliseconds: 0),
          smileLeft: 0.7,
          smileRight: 0.7,
        ),
      );
      recognizer.addFaceFrame(
        _frame(
          timestamp: Duration(milliseconds: 200),
          smileLeft: 0.7,
          smileRight: 0.7,
        ),
      );

      recognizer.reset();

      // After reset, timer restarts
      recognizer.addFaceFrame(
        _frame(
          timestamp: Duration(milliseconds: 300),
          smileLeft: 0.7,
          smileRight: 0.7,
        ),
      );
      expect(smileEvents, isEmpty);
    });
  });
}
