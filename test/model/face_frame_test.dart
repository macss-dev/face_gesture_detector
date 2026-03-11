import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:face_gesture_detector/face_gesture_detector.dart';

void main() {
  group('FaceFrame', () {
    test('stores all fields from constructor', () {
      final blendshapes = {
        FaceBlendshape.eyeBlinkLeft: 0.8,
        FaceBlendshape.mouthSmileRight: 0.3,
      };
      final landmarks = [
        FaceLandmark(x: 0.1, y: 0.2, z: 0.0),
        FaceLandmark(x: 0.5, y: 0.5, z: -0.1),
      ];
      final poseAngles = PoseAngles(pitch: 5.0, yaw: -3.0, roll: 1.0);
      final quality = ImageQualityMetrics(brightness: 0.5, sharpness: 120.0);

      final frame = FaceFrame(
        timestamp: Duration(milliseconds: 1234),
        isFaceDetected: true,
        faceConfidence: 0.95,
        faceBoundingBox: Rect.fromLTWH(100, 120, 200, 250),
        poseAngles: poseAngles,
        blendshapes: blendshapes,
        landmarks: landmarks,
        quality: quality,
      );

      expect(frame.timestamp, Duration(milliseconds: 1234));
      expect(frame.isFaceDetected, isTrue);
      expect(frame.faceConfidence, 0.95);
      expect(frame.faceBoundingBox, Rect.fromLTWH(100, 120, 200, 250));
      expect(frame.poseAngles.pitch, 5.0);
      expect(frame.blendshapes[FaceBlendshape.eyeBlinkLeft], 0.8);
      expect(frame.landmarks, hasLength(2));
      expect(frame.quality.brightness, 0.5);
    });

    test('landmarks can be null', () {
      final frame = FaceFrame(
        timestamp: Duration.zero,
        isFaceDetected: false,
        faceConfidence: 0.0,
        faceBoundingBox: Rect.zero,
        poseAngles: PoseAngles(pitch: 0, yaw: 0, roll: 0),
        blendshapes: {},
        landmarks: null,
        quality: ImageQualityMetrics(brightness: 0, sharpness: 0),
      );

      expect(frame.landmarks, isNull);
    });

    group('fromMap', () {
      test('deserializes a representative native payload', () {
        final map = <String, dynamic>{
          'timestamp': 1234,
          'isFaceDetected': true,
          'faceConfidence': 0.95,
          'faceBoundingBox': <String, dynamic>{
            'left': 100.0,
            'top': 120.0,
            'width': 200.0,
            'height': 250.0,
          },
          'poseAngles': <String, dynamic>{
            'pitch': 5.0,
            'yaw': -3.0,
            'roll': 1.0,
          },
          'blendshapes': <String, dynamic>{
            'eyeBlinkLeft': 0.8,
            'mouthSmileRight': 0.3,
          },
          'quality': <String, dynamic>{'brightness': 0.5, 'sharpness': 120.0},
        };

        final frame = FaceFrame.fromMap(map);

        expect(frame.timestamp, Duration(milliseconds: 1234));
        expect(frame.isFaceDetected, isTrue);
        expect(frame.faceConfidence, 0.95);
        expect(
          frame.faceBoundingBox,
          Rect.fromLTWH(100.0, 120.0, 200.0, 250.0),
        );
        expect(frame.poseAngles.pitch, 5.0);
        expect(frame.poseAngles.yaw, -3.0);
        expect(frame.blendshapes[FaceBlendshape.eyeBlinkLeft], 0.8);
        expect(frame.blendshapes[FaceBlendshape.mouthSmileRight], 0.3);
        expect(frame.landmarks, isNull);
        expect(frame.quality.brightness, 0.5);
        expect(frame.quality.sharpness, 120.0);
      });

      test('deserializes landmarks when present', () {
        final map = <String, dynamic>{
          'timestamp': 0,
          'isFaceDetected': true,
          'faceConfidence': 0.9,
          'faceBoundingBox': <String, dynamic>{
            'left': 0.0,
            'top': 0.0,
            'width': 100.0,
            'height': 100.0,
          },
          'poseAngles': <String, dynamic>{
            'pitch': 0.0,
            'yaw': 0.0,
            'roll': 0.0,
          },
          'blendshapes': <String, dynamic>{},
          'landmarks': <Map<String, dynamic>>[
            {'x': 0.1, 'y': 0.2, 'z': 0.0},
            {'x': 0.5, 'y': 0.5, 'z': -0.1},
          ],
          'quality': <String, dynamic>{'brightness': 0.4, 'sharpness': 80.0},
        };

        final frame = FaceFrame.fromMap(map);

        expect(frame.landmarks, isNotNull);
        expect(frame.landmarks, hasLength(2));
        expect(frame.landmarks![0].x, 0.1);
        expect(frame.landmarks![1].z, -0.1);
      });

      test('deserializes no-face-detected payload', () {
        final map = <String, dynamic>{
          'timestamp': 500,
          'isFaceDetected': false,
          'faceConfidence': 0.0,
          'faceBoundingBox': <String, dynamic>{
            'left': 0.0,
            'top': 0.0,
            'width': 0.0,
            'height': 0.0,
          },
          'poseAngles': <String, dynamic>{
            'pitch': 0.0,
            'yaw': 0.0,
            'roll': 0.0,
          },
          'blendshapes': <String, dynamic>{},
          'quality': <String, dynamic>{'brightness': 0.3, 'sharpness': 50.0},
        };

        final frame = FaceFrame.fromMap(map);

        expect(frame.isFaceDetected, isFalse);
        expect(frame.faceConfidence, 0.0);
        expect(frame.blendshapes, isEmpty);
      });
    });
  });
}
