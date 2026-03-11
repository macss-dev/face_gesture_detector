/// Details emitted when a sustained brow raise is detected.
///
/// Derived from the browInnerUp blendshape exceeding the
/// configured threshold for the sustained duration.
class BrowDetails {
  final double intensity;

  const BrowDetails({required this.intensity});
}
