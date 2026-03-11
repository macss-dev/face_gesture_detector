import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:face_gesture_detector/face_gesture_detector.dart';

FaceFrame _frame({
  bool isFaceDetected = true,
  double confidence = 0.9,
  Rect? boundingBox,
}) {
  return FaceFrame(
    timestamp: Duration.zero,
    isFaceDetected: isFaceDetected,
    faceConfidence: confidence,
    faceBoundingBox: boundingBox ?? Rect.fromLTWH(50, 60, 200, 250),
    poseAngles: PoseAngles(pitch: 0, yaw: 0, roll: 0),
    blendshapes: {},
    landmarks: null,
    quality: ImageQualityMetrics(brightness: 0.5, sharpness: 100),
  );
}

void main() {
  group('FacePresenceRecognizer', () {
    late List<FaceDetectedDetails> detectedEvents;
    late List<void> lostEvents;
    late FacePresenceRecognizer recognizer;

    setUp(() {
      detectedEvents = [];
      lostEvents = [];
      recognizer = FacePresenceRecognizer(
        configuration: FaceGestureConfiguration(),
        onFaceDetected: detectedEvents.add,
        onFaceLost: () => lostEvents.add(null),
      );
    });

    test('does not fire when face is absent initially', () {
      recognizer.addFaceFrame(_frame(isFaceDetected: false));

      expect(detectedEvents, isEmpty);
      expect(lostEvents, isEmpty);
    });

    test('fires onFaceDetected on transition absent→present', () {
      recognizer.addFaceFrame(_frame(isFaceDetected: true));

      expect(detectedEvents, hasLength(1));
      expect(detectedEvents.first.confidence, 0.9);
    });

    test('does not fire onFaceDetected when confidence is below threshold', () {
      recognizer = FacePresenceRecognizer(
        configuration: FaceGestureConfiguration(faceDetectionConfidence: 0.8),
        onFaceDetected: detectedEvents.add,
        onFaceLost: () => lostEvents.add(null),
      );

      recognizer.addFaceFrame(_frame(isFaceDetected: true, confidence: 0.5));

      expect(detectedEvents, isEmpty);
    });

    test('fires onFaceLost on transition present→absent', () {
      // Become present
      recognizer.addFaceFrame(_frame(isFaceDetected: true));
      expect(detectedEvents, hasLength(1));

      // Become absent
      recognizer.addFaceFrame(_frame(isFaceDetected: false));

      expect(lostEvents, hasLength(1));
    });

    test('does not fire repeatedly while face remains present', () {
      recognizer.addFaceFrame(_frame(isFaceDetected: true));
      recognizer.addFaceFrame(_frame(isFaceDetected: true));
      recognizer.addFaceFrame(_frame(isFaceDetected: true));

      expect(detectedEvents, hasLength(1));
    });

    test('does not fire onFaceLost repeatedly while face remains absent', () {
      // Present → absent → still absent
      recognizer.addFaceFrame(_frame(isFaceDetected: true));
      recognizer.addFaceFrame(_frame(isFaceDetected: false));
      recognizer.addFaceFrame(_frame(isFaceDetected: false));

      expect(lostEvents, hasLength(1));
    });

    test('full cycle: absent→present→absent→present', () {
      recognizer.addFaceFrame(_frame(isFaceDetected: true));
      expect(detectedEvents, hasLength(1));

      recognizer.addFaceFrame(_frame(isFaceDetected: false));
      expect(lostEvents, hasLength(1));

      recognizer.addFaceFrame(_frame(isFaceDetected: true));
      expect(detectedEvents, hasLength(2));
    });

    test('reset returns to initial state', () {
      recognizer.addFaceFrame(_frame(isFaceDetected: true));
      recognizer.reset();

      // After reset, next face-detected frame should fire again
      recognizer.addFaceFrame(_frame(isFaceDetected: true));
      expect(detectedEvents, hasLength(2));
    });
  });
}
