import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(home: StatePersistenceDemo()));
}

class StatePersistenceDemo extends StatefulWidget {
  const StatePersistenceDemo({Key? key}) : super(key: key);

  @override
  State<StatePersistenceDemo> createState() => _StatePersistenceDemoState();
}

class _StatePersistenceDemoState extends State<StatePersistenceDemo> {
  bool useKeys = false;
  List<_Item> items = List.generate(5, (i) => _Item('Item \$i', i));

  void shuffleItems() {
    setState(() {
      items.shuffle();
    });
  }

  void toggleUseKeys(bool? v) {
    setState(() {
      useKeys = v ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('State Persistence & Keys Demo')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Checkbox(value: useKeys, onChanged: toggleUseKeys),
                const Text('Use ValueKey for items'),
                const Spacer(),
                ElevatedButton(onPressed: shuffleItems, child: const Text('Shuffle')),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: items.map((item) {
                return _ItemWidget(
                  key: useKeys ? ValueKey(item.id) : null,
                  item: item,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _Item {
  final String name;
  final int id;
  _Item(this.name, this.id);
}

class _ItemWidget extends StatefulWidget {
  final _Item item;
  const _ItemWidget({Key? key, required this.item}) : super(key: key);

  @override
  State<_ItemWidget> createState() => _ItemWidgetState();
}

class _ItemWidgetState extends State<_ItemWidget> {
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.text = 'Note for \${widget.item.name}';
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _ItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If identity changed and we want to reset controller, we could detect here
    // but default behavior is to keep controller to demonstrate key effects
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.item.name),
      subtitle: TextField(controller: controller),
    );
  }
}
