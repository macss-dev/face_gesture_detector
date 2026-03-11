import 'package:flutter/material.dart';
import 'package:face_gesture_detector/face_gesture_detector.dart';

void main() {
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

class _FaceDetectorDemoState extends State<FaceDetectorDemo> {
  final _controller = FaceGestureDetectorController();
  final _events = <String>[];

  bool _hasFace = false;
  bool _isPaused = false;

  void _addEvent(String event) {
    setState(() {
      _events.insert(
        0,
        '${DateTime.now().toIso8601String().substring(11, 19)} $event',
      );
      if (_events.length > 50) _events.removeLast();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
                _isPaused ? _controller.pause() : _controller.resume();
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _controller.reset();
              setState(() => _events.clear());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Camera preview placeholder — replace with actual CameraPreview
          // once native layer (M3) is integrated.
          Expanded(
            flex: 2,
            child: FaceGestureDetector(
              configuration: FaceGestureConfiguration(),
              controller: _controller,
              onFaceDetected: (details) {
                _hasFace = true;
                _addEvent(
                  'Face detected (${(details.confidence * 100).toInt()}%)',
                );
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
              child: Container(
                color: _hasFace ? Colors.green.shade50 : Colors.grey.shade200,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _hasFace ? Icons.face : Icons.face_retouching_off,
                        size: 64,
                        color: _hasFace ? Colors.green : Colors.grey,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _hasFace ? 'Face Detected' : 'No Face',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Camera preview will appear here\nonce native layer is integrated',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Event log
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.grey.shade100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      'Event Log',
                      style: Theme.of(context).textTheme.titleSmall,
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
            ),
          ),
        ],
      ),
    );
  }
}
