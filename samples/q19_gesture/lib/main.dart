import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: GestureDemo()));

class _TapHoldRecognizer extends OneSequenceGestureRecognizer {
  // Very simple demo recognizer: treat a long press (>=500ms) as accepted
  Duration holdTime = const Duration(milliseconds: 500);
  bool _accepted = false;
  late int _primaryPointer;
  Timer? _timer;

  @override
  void addPointer(PointerEvent event) {
    startTrackingPointer(event.pointer);
    _primaryPointer = event.pointer;
    _timer = Timer(holdTime, () {
      if (!_accepted) {
        _accepted = true;
        resolve(GestureDisposition.accepted);
      }
    });
  }

  @override
  String get debugDescription => 'tapHold';

  @override
  void didStopTrackingLastPointer(int pointer) {}

  @override
  void handleEvent(PointerEvent event) {
    if (event is PointerUpEvent || event is PointerCancelEvent) {
      _timer?.cancel();
      if (!_accepted) resolve(GestureDisposition.rejected);
      stopTrackingPointer(event.pointer);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class GestureDemo extends StatelessWidget {
  const GestureDemo({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Custom GestureRecognizer Demo')),
      body: Center(
        child: RawGestureDetector(
          gestures: {
            _TapHoldRecognizer: GestureRecognizerFactoryWithHandlers<_TapHoldRecognizer>(
              () => _TapHoldRecognizer(),
              (_TapHoldRecognizer instance) {},
            ),
          },
          child: Container(
            width: 200,
            height: 200,
            color: Colors.lightBlue,
            alignment: Alignment.center,
            child: const Text('Hold me for 500ms'),
          ),
        ),
      ),
    );
  }
}
