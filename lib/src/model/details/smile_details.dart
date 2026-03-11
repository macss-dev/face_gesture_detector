/// Details emitted when a sustained smile is detected.
///
/// A smile is recognized when the average of mouthSmileLeft and
/// mouthSmileRight blendshapes exceeds the threshold for the
/// configured sustained duration.
class SmileDetails {
  final double intensity;
  final Duration sustainedFor;

  const SmileDetails({
    required this.intensity,
    required this.sustainedFor,
  });
}
