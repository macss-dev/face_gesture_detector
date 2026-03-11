import 'package:flutter_test/flutter_test.dart';
import 'package:face_gesture_detector/face_gesture_detector.dart';

void main() {
  group('FaceLandmark', () {
    test('stores x, y, and z coordinates', () {
      final landmark = FaceLandmark(x: 0.5, y: 0.3, z: -0.1);

      expect(landmark.x, 0.5);
      expect(landmark.y, 0.3);
      expect(landmark.z, -0.1);
    });
  });

  group('DistanceCategory', () {
    test('has three values: tooFar, tooClose, optimal', () {
      expect(DistanceCategory.values.length, 3);
      expect(DistanceCategory.values, contains(DistanceCategory.tooFar));
      expect(DistanceCategory.values, contains(DistanceCategory.tooClose));
      expect(DistanceCategory.values, contains(DistanceCategory.optimal));
    });
  });

  group('BrightnessCategory', () {
    test('has three values: tooDark, tooBright, optimal', () {
      expect(BrightnessCategory.values.length, 3);
      expect(BrightnessCategory.values, contains(BrightnessCategory.tooDark));
      expect(BrightnessCategory.values, contains(BrightnessCategory.tooBright));
      expect(BrightnessCategory.values, contains(BrightnessCategory.optimal));
    });
  });
}
