import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:face_gesture_detector/face_gesture_detector.dart';

FaceFrame _frame({double pitch = 0, double yaw = 0, double roll = 0}) {
  return FaceFrame(
    timestamp: Duration.zero,
    isFaceDetected: true,
    faceConfidence: 0.9,
    faceBoundingBox: Rect.fromLTWH(50, 60, 200, 250),
    poseAngles: PoseAngles(pitch: pitch, yaw: yaw, roll: roll),
    blendshapes: {},
    landmarks: null,
    quality: ImageQualityMetrics(brightness: 0.5, sharpness: 100),
  );
}

void main() {
  group('PoseRecognizer', () {
    late List<PoseDetails> poseEvents;
    late PoseRecognizer recognizer;

    setUp(() {
      poseEvents = [];
      recognizer = PoseRecognizer(
        configuration: FaceGestureConfiguration(),
        onPoseChanged: poseEvents.add,
      );
    });

    test('fires onPoseChanged on first frame', () {
      recognizer.addFaceFrame(_frame(pitch: 0, yaw: 0, roll: 0));

      expect(poseEvents, hasLength(1));
      expect(poseEvents.first.isFrontal, isTrue);
    });

    test('fires when angles change beyond minimum delta', () {
      recognizer.addFaceFrame(_frame(pitch: 0, yaw: 0));
      expect(poseEvents, hasLength(1));

      // Large change → fires
      recognizer.addFaceFrame(_frame(pitch: 30, yaw: 0));
      expect(poseEvents, hasLength(2));
      expect(poseEvents.last.isFrontal, isFalse);
    });

    test('does not fire when angles change below minimum delta', () {
      recognizer.addFaceFrame(_frame(pitch: 0, yaw: 0));
      expect(poseEvents, hasLength(1));

      // Tiny change → does not fire
      recognizer.addFaceFrame(_frame(pitch: 1, yaw: 1));
      expect(poseEvents, hasLength(1));
    });

    test('detects frontal to non-frontal transition', () {
      recognizer.addFaceFrame(_frame(pitch: 0, yaw: 0));
      expect(poseEvents.last.isFrontal, isTrue);

      recognizer.addFaceFrame(_frame(pitch: 0, yaw: 25));
      expect(poseEvents.last.isFrontal, isFalse);
    });

    test('reset clears tracked state', () {
      recognizer.addFaceFrame(_frame(pitch: 0, yaw: 0));
      expect(poseEvents, hasLength(1));

      recognizer.reset();

      // Same angles fire again after reset
      recognizer.addFaceFrame(_frame(pitch: 0, yaw: 0));
      expect(poseEvents, hasLength(2));
    });
  });
}
