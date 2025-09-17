import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Scaffold(body: Center(child: PainterVsRenderDemo()))));

class PainterVsRenderDemo extends StatelessWidget {
  const PainterVsRenderDemo({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          width: 200,
          height: 100,
          child: CustomPaint(
            painter: _MyPainter(),
          ),
        ),
        const SizedBox(height: 20),
        const Text('CustomPainter example above; use RenderObject for layout-aware painting'),
      ],
    );
  }
}

class _MyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.orange;
    canvas.drawRRect(Offset.zero & size, RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(12)), p);
    final tp = TextPainter(text: const TextSpan(text: 'Painter', style: TextStyle(color: Colors.white)), textDirection: TextDirection.ltr)..layout();
    tp.paint(canvas, const Offset(8,8));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
