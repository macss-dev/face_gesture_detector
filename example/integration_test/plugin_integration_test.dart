// This is a basic Flutter integration test.
//
// Since integration tests run in a full Flutter application, they can interact
// with the host side of a plugin implementation, unlike Dart unit tests.
//
// For more information about Flutter integration tests, please see
// https://flutter.dev/to/integration-testing

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:face_gesture_detector/face_gesture_detector.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('startDetection and stopDetection complete', (
    WidgetTester tester,
  ) async {
    final platform = FaceGestureDetectorPlatform.instance;
    final options = FaceDetectionOptions.fromConfiguration(
      FaceGestureConfiguration(),
    );

    await platform.startDetection(options);
    await platform.stopDetection();
  });

  testWidgets('processFrame does not throw', (WidgetTester tester) async {
    final platform = FaceGestureDetectorPlatform.instance;
    final options = FaceDetectionOptions.fromConfiguration(
      FaceGestureConfiguration(),
    );

    await platform.startDetection(options);

    // Send a minimal synthetic frame (won't produce a real face detection,
    // but verifies the native pipeline doesn't crash on processFrame).
    final syntheticFrame = FrameData(
      bytes: Uint8List(640 * 480 * 3 ~/ 2), // NV21: width*height*1.5
      width: 640,
      height: 480,
      rotation: 0,
    );

    await platform.processFrame(syntheticFrame);

    await platform.stopDetection();
  });

  testWidgets('faceFrameStream is a valid stream', (WidgetTester tester) async {
    final platform = FaceGestureDetectorPlatform.instance;
    final stream = platform.faceFrameStream;

    expect(stream, isA<Stream<Map<String, dynamic>>>());
  });
}
