import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:face_gesture_detector/face_gesture_detector.dart';

FaceFrame _frame({
  required Duration timestamp,
  double browInnerUp = 0.0,
}) {
  return FaceFrame(
    timestamp: timestamp,
    isFaceDetected: true,
    faceConfidence: 0.9,
    faceBoundingBox: Rect.fromLTWH(50, 60, 200, 250),
    poseAngles: PoseAngles(pitch: 0, yaw: 0, roll: 0),
    blendshapes: {
      FaceBlendshape.browInnerUp: browInnerUp,
    },
    landmarks: null,
    quality: ImageQualityMetrics(brightness: 0.5, sharpness: 100),
  );
}

void main() {
  group('BrowRecognizer', () {
    late List<BrowDetails> events;
    late BrowRecognizer recognizer;

    setUp(() {
      events = [];
      recognizer = BrowRecognizer(
        configuration: FaceGestureConfiguration(
          browRaisedThreshold: 0.5,
          sustainedGestureDuration: Duration(milliseconds: 400),
        ),
        onBrowRaised: events.add,
      );
    });

    test('fires when browInnerUp exceeds threshold for sustained duration', () {
      recognizer.addFaceFrame(_frame(timestamp: Duration.zero, browInnerUp: 0.7));
      recognizer.addFaceFrame(_frame(timestamp: Duration(milliseconds: 200), browInnerUp: 0.65));
      expect(events, isEmpty);

      recognizer.addFaceFrame(_frame(timestamp: Duration(milliseconds: 400), browInnerUp: 0.75));
      expect(events, hasLength(1));
      expect(events.first.intensity, 0.75);
    });

    test('does not fire on single frame above threshold', () {
      recognizer.addFaceFrame(_frame(timestamp: Duration.zero, browInnerUp: 0.8));
      expect(events, isEmpty);
    });

    test('does not fire when below threshold', () {
      recognizer.addFaceFrame(_frame(timestamp: Duration.zero, browInnerUp: 0.3));
      recognizer.addFaceFrame(_frame(timestamp: Duration(milliseconds: 400), browInnerUp: 0.3));

      expect(events, isEmpty);
    });

    test('resets timer when value drops below threshold', () {
      recognizer.addFaceFrame(_frame(timestamp: Duration.zero, browInnerUp: 0.7));
      recognizer.addFaceFrame(_frame(timestamp: Duration(milliseconds: 200), browInnerUp: 0.7));

      // Drops below
      recognizer.addFaceFrame(_frame(timestamp: Duration(milliseconds: 300), browInnerUp: 0.2));

      // Resumes — timer restarts
      recognizer.addFaceFrame(_frame(timestamp: Duration(milliseconds: 400), browInnerUp: 0.7));
      recognizer.addFaceFrame(_frame(timestamp: Duration(milliseconds: 600), browInnerUp: 0.7));
      expect(events, isEmpty);

      recognizer.addFaceFrame(_frame(timestamp: Duration(milliseconds: 800), browInnerUp: 0.7));
      expect(events, hasLength(1));
    });

    test('reset clears sustained tracking', () {
      recognizer.addFaceFrame(_frame(timestamp: Duration.zero, browInnerUp: 0.7));
      recognizer.addFaceFrame(_frame(timestamp: Duration(milliseconds: 200), browInnerUp: 0.7));

      recognizer.reset();

      recognizer.addFaceFrame(_frame(timestamp: Duration(milliseconds: 300), browInnerUp: 0.7));
      expect(events, isEmpty);
    });
  });
}
