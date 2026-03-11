// Verifies the barrel file exports the complete public API surface.
import 'package:flutter_test/flutter_test.dart';
import 'package:face_gesture_detector/face_gesture_detector.dart';

void main() {
  test('barrel file exports all model types', () {
    // If any of these types were missing from the barrel file,
    // this test would fail to compile.
    expect(FaceBlendshape.values, isNotEmpty);
    expect(FaceFrame, isNotNull);
    expect(FaceLandmark, isNotNull);
    expect(PoseAngles, isNotNull);
    expect(ImageQualityMetrics, isNotNull);
    expect(DistanceCategory.values, isNotEmpty);
    expect(BrightnessCategory.values, isNotEmpty);
  });

  test('barrel file exports all details types', () {
    expect(FaceDetectedDetails, isNotNull);
    expect(QualityDetails, isNotNull);
    expect(DistanceDetails, isNotNull);
    expect(PoseDetails, isNotNull);
    expect(BlinkDetails, isNotNull);
    expect(SmileDetails, isNotNull);
    expect(MouthDetails, isNotNull);
    expect(BrowDetails, isNotNull);
    expect(HeadTurnDetails, isNotNull);
    expect(HeadNodDetails, isNotNull);
    expect(HeadTurnDirection.values, isNotEmpty);
    expect(HeadNodDirection.values, isNotEmpty);
  });

  test('barrel file exports configuration', () {
    expect(FaceGestureConfiguration, isNotNull);
  });
}
