import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class AttachmentSheet extends StatelessWidget {
  final Function(String type) onOptionSelected;

  const AttachmentSheet({super.key, required this.onOptionSelected});

  Widget _buildOption(BuildContext context, IconData icon, String label, Color color, String type) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onOptionSelected(type);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: color.withAlpha(40),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textMuted,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 3,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            children: [
              _buildOption(context, Icons.photo_library_rounded, 'Gallery', Colors.purpleAccent, 'gallery'),
              _buildOption(context, Icons.camera_alt_rounded, 'Camera', Colors.redAccent, 'camera'),
              _buildOption(context, Icons.insert_drive_file_rounded, 'Document', AppColors.primary, 'document'),
              _buildOption(context, Icons.headphones_rounded, 'Audio', Colors.orangeAccent, 'audio'),
              _buildOption(context, Icons.location_on_rounded, 'Location', Colors.green, 'location'),
              _buildOption(context, Icons.person_rounded, 'Contact', Colors.cyan, 'contact'),
            ],
          ),
        ],
      ),
    );
  }
}
