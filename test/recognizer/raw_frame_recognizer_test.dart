import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:face_gesture_detector/face_gesture_detector.dart';

FaceFrame _syntheticFrame({Duration timestamp = Duration.zero}) {
  return FaceFrame(
    timestamp: timestamp,
    isFaceDetected: true,
    faceConfidence: 0.9,
    faceBoundingBox: Rect.fromLTWH(50, 60, 200, 250),
    poseAngles: PoseAngles(pitch: 0, yaw: 0, roll: 0),
    blendshapes: {},
    landmarks: null,
    quality: ImageQualityMetrics(brightness: 0.5, sharpness: 100),
  );
}

void main() {
  group('RawFrameRecognizer', () {
    test('fires onFaceFrame callback with the received frame', () {
      FaceFrame? receivedFrame;
      final recognizer = RawFrameRecognizer(
        configuration: FaceGestureConfiguration(),
        onFaceFrame: (frame) => receivedFrame = frame,
      );

      final frame = _syntheticFrame(timestamp: Duration(milliseconds: 42));
      recognizer.addFaceFrame(frame);

      expect(receivedFrame, isNotNull);
      expect(receivedFrame!.timestamp, Duration(milliseconds: 42));
    });

    test('fires callback for every frame', () {
      final receivedFrames = <FaceFrame>[];
      final recognizer = RawFrameRecognizer(
        configuration: FaceGestureConfiguration(),
        onFaceFrame: receivedFrames.add,
      );

      recognizer.addFaceFrame(
        _syntheticFrame(timestamp: Duration(milliseconds: 1)),
      );
      recognizer.addFaceFrame(
        _syntheticFrame(timestamp: Duration(milliseconds: 2)),
      );
      recognizer.addFaceFrame(
        _syntheticFrame(timestamp: Duration(milliseconds: 3)),
      );

      expect(receivedFrames, hasLength(3));
    });

    test('reset and dispose do not throw', () {
      final recognizer = RawFrameRecognizer(
        configuration: FaceGestureConfiguration(),
        onFaceFrame: (_) {},
      );

      expect(() => recognizer.reset(), returnsNormally);
      expect(() => recognizer.dispose(), returnsNormally);
    });
  });
}
