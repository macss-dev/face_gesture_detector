import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:face_gesture_detector/face_gesture_detector.dart';

/// Frame dimensions for bounding box ratio calculation.
const _frameWidth = 1080.0;
const _frameHeight = 1920.0;

FaceFrame _frame({
  double brightness = 0.5,
  double sharpness = 100.0,
  double bboxWidth = 300.0,
  double bboxHeight = 400.0,
}) {
  return FaceFrame(
    timestamp: Duration.zero,
    isFaceDetected: true,
    faceConfidence: 0.9,
    faceBoundingBox: Rect.fromLTWH(
      (_frameWidth - bboxWidth) / 2,
      (_frameHeight - bboxHeight) / 2,
      bboxWidth,
      bboxHeight,
    ),
    poseAngles: PoseAngles(pitch: 0, yaw: 0, roll: 0),
    blendshapes: {},
    landmarks: null,
    quality: ImageQualityMetrics(brightness: brightness, sharpness: sharpness),
  );
}

void main() {
  group('QualityGateRecognizer', () {
    late List<QualityDetails> qualityEvents;
    late List<DistanceDetails> distanceEvents;
    late QualityGateRecognizer recognizer;

    setUp(() {
      qualityEvents = [];
      distanceEvents = [];
      recognizer = QualityGateRecognizer(
        configuration: FaceGestureConfiguration(),
        frameWidth: _frameWidth,
        frameHeight: _frameHeight,
        onQualityChanged: qualityEvents.add,
        onDistanceChanged: distanceEvents.add,
      );
    });

    test('fires onQualityChanged on first frame', () {
      recognizer.addFaceFrame(_frame());

      expect(qualityEvents, hasLength(1));
      expect(qualityEvents.first.metrics.brightness, 0.5);
    });

    test(
      'fires onDistanceChanged when bounding box ratio is below minimum',
      () {
        // Very small face → too far. Ratio = (50*60) / (1080*1920) ≈ 0.0014
        recognizer.addFaceFrame(_frame(bboxWidth: 50, bboxHeight: 60));

        expect(distanceEvents, hasLength(1));
        expect(distanceEvents.first.category, DistanceCategory.tooFar);
      },
    );

    test('fires onDistanceChanged with tooClose for large bounding box', () {
      // Very large face → too close. Ratio = (800*1200) / (1080*1920) ≈ 0.46
      // With defaults: maxDistanceRatio = 0.60, this is still optimal.
      // Need even bigger: (900*1500) / (1080*1920) ≈ 0.65
      recognizer.addFaceFrame(_frame(bboxWidth: 900, bboxHeight: 1500));

      expect(distanceEvents, hasLength(1));
      expect(distanceEvents.first.category, DistanceCategory.tooClose);
    });

    test('fires onDistanceChanged with optimal for medium bounding box', () {
      // Medium face. Ratio = (400*500) / (1080*1920) ≈ 0.096
      // That's < 0.20 → tooFar. Let's use bigger: (500*700)/(1080*1920) = 0.169 → tooFar
      // Need:  0.20 * 1080 * 1920 = 414,720; sqrt ≈ 644. Use 650x650:
      // (650*650)/(1080*1920) = 422500/2073600 = 0.204 → optimal
      recognizer.addFaceFrame(_frame(bboxWidth: 650, bboxHeight: 650));

      expect(distanceEvents, hasLength(1));
      expect(distanceEvents.first.category, DistanceCategory.optimal);
    });

    test(
      'only fires onDistanceChanged on category change, not every frame',
      () {
        // Two frames with same distance category → only fires once
        recognizer.addFaceFrame(_frame(bboxWidth: 650, bboxHeight: 650));
        recognizer.addFaceFrame(_frame(bboxWidth: 660, bboxHeight: 660));

        expect(distanceEvents, hasLength(1));
      },
    );

    test('fires again when distance category changes', () {
      // Optimal
      recognizer.addFaceFrame(_frame(bboxWidth: 650, bboxHeight: 650));
      expect(distanceEvents, hasLength(1));
      expect(distanceEvents.last.category, DistanceCategory.optimal);

      // Too far
      recognizer.addFaceFrame(_frame(bboxWidth: 50, bboxHeight: 60));
      expect(distanceEvents, hasLength(2));
      expect(distanceEvents.last.category, DistanceCategory.tooFar);
    });

    test('reset clears tracked state', () {
      recognizer.addFaceFrame(_frame(bboxWidth: 650, bboxHeight: 650));
      expect(distanceEvents, hasLength(1));

      recognizer.reset();

      // Same category fires again after reset
      recognizer.addFaceFrame(_frame(bboxWidth: 650, bboxHeight: 650));
      expect(distanceEvents, hasLength(2));
    });
  });
}
