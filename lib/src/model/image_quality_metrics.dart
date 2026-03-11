/// Image quality metrics computed on the native side.
///
/// Brightness is derived from the Y channel (0.0 = black, 1.0 = white;
/// optimal range: 0.3–0.7). Sharpness is based on Laplacian variance
/// (values > 100 are generally acceptable for capture).
class ImageQualityMetrics {
  final double brightness;
  final double sharpness;

  const ImageQualityMetrics({
    required this.brightness,
    required this.sharpness,
  });
}
