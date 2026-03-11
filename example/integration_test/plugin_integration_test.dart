// This is a basic Flutter integration test.
//
// Since integration tests run in a full Flutter application, they can interact
// with the host side of a plugin implementation, unlike Dart unit tests.
//
// For more information about Flutter integration tests, please see
// https://flutter.dev/to/integration-testing


import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:face_gesture_detector/face_gesture_detector.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('startDetection does not throw', (WidgetTester tester) async {
    final platform = FaceGestureDetectorPlatform.instance;
    final options = FaceDetectionOptions.fromConfiguration(
      FaceGestureConfiguration(),
    );

    // Should complete without throwing.
    await platform.startDetection(options);
    await platform.stopDetection();
  });
}
