import 'dart:async';
import 'package:flutter/material.dart';

/// Q09: 简单的手写 Bloc（无依赖包），用于教学与测试
void main() => runApp(const MaterialApp(home: BlocDemo()));

class CounterBloc {
  int _count = 0;
  final _controller = StreamController<int>.broadcast();
  Stream<int> get stream => _controller.stream;
  void increment() {
    _count++;
    _controller.add(_count);
  }
  void dispose() => _controller.close();
}

class BlocDemo extends StatefulWidget {
  const BlocDemo({Key? key}) : super(key: key);
  @override State<BlocDemo> createState() => _BlocDemoState();
}

class _BlocDemoState extends State<BlocDemo> {
  final bloc = CounterBloc();
  @override
  void dispose() { bloc.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Simple Bloc Demo')),
      body: StreamBuilder<int>(
        stream: bloc.stream,
        initialData: 0,
        builder: (context, snapshot) {
          return Center(child: Text('Count: \${snapshot.data}', style: const TextStyle(fontSize:24)));
        },
      ),
      floatingActionButton: FloatingActionButton(onPressed: bloc.increment, child: const Icon(Icons.add)),
    );
  }
}
