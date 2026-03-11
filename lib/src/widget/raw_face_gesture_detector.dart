import 'package:flutter/widgets.dart';

import '../configuration/face_gesture_configuration.dart';
import '../controller/face_gesture_detector_controller.dart';
import '../model/face_frame.dart';
import 'package:face_gesture_detector/src/recognizer/face_gesture_recognizer.dart';
import 'package:face_gesture_detector/src/recognizer/face_gesture_recognizer_factory.dart';

/// Layer 2 widget that manages the recognizer lifecycle and frame dispatch.
///
/// Analogous to [RawGestureDetector] in Flutter's gesture system.
/// Accepts a [recognizers] map for advanced use cases. Most developers
/// should use [FaceGestureDetector] (Layer 1 facade) instead.
class RawFaceGestureDetector extends StatefulWidget {
  /// Map of recognizer Type to factory. Each factory creates one recognizer.
  final Map<Type, FaceGestureRecognizerFactory> recognizers;

  /// Configuration forwarded to recognizers.
  final FaceGestureConfiguration configuration;

  /// Optional controller for imperative pause/resume/reset.
  final FaceGestureDetectorController? controller;

  /// Child widget, typically a camera preview.
  final Widget? child;

  const RawFaceGestureDetector({
    super.key,
    required this.recognizers,
    required this.configuration,
    this.controller,
    this.child,
  });

  @override
  State<RawFaceGestureDetector> createState() =>
      RawFaceGestureDetectorState();
}

/// Public state so tests and advanced users can call [dispatchFrame].
class RawFaceGestureDetectorState extends State<RawFaceGestureDetector> {
  final Map<Type, FaceGestureRecognizer> _activeRecognizers = {};
  int _frameCounter = 0;

  @override
  void initState() {
    super.initState();
    _syncRecognizers(widget.recognizers);
    widget.controller?.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(covariant RawFaceGestureDetector oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onControllerChanged);
      widget.controller?.addListener(_onControllerChanged);
    }

    if (!_mapsEqual(oldWidget.recognizers, widget.recognizers)) {
      _syncRecognizers(widget.recognizers);
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onControllerChanged);
    for (final recognizer in _activeRecognizers.values) {
      recognizer.dispose();
    }
    _activeRecognizers.clear();
    super.dispose();
  }

  /// Dispatches a [FaceFrame] to all active recognizers.
  ///
  /// Called internally when native frames arrive, or externally for testing.
  void dispatchFrame(FaceFrame frame) {
    if (widget.controller?.isPaused ?? false) return;

    // Frame skipping: process 1 out of every (skipCount + 1) frames.
    final skipCount = widget.configuration.frameSkipCount;
    if (skipCount > 0) {
      if (_frameCounter % (skipCount + 1) != 0) {
        _frameCounter++;
        return;
      }
      _frameCounter++;
    }

    for (final recognizer in _activeRecognizers.values) {
      recognizer.addFaceFrame(frame);
    }
  }

  void _onControllerChanged() {
    if (widget.controller?.isPaused ?? false) return;

    // If not paused, this is a reset signal.
    for (final recognizer in _activeRecognizers.values) {
      recognizer.reset();
    }
  }

  /// Syncs the active recognizer instances with the requested map.
  ///
  /// Disposes removed recognizers, creates new ones, reuses persisting.
  void _syncRecognizers(Map<Type, FaceGestureRecognizerFactory> requested) {
    // Dispose recognizers no longer in the map.
    final removedKeys =
        _activeRecognizers.keys.where((k) => !requested.containsKey(k)).toList();
    for (final key in removedKeys) {
      _activeRecognizers.remove(key)?.dispose();
    }

    // Create recognizers that are new.
    for (final entry in requested.entries) {
      if (!_activeRecognizers.containsKey(entry.key)) {
        _activeRecognizers[entry.key] = entry.value.create();
      }
    }
  }

  bool _mapsEqual(
    Map<Type, FaceGestureRecognizerFactory> a,
    Map<Type, FaceGestureRecognizerFactory> b,
  ) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return widget.child ?? const SizedBox.shrink();
  }
}
