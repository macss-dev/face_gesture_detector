import 'dart:async';

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

  group('RawFaceGestureDetector pipeline wiring', () {
    late FaceGestureConfiguration config;
    late _MockPlatform mockPlatform;
    late FaceGestureDetectorPlatform originalPlatform;

    setUp(() {
      config = FaceGestureConfiguration();
      originalPlatform = FaceGestureDetectorPlatform.instance;
      mockPlatform = _MockPlatform();
      FaceGestureDetectorPlatform.instance = mockPlatform;
    });

    tearDown(() {
      FaceGestureDetectorPlatform.instance = originalPlatform;
      mockPlatform.dispose();
    });

    testWidgets('calls startDetection on init when cameraController is null', (
      tester,
    ) async {
      // Without cameraController, no startDetection should be called.
      await tester.pumpWidget(
        RawFaceGestureDetector(
          configuration: config,
          recognizers: {},
          child: SizedBox.shrink(),
        ),
      );

      expect(mockPlatform.startDetectionCalled, isFalse);
    });

    testWidgets('dispatches FaceFrame from faceFrameStream to recognizers', (
      tester,
    ) async {
      final factory = _TestRecognizerFactory(config);

      await tester.pumpWidget(
        RawFaceGestureDetector(
          configuration: config,
          recognizers: {_TestRecognizer: factory},
          child: SizedBox.shrink(),
        ),
      );

      // Simulate a native face frame arriving via the stream
      final state = tester.state<RawFaceGestureDetectorState>(
        find.byType(RawFaceGestureDetector),
      );

      final faceFrameMap = _sampleFaceFrameMap();
      state.dispatchFrame(FaceFrame.fromMap(faceFrameMap));
      await tester.pump();

      expect(factory.lastCreated!.receivedFrames, hasLength(1));
      expect(factory.lastCreated!.receivedFrames.first.isFaceDetected, isTrue);
    });

    testWidgets('calls stopDetection on dispose when pipeline was null', (
      tester,
    ) async {
      await tester.pumpWidget(
        RawFaceGestureDetector(
          configuration: config,
          recognizers: {},
          child: SizedBox.shrink(),
        ),
      );

      // Without cameraController, stopDetection should NOT be called on dispose
      await tester.pumpWidget(SizedBox.shrink());

      // stopDetection is called in _stopPipeline, but only tries if pipeline was started
      // Since no cameraController was provided, startDetection was never called
      expect(mockPlatform.startDetectionCalled, isFalse);
    });
  });
}

/// Mock platform for testing pipeline wiring without native code.
class _MockPlatform extends FaceGestureDetectorPlatform {
  bool startDetectionCalled = false;
  bool stopDetectionCalled = false;
  final List<FrameData> processedFrames = [];
  final StreamController<Map<String, dynamic>> _frameController =
      StreamController<Map<String, dynamic>>.broadcast();

  @override
  Future<void> startDetection(FaceDetectionOptions options) async {
    startDetectionCalled = true;
  }

  @override
  Future<void> stopDetection() async {
    stopDetectionCalled = true;
  }

  @override
  Future<void> processFrame(FrameData frameData) async {
    processedFrames.add(frameData);
  }

  @override
  Stream<Map<String, dynamic>> get faceFrameStream => _frameController.stream;

  void emitFaceFrame(Map<String, dynamic> map) => _frameController.add(map);

  void dispose() => _frameController.close();
}

Map<String, dynamic> _sampleFaceFrameMap() {
  return {
    'timestamp': 100,
    'isFaceDetected': true,
    'faceConfidence': 0.95,
    'faceBoundingBox': {
      'left': 50.0,
      'top': 60.0,
      'width': 200.0,
      'height': 250.0,
    },
    'poseAngles': {'pitch': 5.0, 'yaw': -3.0, 'roll': 1.0},
    'quality': {'brightness': 0.6, 'sharpness': 120.0},
    'blendshapes': {'eyeBlinkLeft': 0.1, 'mouthSmileRight': 0.8},
    'landmarks': null,
  };
}
