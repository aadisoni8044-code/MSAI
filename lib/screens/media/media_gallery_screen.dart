import 'package:flutter/material.dart';

class MediaGalleryScreen extends StatelessWidget {
  const MediaGalleryScreen({super.key});

  final List<String> _mediaItems = const [
    'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=600&q=80',
    'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=600&q=80',
    'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?auto=format&fit=crop&w=600&q=80',
    'https://images.unsplash.com/photo-1522071820081-009f0129c71c?auto=format&fit=crop&w=600&q=80',
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=600&q=80',
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=600&q=80',
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Media, links, and docs'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'MEDIA'),
              Tab(text: 'DOCS'),
              Tab(text: 'LINKS'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            GridView.builder(
              padding: const EdgeInsets.all(4),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: _mediaItems.length,
              itemBuilder: (context, index) {
                return Image.network(
                  _mediaItems[index],
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade300),
                );
              },
            ),
            ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                ListTile(
                  leading: Icon(Icons.insert_drive_file, color: Colors.teal, size: 36),
                  title: Text('Project_Requirements.pdf'),
                  subtitle: Text('2.4 MB • 12/10/2026'),
                ),
                ListTile(
                  leading: Icon(Icons.picture_as_pdf, color: Colors.red, size: 36),
                  title: Text('Architecture_Diagram.pdf'),
                  subtitle: Text('1.1 MB • 10/10/2026'),
                ),
              ],
            ),
            ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                ListTile(
                  leading: Icon(Icons.link, color: Colors.blue, size: 36),
                  title: Text('https://flutter.dev'),
                  subtitle: Text('Flutter - Build apps for any screen'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
