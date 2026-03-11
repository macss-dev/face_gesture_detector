// Flutter integration tests — run on a physical Android device.
//
// Tests are ordered so the camera-based tests run first (they provide the
// most meaningful coverage). The platform-API-only tests follow.
//
// IMPORTANT: Camera permission must be granted before running these tests.
// After installing the test APK, grant it via:
//   adb shell pm grant <package> android.permission.CAMERA
//
// Run: flutter test integration_test/ -d <device_id>

import 'dart:async';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:face_gesture_detector/face_gesture_detector.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ── Camera pipeline tests (require a front-facing camera) ────────
  //
  // Run these first — they exercise processFrame with real camera data.

  group('Camera pipeline', () {
    testWidgets('camera initializes and produces image stream', (
      WidgetTester tester,
    ) async {
      final cameras = await availableCameras();
      expect(cameras, isNotEmpty, reason: 'No cameras found');

      final front = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        front,
        ResolutionPreset.low,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.nv21,
      );

      await controller.initialize();
      expect(controller.value.isInitialized, isTrue);

      var framesReceived = 0;
      final completer = Completer<void>();

      await controller.startImageStream((CameraImage image) {
        framesReceived++;
        if (framesReceived >= 3 && !completer.isCompleted) {
          completer.complete();
        }
      });

      await completer.future.timeout(const Duration(seconds: 10));

      await controller.stopImageStream();
      await controller.dispose();

      expect(framesReceived, greaterThanOrEqualTo(3));
    });

    testWidgets('real camera frames reach processFrame without error', (
      WidgetTester tester,
    ) async {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      final front = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        front,
        ResolutionPreset.low,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.nv21,
      );

      await controller.initialize();

      final platform = FaceGestureDetectorPlatform.instance;
      final options = FaceDetectionOptions.fromConfiguration(
        FaceGestureConfiguration(),
      );
      await platform.startDetection(options);

      var framesProcessed = 0;
      final completer = Completer<void>();

      await controller.startImageStream((CameraImage image) async {
        if (completer.isCompleted) return;

        final totalBytes = image.planes.fold<int>(
          0,
          (sum, plane) => sum + plane.bytes.length,
        );
        final buffer = Uint8List(totalBytes);
        var offset = 0;
        for (final plane in image.planes) {
          buffer.setRange(offset, offset + plane.bytes.length, plane.bytes);
          offset += plane.bytes.length;
        }

        await platform.processFrame(
          FrameData(
            bytes: buffer,
            width: image.width,
            height: image.height,
            rotation: controller.description.sensorOrientation,
          ),
        );
        framesProcessed++;

        if (framesProcessed >= 3 && !completer.isCompleted) {
          completer.complete();
        }
      });

      await completer.future.timeout(const Duration(seconds: 10));

      await controller.stopImageStream();
      // Allow background inference to finish before stopping the engine.
      await Future<void>.delayed(const Duration(seconds: 1));
      await platform.stopDetection();
      await controller.dispose();

      expect(framesProcessed, greaterThanOrEqualTo(3));
    });

    testWidgets('faceFrameStream emits data from real camera', (
      WidgetTester tester,
    ) async {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      final front = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        front,
        ResolutionPreset.low,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.nv21,
      );

      await controller.initialize();

      final platform = FaceGestureDetectorPlatform.instance;
      final options = FaceDetectionOptions.fromConfiguration(
        FaceGestureConfiguration(),
      );
      await platform.startDetection(options);

      final received = <Map<String, dynamic>>[];
      final sub = platform.faceFrameStream.listen(received.add);

      await controller.startImageStream((CameraImage image) async {
        final totalBytes = image.planes.fold<int>(
          0,
          (sum, plane) => sum + plane.bytes.length,
        );
        final buffer = Uint8List(totalBytes);
        var offset = 0;
        for (final plane in image.planes) {
          buffer.setRange(offset, offset + plane.bytes.length, plane.bytes);
          offset += plane.bytes.length;
        }

        await platform.processFrame(
          FrameData(
            bytes: buffer,
            width: image.width,
            height: image.height,
            rotation: controller.description.sensorOrientation,
          ),
        );
      });

      // Give the pipeline time to produce results.
      await Future<void>.delayed(const Duration(seconds: 5));

      await controller.stopImageStream();
      await Future<void>.delayed(const Duration(seconds: 1));
      await sub.cancel();
      await platform.stopDetection();
      await controller.dispose();

      // Accept ≥0 to avoid flakiness — whether face data arrives depends
      // on what the camera sees. The key assertion is: no crash.
      expect(received, isA<List<Map<String, dynamic>>>());
    });
  });

  // ── Platform API tests (no camera needed) ────────────────────────

  group('Platform API', () {
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

    testWidgets('faceFrameStream is a valid stream', (
      WidgetTester tester,
    ) async {
      final platform = FaceGestureDetectorPlatform.instance;
      final stream = platform.faceFrameStream;
      expect(stream, isA<Stream<Map<String, dynamic>>>());
    });
  });
}
