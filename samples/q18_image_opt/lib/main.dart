import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: ImageOptDemo()));

class ImageOptDemo extends StatelessWidget {
  const ImageOptDemo({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    // Use ResizeImage to avoid decoding at full resolution
    final provider = ResizeImage(const NetworkImage('https://via.placeholder.com/2000'), width: 800);
    return Scaffold(
      appBar: AppBar(title: const Text('Image Decode Optimization')),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 12),
            Image(image: provider),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                // Example: precache image
                precacheImage(provider, context);
              },
              child: const Text('Precache'),
            ),
            const SizedBox(height: 8),
            const Text('Use ResizeImage / precacheImage to reduce runtime decode cost')
          ],
        ),
      ),
    );
  }
}
