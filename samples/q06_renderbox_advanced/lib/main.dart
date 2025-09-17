import 'package:flutter/material.dart';
import 'dart:ui' as ui;

void main() => runApp(const MaterialApp(home: Scaffold(body: Center(child: AdvancedBoxDemo()))));

class AdvancedBoxDemo extends LeafRenderObjectWidget {
  const AdvancedBoxDemo({Key? key}) : super(key: key);
  @override
  RenderObject createRenderObject(BuildContext context) => _AdvancedRenderBox();
}

class _AdvancedRenderBox extends RenderBox {
  final TextPainter _tp = TextPainter(textDirection: TextDirection.ltr);
  Color _color = Colors.teal;

  @override
  void performLayout() {
    size = constraints.constrain(const Size(200, 80));
  }

  void _layoutText() {
    _tp.text = const TextSpan(text: 'AdvancedRenderBox', style: TextStyle(color: Colors.white, fontSize: 16));
    _tp.layout(maxWidth: size.width - 8);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final Canvas canvas = context.canvas;
    final Paint p = Paint()..color = _color;
    canvas.drawRRect(offset & size, RRect.fromRectAndRadius(offset & size, const Radius.circular(8)), p);
    _layoutText();
    _tp.paint(canvas, offset + const Offset(8, 8));
  }

  @override
  bool hitTestSelf(Offset position) => (position.dx >= 0 && position.dy >= 0 && position.dx <= size.width && position.dy <= size.height);
}
