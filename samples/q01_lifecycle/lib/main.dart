import 'package:flutter/material.dart';
import 'dart:developer' as dev;

void log(String s) {
  dev.log(s, name: 'lifecycle-demo');
  // also print for console
  print(s);
}

void main() {
  runApp(const MaterialApp(home: LifecycleDemoPage()));
}

class LifecycleDemoPage extends StatefulWidget {
  const LifecycleDemoPage({Key? key}) : super(key: key);

  @override
  State<LifecycleDemoPage> createState() => _LifecycleDemoPageState();
}

class _LifecycleDemoPageState extends State<LifecycleDemoPage> {
  int counter = 0;

  @override
  void initState() {
    super.initState();
    log('LifecycleDemoPage.initState');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    log('LifecycleDemoPage.didChangeDependencies');
  }

  @override
  void didUpdateWidget(covariant LifecycleDemoPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    log('LifecycleDemoPage.didUpdateWidget');
  }

  @override
  void dispose() {
    log('LifecycleDemoPage.dispose');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    log('LifecycleDemoPage.build');
    return Scaffold(
      appBar: AppBar(title: const Text('Lifecycle & RenderObject Demo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Counter: \$counter', style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => setState(() => counter++),
              child: const Text('Increment'),
            ),
            const SizedBox(height: 20),
            const SizedBox(
              width: 200,
              height: 120,
              child: DecoratedBoxDemo(color: Colors.blueAccent),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => setState(() {}),
              child: const Text('Trigger rebuild'),
            ),
          ],
        ),
      ),
    );
  }
}

/// A simple LeafRenderObjectWidget that creates a RenderBox to draw.
class DecoratedBoxDemo extends LeafRenderObjectWidget {
  final Color color;
  const DecoratedBoxDemo({Key? key, required this.color}) : super(key: key);

  @override
  RenderObject createRenderObject(BuildContext context) {
    log('DecoratedBoxDemo.createRenderObject');
    return _DecoratedRenderBox(color);
  }

  @override
  void updateRenderObject(BuildContext context, covariant _DecoratedRenderBox renderObject) {
    log('DecoratedBoxDemo.updateRenderObject');
    renderObject.color = color;
  }
}

class _DecoratedRenderBox extends RenderBox {
  _DecoratedRenderBox(this._color);
  Color _color;
  set color(Color c) {
    if (_color != c) {
      _color = c;
      markNeedsPaint();
    }
  }

  @override
  void performLayout() {
    // respect incoming constraints - choose a size
    size = constraints.constrain(const Size(200, 120));
    // log layout
    log('DecoratedRenderBox.performLayout size=\$size constraints=\$constraints');
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final Canvas canvas = context.canvas;
    final Paint paint = Paint()..color = _color;
    canvas.drawRRect(
      RRect.fromRectAndRadius(offset & size, const Radius.circular(12)),
      paint,
    );
    // draw text
    final textPainter = TextPainter(
      text: const TextSpan(text: 'RenderBox', style: TextStyle(color: Colors.white, fontSize: 18)),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width - 8);
    textPainter.paint(canvas, offset + const Offset(8, 8));
    log('DecoratedRenderBox.paint');
  }
}
