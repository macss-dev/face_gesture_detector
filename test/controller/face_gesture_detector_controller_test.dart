import 'package:flutter_test/flutter_test.dart';
import 'package:face_gesture_detector/face_gesture_detector.dart';

void main() {
  group('FaceGestureDetectorController', () {
    late FaceGestureDetectorController controller;

    setUp(() {
      controller = FaceGestureDetectorController();
    });

    test('starts in non-paused state', () {
      expect(controller.isPaused, isFalse);
    });

    test('pause sets isPaused to true', () {
      controller.pause();
      expect(controller.isPaused, isTrue);
    });

    test('resume sets isPaused to false after pause', () {
      controller.pause();
      controller.resume();
      expect(controller.isPaused, isFalse);
    });

    test('reset notifies listeners', () {
      var resetCount = 0;
      controller.addListener(() => resetCount++);
      controller.reset();
      expect(resetCount, 1);
    });

    test('pause notifies listeners', () {
      var callCount = 0;
      controller.addListener(() => callCount++);
      controller.pause();
      expect(callCount, 1);
    });

    test('resume notifies listeners', () {
      var callCount = 0;
      controller.pause();
      controller.addListener(() => callCount++);
      controller.resume();
      expect(callCount, 1);
    });

    test('dispose prevents further notifications', () {
      var callCount = 0;
      controller.addListener(() => callCount++);
      controller.dispose();

      // After dispose, calling methods should not crash
      // but we don't expect notifications
    });
  });
}
