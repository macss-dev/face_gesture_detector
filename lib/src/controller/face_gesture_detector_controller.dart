import 'package:flutter/foundation.dart';

/// Imperative controller for [RawFaceGestureDetector].
///
/// Allows pausing, resuming, and resetting the detection pipeline.
/// Uses [ChangeNotifier] so the widget can react to state changes.
class FaceGestureDetectorController extends ChangeNotifier {
  bool _isPaused = false;

  /// Whether frame dispatch to recognizers is paused.
  bool get isPaused => _isPaused;

  /// Pauses frame dispatch. Recognizers stop receiving frames.
  void pause() {
    if (!_isPaused) {
      _isPaused = true;
      notifyListeners();
    }
  }

  /// Resumes frame dispatch after a pause.
  void resume() {
    if (_isPaused) {
      _isPaused = false;
      notifyListeners();
    }
  }

  /// Resets all recognizers to their initial state.
  void reset() {
    notifyListeners();
  }
}
