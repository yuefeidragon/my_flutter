import 'dart:async';
import 'dart:math';
import 'dart:isolate';
import 'package:flutter/material.dart';

/// Q03: Performance demo code snippet (non-exhaustive)
/// This demo shows a toggle that either does heavy CPU work on main isolate
/// (causing jank) or offloads to a spawned isolate (smooth).
void main() => runApp(const MaterialApp(home: PerfDemo()));

class PerfDemo extends StatefulWidget {
  const PerfDemo({Key? key}) : super(key: key);
  @override
  State<PerfDemo> createState() => _PerfDemoState();
}

class _PerfDemoState extends State<PerfDemo> {
  bool useIsolate = false;
  int result = 0;

  void _doWorkOnMain() {
    // simulate heavy compute on UI thread (blocks)
    final int r = _heavyComputation(40);
    setState(() => result = r);
  }

  static int _heavyComputation(int n) {
    int sum = 0;
    for (int i = 0; i < pow(10, n).toInt(); i++) {
      sum += i % 7;
      if (i % 1000000 == 0) {
        // keep loop going
      }
    }
    return sum;
  }

  Future<void> _doWorkInIsolate() async {
    final p = ReceivePort();
    await Isolate.spawn(_isolateEntry, p.sendPort);
    final send = await p.first as SendPort;
    final rp = ReceivePort();
    send.send([40, rp.sendPort]);
    final res = await rp.first as int;
    setState(() => result = res);
    rp.close();
    p.close();
  }

  static void _isolateEntry(SendPort initialReply) {
    final rp = ReceivePort();
    initialReply.send(rp.sendPort);
    rp.listen((message) {
      final int n = message[0] as int;
      final SendPort reply = message[1] as SendPort;
      // perform computation (careful: this is illustrative and may still be huge)
      int s = 0;
      for (int i = 0; i < 10000000; i++) {
        s += i % (n + 1);
      }
      reply.send(s);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perf Demo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Result: \$result'),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Use Isolate'),
              value: useIsolate,
              onChanged: (v) => setState(() => useIsolate = v),
            ),
            ElevatedButton(
              onPressed: () {
                if (useIsolate) {
                  _doWorkInIsolate();
                } else {
                  _doWorkOnMain();
                }
              },
              child: const Text('Run heavy compute'),
            ),
            const SizedBox(height: 8),
            const Text('Use DevTools Performance -> Record to observe jank'),
          ],
        ),
      ),
    );
  }
}
