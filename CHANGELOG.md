# Changelog
All notable changes to this project will be documented in this file.

The format loosely follows [Keep a Changelog](https://keepachangelog.com/)
and the project adheres to [Semantic Versioning](https://semver.org/).

## 0.1.0-dev

### Added
- **Data Model**: `FaceFrame`, `FaceBlendshape` (52 values), `PoseAngles`, `FaceLandmark`, `ImageQualityMetrics`
- **Details objects**: `FaceDetectedDetails`, `QualityDetails`, `DistanceDetails`, `PoseDetails`, `BlinkDetails`, `SmileDetails`, `MouthDetails`, `BrowDetails`, `HeadTurnDetails`, `HeadNodDetails`
- **Configuration**: `FaceGestureConfiguration` with calibrated defaults
- **Platform interface**: `FaceGestureDetectorPlatform` + `MethodChannelFaceGestureDetector`
- **Recognizers**: `FacePresenceRecognizer`, `QualityGateRecognizer`, `PoseRecognizer`, `BlinkRecognizer`, `SmileRecognizer`, `MouthRecognizer`, `BrowRecognizer`, `HeadTurnRecognizer`, `HeadNodRecognizer`, `RawFrameRecognizer`
- **Widgets**: `RawFaceGestureDetector` (Layer 2), `FaceGestureDetector` (Layer 1 facade)
- **Controller**: `FaceGestureDetectorController` with pause/resume/reset
- **Example app**: MVP with all callback families and event log