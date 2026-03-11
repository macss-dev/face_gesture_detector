import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:face_gesture_detector/face_gesture_detector.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Face Gesture Detector Demo',
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: const FaceDetectorDemo(),
    );
  }
}

class FaceDetectorDemo extends StatefulWidget {
  const FaceDetectorDemo({super.key});

  @override
  State<FaceDetectorDemo> createState() => _FaceDetectorDemoState();
}

class _FaceDetectorDemoState extends State<FaceDetectorDemo>
    with WidgetsBindingObserver {
  final _gestureController = FaceGestureDetectorController();
  final _events = <String>[];

  CameraController? _cameraController;
  bool _hasFace = false;
  bool _isPaused = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _gestureController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final camera = _cameraController;
    if (camera == null || !camera.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      camera.dispose();
      _cameraController = null;
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      final front = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        front,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.nv21,
      );

      await controller.initialize();

      if (!mounted) {
        controller.dispose();
        return;
      }

      setState(() {
        _cameraController = controller;
        _error = null;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString());
      }
    }
  }

  void _addEvent(String event) {
    final entry = '${DateTime.now().toIso8601String().substring(11, 19)} $event';
    debugPrint('[FaceGesture] $entry');
    setState(() {
      _events.insert(0, entry);
      if (_events.length > 50) _events.removeLast();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Face Gesture Detector'),
        actions: [
          IconButton(
            icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
            onPressed: () {
              setState(() {
                _isPaused = !_isPaused;
                _isPaused
                    ? _gestureController.pause()
                    : _gestureController.resume();
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _gestureController.reset();
              setState(() => _events.clear());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(flex: 2, child: _buildCameraArea()),
          Expanded(flex: 1, child: _buildEventLog()),
        ],
      ),
    );
  }

  Widget _buildCameraArea() {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Camera error: $_error',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    final camera = _cameraController;
    if (camera == null || !camera.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return FaceGestureDetector(
      configuration: FaceGestureConfiguration(),
      cameraController: camera,
      controller: _gestureController,
      onFaceDetected: (details) {
        if (!_hasFace) {
          _hasFace = true;
          _addEvent(
            'Face detected (${(details.confidence * 100).toInt()}%)',
          );
        }
      },
      onFaceLost: () {
        _hasFace = false;
        _addEvent('Face lost');
      },
      onBlinkDetected: (details) => _addEvent(
        'Blink (${details.blinkDuration.inMilliseconds}ms)',
      ),
      onSmileDetected: (details) => _addEvent(
        'Smile (intensity: ${details.intensity.toStringAsFixed(2)})',
      ),
      onHeadTurnDetected: (details) =>
          _addEvent('Head turn ${details.direction.name}'),
      onHeadNodDetected: (details) =>
          _addEvent('Head nod ${details.direction.name}'),
      onBrowRaised: (details) => _addEvent(
        'Brow raised (${details.intensity.toStringAsFixed(2)})',
      ),
      onMouthOpened: (details) => _addEvent(
        'Mouth open (${details.openness.toStringAsFixed(2)})',
      ),
      onPoseChanged: (details) =>
          _addEvent('Pose: frontal=${details.isFrontal}'),
      onDistanceChanged: (details) =>
          _addEvent('Distance: ${details.category.name}'),
      child: CameraPreview(camera),
    );
  }

  Widget _buildEventLog() {
    return Container(
      color: Colors.grey.shade100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Text(
                  'Event Log',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const Spacer(),
                if (_hasFace)
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _events.isEmpty
                ? const Center(child: Text('Waiting for events...'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: _events.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        _events[index],
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
