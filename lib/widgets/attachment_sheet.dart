import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class AttachmentSheet extends StatelessWidget {
  final Function(String type) onOptionSelected;

  const AttachmentSheet({
    super.key,
    required this.onOptionSelected,
  });

  Widget _buildOptionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withAlpha(38),
              shape: BoxShape.circle,
              border: Border.all(color: color.withAlpha(128), width: 1.5),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: const BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.borderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 3,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildOptionItem(
                icon: Icons.photo_library_rounded,
                label: 'Gallery',
                color: AppColors.primaryBlue,
                onTap: () => onOptionSelected('gallery'),
              ),
              _buildOptionItem(
                icon: Icons.camera_alt_rounded,
                label: 'Camera',
                color: Colors.pinkAccent,
                onTap: () => onOptionSelected('camera'),
              ),
              _buildOptionItem(
                icon: Icons.insert_drive_file_rounded,
                label: 'Document',
                color: Colors.purpleAccent,
                onTap: () => onOptionSelected('document'),
              ),
              _buildOptionItem(
                icon: Icons.location_on_rounded,
                label: 'Location',
                color: AppColors.successGreen,
                onTap: () => onOptionSelected('location'),
              ),
              _buildOptionItem(
                icon: Icons.person_rounded,
                label: 'Contact',
                color: AppColors.warningOrange,
                onTap: () => onOptionSelected('contact'),
              ),
              _buildOptionItem(
                icon: Icons.headphones_rounded,
                label: 'Audio',
                color: Colors.tealAccent,
                onTap: () => onOptionSelected('audio'),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
