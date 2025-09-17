import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Q04: Dart side MethodChannel example for captureAndProcess
const MethodChannel _channel = MethodChannel('com.example.camera');

void main() => runApp(const MaterialApp(home: CameraExample()));

class CameraExample extends StatefulWidget {
  const CameraExample({Key? key}) : super(key: key);
  @override
  State<CameraExample> createState() => _CameraExampleState();
}

class _CameraExampleState extends State<CameraExample> {
  String _status = 'idle';
  String? _lastPath;

  Future<void> _capture() async {
    setState(() => _status = 'capturing...');
    try {
      final Map<dynamic, dynamic> res = await _channel.invokeMethod('captureAndProcess', {
        'width': 800,
        'height': 600,
        'quality': 80,
      });
      // Expect native returns {'path': '/tmp/xx.jpg'}
      final String path = res['path'] as String;
      setState(() {
        _status = 'done';
        _lastPath = path;
      });
    } on PlatformException catch (e) {
      setState(() => _status = 'error: \${e.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Platform Channel Camera Demo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Status: \$_status'),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: _capture, child: const Text('Capture')),
            if (_lastPath != null) Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Last path: \$_lastPath'),
            ),
            const SizedBox(height: 16),
            const Text('Native side should return a temp file path; Dart should not transfer big bytes')
          ],
        ),
      ),
    );
  }
}
