import 'package:flutter/material.dart';

// 简单的 InheritedWidget 示例（没有依赖外部 package）
void main() => runApp(const MyApp());

class CounterModel extends InheritedWidget {
  final int count;
  final Widget child;
  const CounterModel({required this.count, required this.child}) : super(child: child);

  static CounterModel? of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<CounterModel>();

  @override
  bool updateShouldNotify(covariant CounterModel oldWidget) => oldWidget.count != count;
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _c = 0;
  @override
  Widget build(BuildContext context) {
    return CounterModel(
      count: _c,
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('InheritedWidget Demo')),
          body: Column(
            children: [
              const SizedBox(height: 20),
              Builder(builder: (context) {
                final model = CounterModel.of(context);
                return Text('Count: \${model?.count}', style: const TextStyle(fontSize: 24));
              }),
              ElevatedButton(onPressed: () => setState(() => _c++), child: const Text('Increment')),
            ],
          ),
        ),
      ),
    );
  }
}
