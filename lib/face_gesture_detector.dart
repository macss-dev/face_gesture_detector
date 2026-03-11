/// Face Gesture Detector — a Flutter widget that translates camera frames
/// and MediaPipe facial landmarks into high-level semantic callbacks.
///
/// Import this barrel file to access all public types:
/// ```dart
/// import 'package:face_gesture_detector/face_gesture_detector.dart';
/// ```
library face_gesture_detector;

export 'src/configuration/face_gesture_configuration.dart';

export 'src/model/face_blendshape.dart';
export 'src/model/face_frame.dart';
export 'src/model/face_landmark.dart';
export 'src/model/image_quality_metrics.dart';
export 'src/model/pose_angles.dart';

// Details objects — one per callback family
export 'src/model/details/blink_details.dart';
export 'src/model/details/brow_details.dart';
export 'src/model/details/distance_details.dart';
export 'src/model/details/face_detected_details.dart';
export 'src/model/details/head_nod_details.dart';
export 'src/model/details/head_turn_details.dart';
export 'src/model/details/mouth_details.dart';
export 'src/model/details/pose_details.dart';
export 'src/model/details/quality_details.dart';
export 'src/model/details/smile_details.dart';

// Platform
export 'src/platform/face_detection_options.dart';
export 'src/platform/face_gesture_detector_platform_interface.dart';
export 'src/platform/method_channel_face_gesture_detector.dart';

// Recognizer
export 'src/recognizer/face_gesture_recognizer.dart';
