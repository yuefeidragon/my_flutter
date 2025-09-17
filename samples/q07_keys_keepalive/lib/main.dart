import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: KeysKeepAliveDemo()));

class KeysKeepAliveDemo extends StatefulWidget {
  const KeysKeepAliveDemo({Key? key}) : super(key: key);
  @override
  State<KeysKeepAliveDemo> createState() => _KeysKeepAliveDemoState();
}

class _KeysKeepAliveDemoState extends State<KeysKeepAliveDemo> {
  bool useKeys = true;
  List<int> items = List.generate(6, (i) => i);

  void shuffleItems() {
    setState(() => items.shuffle());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Keys & KeepAlive Demo')),
      body: Column(
        children: [
          SwitchListTile(
            title: const Text('Use ValueKey'),
            value: useKeys,
            onChanged: (v) => setState(() => useKeys = v),
          ),
          ElevatedButton(onPressed: shuffleItems, child: const Text('Shuffle')),
          Expanded(
            child: ListView(
              children: items.map((id) => _TileWidget(key: useKeys ? ValueKey(id) : null, id: id)).toList(),
            ),
          )
        ],
      ),
    );
  }
}

class _TileWidget extends StatefulWidget {
  final int id;
  const _TileWidget({Key? key, required this.id}) : super(key: key);
  @override
  State<_TileWidget> createState() => _TileWidgetState();
}

class _TileWidgetState extends State<_TileWidget> with AutomaticKeepAliveClientMixin {
  String text = '';
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    text = 'note for \${widget.id}';
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListTile(
      title: Text('Item \${widget.id}'),
      subtitle: TextField(controller: TextEditingController(text: text)),
    );
  }
}
