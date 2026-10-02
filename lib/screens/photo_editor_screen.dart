import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/camera_provider.dart';
import '../providers/story_provider.dart';
import '../widgets/media_preview.dart';
import '../core/theme/app_theme.dart';

class PhotoEditorScreen extends StatefulWidget {
  final String mediaPath;
  final bool isVideo;

  const PhotoEditorScreen({
    super.key,
    required this.mediaPath,
    this.isVideo = false,
  });

  @override
  State<PhotoEditorScreen> createState() => _PhotoEditorScreenState();
}

class _TextOverlay {
  String text;
  Offset position;
  Color color;

  _TextOverlay({required this.text, required this.position, required this.color});
}

class _StickerOverlay {
  String emoji;
  Offset position;

  _StickerOverlay({required this.emoji, required this.position});
}

class _DrawnLine {
  List<Offset> path;
  Color color;

  _DrawnLine({required this.path, required this.color});
}

class _PhotoEditorScreenState extends State<PhotoEditorScreen> {
  final List<_TextOverlay> _texts = [];
  final List<_StickerOverlay> _stickers = [];
  final List<_DrawnLine> _lines = [];
  final List<_DrawnLine> _undoHistory = [];

  Color _selectedColor = AppTheme.primaryCyan;
  String _selectedFilter = 'Normal';
  double _brightness = 0.0;
  double _contrast = 1.0;
  int _rotationQuarterTurns = 0;

  bool _isDrawingMode = false;
  List<Offset> _currentLinePath = [];

  final List<String> _filters = ['Normal', 'Vintage', 'B&W', 'Cyber', 'Vivid', 'Sepia'];
  final List<Color> _colorPalette = [
    AppTheme.primaryCyan,
    AppTheme.accentPink,
    AppTheme.accentPurple,
    Colors.yellow,
    Colors.green,
    Colors.white,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Main Media Canvas
            Center(
              child: GestureDetector(
                onPanStart: _isDrawingMode ? (details) {
                  setState(() {
                    _currentLinePath = [details.localPosition];
                  });
                } : null,
                onPanUpdate: _isDrawingMode ? (details) {
                  setState(() {
                    _currentLinePath.add(details.localPosition);
                  });
                } : null,
                onPanEnd: _isDrawingMode ? (details) {
                  setState(() {
                    _lines.add(_DrawnLine(path: List.from(_currentLinePath), color: _selectedColor));
                    _currentLinePath.clear();
                  });
                } : null,
                child: ColorFiltered(
                  colorFilter: _getFilterMatrix(_selectedFilter, _brightness, _contrast),
                  child: RotatedBox(
                    quarterTurns: _rotationQuarterTurns,
                    child: Stack(
                      children: [
                        MediaPreview(mediaPath: widget.mediaPath, isVideo: widget.isVideo, fit: BoxFit.contain),

                        // Drawing layer
                        CustomPaint(
                          painter: _DrawingPainter(lines: _lines, currentPath: _currentLinePath, currentColor: _selectedColor),
                          child: Container(),
                        ),

                        // Text overlays
                        ..._texts.map((t) => Positioned(
                              left: t.position.dx,
                              top: t.position.dy,
                              child: GestureDetector(
                                onPanUpdate: (details) {
                                  setState(() {
                                    t.position += details.delta;
                                  });
                                },
                                child: Text(
                                  t.text,
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: t.color,
                                    shadows: const [
                                      Shadow(color: Colors.black, blurRadius: 4),
                                    ],
                                  ),
                                ),
                              ),
                            )),

                        // Sticker overlays
                        ..._stickers.map((s) => Positioned(
                              left: s.position.dx,
                              top: s.position.dy,
                              child: GestureDetector(
                                onPanUpdate: (details) {
                                  setState(() {
                                    s.position += details.delta;
                                  });
                                },
                                child: Text(
                                  s.emoji,
                                  style: const TextStyle(fontSize: 48),
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Top Action Bar
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.brush, color: _isDrawingMode ? _selectedColor : Colors.white),
                        onPressed: () {
                          setState(() {
                            _isDrawingMode = !_isDrawingMode;
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.text_fields, color: Colors.white),
                        onPressed: _addTextDialog,
                      ),
                      IconButton(
                        icon: const Icon(Icons.emoji_emotions_outlined, color: Colors.white),
                        onPressed: _addStickerPicker,
                      ),
                      IconButton(
                        icon: const Icon(Icons.rotate_right, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            _rotationQuarterTurns = (_rotationQuarterTurns + 1) % 4;
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.undo, color: Colors.white),
                        onPressed: _lines.isNotEmpty
                            ? () {
                                setState(() {
                                  _undoHistory.add(_lines.removeLast());
                                });
                              }
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Color Palette Selector (when drawing mode is enabled)
            if (_isDrawingMode)
              Positioned(
                right: 16,
                top: 100,
                child: Column(
                  children: _colorPalette.map((c) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedColor = c;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: c,
                          border: Border.all(
                            color: _selectedColor == c ? Colors.white : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

            // Bottom Tools & Filters Bar
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Filter Chips
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: _filters.map((f) {
                        final isSel = _selectedFilter == f;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(f, style: TextStyle(color: isSel ? Colors.black : Colors.white)),
                            selected: isSel,
                            selectedColor: AppTheme.primaryCyan,
                            backgroundColor: Colors.white24,
                            onSelected: (_) {
                              setState(() {
                                _selectedFilter = f;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Bottom Buttons: Save / Post Story / Send Chat
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white24,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Media saved to gallery! 📸')),
                          );
                        },
                        icon: const Icon(Icons.download),
                        label: const Text('Save'),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentPurple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        onPressed: () {
                          context.read<StoryProvider>().addStory(
                                mediaUrl: widget.mediaPath,
                                mediaType: widget.isVideo
                                    ? MediaType.video
                                    : MediaType.photo,
                              );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Added to My Story! ⚡️')),
                          );
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.auto_awesome_mosaic),
                        label: const Text('Story'),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryCyan,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Sent in ZipPro Chat! 🚀')),
                          );
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.send),
                        label: const Text('Send'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addTextDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Text Overlay'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Type something...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  _texts.add(_TextOverlay(
                    text: controller.text,
                    position: const Offset(100, 200),
                    color: _selectedColor,
                  ));
                });
              }
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addStickerPicker() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        final emojis = ['🔥', '⚡️', '😎', '📸', '✨', '🎉', '🚀', '❤️', '💯', '👑'];
        return Container(
          padding: const EdgeInsets.all(16),
          height: 160,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemCount: emojis.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _stickers.add(_StickerOverlay(
                      emoji: emojis[index],
                      position: const Offset(150, 250),
                    ));
                  });
                  Navigator.pop(ctx);
                },
                child: Center(
                  child: Text(emojis[index], style: const TextStyle(fontSize: 32)),
                ),
              );
            },
          ),
        );
      },
    );
  }

  ColorFilter _getFilterMatrix(String filter, double b, double c) {
    if (filter == 'B&W') {
      return const ColorFilter.matrix([
        0.2126, 0.7152, 0.0722, 0, 0,
        0.2126, 0.7152, 0.0722, 0, 0,
        0.2126, 0.7152, 0.0722, 0, 0,
        0,      0,      0,      1, 0,
      ]);
    } else if (filter == 'Sepia') {
      return const ColorFilter.matrix([
        0.393, 0.769, 0.189, 0, 0,
        0.349, 0.686, 0.168, 0, 0,
        0.272, 0.534, 0.131, 0, 0,
        0,     0,     0,     1, 0,
      ]);
    } else if (filter == 'Cyber') {
      return const ColorFilter.matrix([
        1.2, 0,   0.5, 0, 0,
        0,   1.1, 0,   0, 0,
        0.5, 0,   1.5, 0, 0,
        0,   0,   0,   1, 0,
      ]);
    }
    return const ColorFilter.mode(Colors.transparent, BlendMode.dst);
  }
}

class _DrawingPainter extends CustomPainter {
  final List<_DrawnLine> lines;
  final List<Offset> currentPath;
  final Color currentColor;

  _DrawingPainter({
    required this.lines,
    required this.currentPath,
    required this.currentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var line in lines) {
      final paint = Paint()
        ..color = line.color
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round;
      for (int i = 0; i < line.path.length - 1; i++) {
        canvas.drawLine(line.path[i], line.path[i + 1], paint);
      }
    }

    if (currentPath.isNotEmpty) {
      final paint = Paint()
        ..color = currentColor
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round;
      for (int i = 0; i < currentPath.length - 1; i++) {
        canvas.drawLine(currentPath[i], currentPath[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
