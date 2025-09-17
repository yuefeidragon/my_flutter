import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Scaffold(body: SliverDemo())));

class SliverDemo extends StatelessWidget {
  const SliverDemo({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverAppBar(title: Text('Sliver Demo'), pinned: true, expandedHeight: 150),
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            return ListTile(title: Text('Item \$index'));
          }, childCount: 1000),
        ),
      ],
    );
  }
}
