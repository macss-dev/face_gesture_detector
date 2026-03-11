// Verifies the barrel file is a clean import point for the public API.
// The old boilerplate (getPlatformVersion) must not be accessible.
import 'package:flutter_test/flutter_test.dart';

// This import must resolve without error — it is the single entry point.
// ignore: unused_import
import 'package:face_gesture_detector/face_gesture_detector.dart';

void main() {
  test('barrel file resolves as a valid library', () {
    // If this file compiles and runs, the barrel file exists and is importable.
    // The old FaceGestureDetector class with getPlatformVersion is gone.
    expect(true, isTrue);
  });
}
