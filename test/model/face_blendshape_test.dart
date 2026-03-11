import 'package:flutter_test/flutter_test.dart';
import 'package:face_gesture_detector/face_gesture_detector.dart';

void main() {
  group('FaceBlendshape', () {
    test('has exactly 52 ARKit-compatible blendshapes', () {
      expect(FaceBlendshape.values.length, 52);
    });

    test('contains key blendshapes used by recognizers', () {
      // Blink detection
      expect(FaceBlendshape.values, contains(FaceBlendshape.eyeBlinkLeft));
      expect(FaceBlendshape.values, contains(FaceBlendshape.eyeBlinkRight));

      // Smile detection
      expect(FaceBlendshape.values, contains(FaceBlendshape.mouthSmileLeft));
      expect(FaceBlendshape.values, contains(FaceBlendshape.mouthSmileRight));

      // Brow detection
      expect(FaceBlendshape.values, contains(FaceBlendshape.browInnerUp));

      // Mouth detection
      expect(FaceBlendshape.values, contains(FaceBlendshape.jawOpen));

      // Neutral baseline
      expect(FaceBlendshape.values, contains(FaceBlendshape.neutral));
    });

    test('covers all anatomical regions', () {
      final names = FaceBlendshape.values.map((b) => b.name).toList();

      // Brow region
      expect(names.where((n) => n.startsWith('brow')).length, 5);

      // Cheek region
      expect(names.where((n) => n.startsWith('cheek')).length, 3);

      // Eye region
      expect(names.where((n) => n.startsWith('eye')).length, 14);

      // Jaw region
      expect(names.where((n) => n.startsWith('jaw')).length, 4);

      // Mouth region
      expect(names.where((n) => n.startsWith('mouth')).length, 23);

      // Nose region
      expect(names.where((n) => n.startsWith('nose')).length, 2);

      // Neutral
      expect(names.where((n) => n == 'neutral').length, 1);
    });
  });
}
