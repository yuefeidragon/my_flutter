import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: AnimationDemo()));

class AnimationDemo extends StatefulWidget {
  const AnimationDemo({Key? key}) : super(key: key);
  @override State<AnimationDemo> createState() => _AnimationDemoState();
}

class _AnimationDemoState extends State<AnimationDemo> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _anim;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds:1));
    _anim = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }
  @override void dispose() { _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Animation Demo')),
      body: Center(
        child: FadeTransition(opacity: _anim, child: ElevatedButton(onPressed: ()=>_controller.forward(from:0), child: const Text('Animate'))),
      ),
    );
  }
}
