import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:face_gesture_detector/face_gesture_detector.dart';

/// A minimal mock recognizer for testing frame routing.
class _TestRecognizer extends FaceGestureRecognizer {
  final List<FaceFrame> receivedFrames = [];
  bool disposed = false;
  int resetCount = 0;

  _TestRecognizer(super.configuration);

  @override
  void addFaceFrame(FaceFrame frame) => receivedFrames.add(frame);

  @override
  void reset() => resetCount++;

  @override
  void dispose() => disposed = true;
}

class _TestRecognizerFactory
    extends FaceGestureRecognizerFactory<_TestRecognizer> {
  final FaceGestureConfiguration configuration;
  _TestRecognizer? lastCreated;

  _TestRecognizerFactory(this.configuration);

  @override
  _TestRecognizer create() {
    lastCreated = _TestRecognizer(configuration);
    return lastCreated!;
  }
}

FaceFrame _frame({Duration timestamp = Duration.zero}) {
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
  group('RawFaceGestureDetector', () {
    late FaceGestureConfiguration config;

    setUp(() {
      config = FaceGestureConfiguration();
    });

    testWidgets('mounts and disposes without error', (tester) async {
      final factory = _TestRecognizerFactory(config);

      await tester.pumpWidget(
        RawFaceGestureDetector(
          configuration: config,
          recognizers: {_TestRecognizer: factory},
          child: SizedBox.shrink(),
        ),
      );

      expect(find.byType(RawFaceGestureDetector), findsOneWidget);
      expect(factory.lastCreated, isNotNull);
      expect(factory.lastCreated!.disposed, isFalse);

      // Dispose by removing from tree
      await tester.pumpWidget(SizedBox.shrink());

      expect(factory.lastCreated!.disposed, isTrue);
    });

    testWidgets('dispatches frames to all recognizers', (tester) async {
      final factoryA = _TestRecognizerFactory(config);

      final widget = RawFaceGestureDetector(
        configuration: config,
        recognizers: {
          _TestRecognizer: factoryA,
          // Use a different key to add second recognizer
        },
        child: SizedBox.shrink(),
      );

      await tester.pumpWidget(widget);

      // Access state and dispatch a frame
      final state = tester.state<RawFaceGestureDetectorState>(
        find.byType(RawFaceGestureDetector),
      );
      final frame = _frame();
      state.dispatchFrame(frame);

      expect(factoryA.lastCreated!.receivedFrames, hasLength(1));
      expect(factoryA.lastCreated!.receivedFrames.first, same(frame));
    });

    testWidgets('applies frame skipping', (tester) async {
      final configWithSkip = FaceGestureConfiguration(frameSkipCount: 2);
      final factorySkip = _TestRecognizerFactory(configWithSkip);

      await tester.pumpWidget(
        RawFaceGestureDetector(
          configuration: configWithSkip,
          recognizers: {_TestRecognizer: factorySkip},
          child: SizedBox.shrink(),
        ),
      );

      final state = tester.state<RawFaceGestureDetectorState>(
        find.byType(RawFaceGestureDetector),
      );

      // Dispatch 6 frames; with skipCount=2, should process frames 0, 3
      // (every 3rd frame: skip 2, process 1)
      for (var i = 0; i < 6; i++) {
        state.dispatchFrame(_frame(timestamp: Duration(milliseconds: i * 33)));
      }

      expect(factorySkip.lastCreated!.receivedFrames, hasLength(2));
    });

    testWidgets('does not dispatch frames when paused via controller', (
      tester,
    ) async {
      final controller = FaceGestureDetectorController();
      final factory = _TestRecognizerFactory(config);

      await tester.pumpWidget(
        RawFaceGestureDetector(
          configuration: config,
          recognizers: {_TestRecognizer: factory},
          controller: controller,
          child: SizedBox.shrink(),
        ),
      );

      final state = tester.state<RawFaceGestureDetectorState>(
        find.byType(RawFaceGestureDetector),
      );

      controller.pause();
      state.dispatchFrame(_frame());
      expect(factory.lastCreated!.receivedFrames, isEmpty);

      controller.resume();
      state.dispatchFrame(_frame());
      expect(factory.lastCreated!.receivedFrames, hasLength(1));
    });

    testWidgets('controller reset resets all recognizers', (tester) async {
      final controller = FaceGestureDetectorController();
      final factory = _TestRecognizerFactory(config);

      await tester.pumpWidget(
        RawFaceGestureDetector(
          configuration: config,
          recognizers: {_TestRecognizer: factory},
          controller: controller,
          child: SizedBox.shrink(),
        ),
      );

      controller.reset();
      await tester.pump();

      expect(factory.lastCreated!.resetCount, 1);
    });

    testWidgets('disposes removed recognizers on rebuild', (tester) async {
      final factoryA = _TestRecognizerFactory(config);

      // Initial build with factoryA
      await tester.pumpWidget(
        RawFaceGestureDetector(
          configuration: config,
          recognizers: {_TestRecognizer: factoryA},
          child: SizedBox.shrink(),
        ),
      );

      final recognizerA = factoryA.lastCreated!;
      expect(recognizerA.disposed, isFalse);

      // Rebuild without any recognizers — A should be disposed
      await tester.pumpWidget(
        RawFaceGestureDetector(
          configuration: config,
          recognizers: {},
          child: SizedBox.shrink(),
        ),
      );

      expect(recognizerA.disposed, isTrue);
    });
  });
}
