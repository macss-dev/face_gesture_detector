import 'package:face_gesture_detector/src/model/image_quality_metrics.dart';

/// Details emitted when image quality metrics change.
///
/// Used by the QualityGateRecognizer to inform the app about
/// capture readiness based on brightness and sharpness thresholds.
class QualityDetails {
  final ImageQualityMetrics metrics;
  final bool isSufficientForCapture;

  const QualityDetails({
    required this.metrics,
    required this.isSufficientForCapture,
  });
}
