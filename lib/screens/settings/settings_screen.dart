import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.primaryBlue,
          fontSize: 13,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue.withAlpha(25),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primaryBlue, size: 22),
      ),
      title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
      subtitle: Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _buildSectionHeader('ACCOUNT'),
          _buildTile(
            icon: Icons.person_outline_rounded,
            title: 'Account & Security',
            subtitle: 'Security notifications, change number, delete account',
            onTap: () {},
          ),
          _buildTile(
            icon: Icons.lock_outline_rounded,
            title: 'Privacy',
            subtitle: 'Block contacts, disappearing messages, last seen',
            onTap: () {},
          ),
          _buildSectionHeader('CHATS & APPEARANCE'),
          _buildTile(
            icon: Icons.chat_bubble_outline_rounded,
            title: 'Chats',
            subtitle: 'Theme, wallpapers, chat history, enter to send',
            onTap: () {},
          ),
          _buildTile(
            icon: Icons.palette_outlined,
            title: 'Appearance',
            subtitle: 'Dark Mode (Default), Blue accent glow, Font sizes',
            onTap: () {},
          ),
          _buildSectionHeader('NOTIFICATIONS & STORAGE'),
          _buildTile(
            icon: Icons.notifications_none_rounded,
            title: 'Notifications',
            subtitle: 'Message, group & call tones',
            onTap: () {},
          ),
          _buildTile(
            icon: Icons.data_usage_rounded,
            title: 'Storage & Data',
            subtitle: 'Network usage, auto-download media settings',
            onTap: () {},
          ),
          _buildSectionHeader('ABOUT & HELP'),
          _buildTile(
            icon: Icons.help_outline_rounded,
            title: 'Help Center & Support',
            subtitle: 'Help center, contact us, privacy policy',
            onTap: () {},
          ),
          _buildTile(
            icon: Icons.info_outline_rounded,
            title: 'About ZIPgram',
            subtitle: 'ZIPgram v1.0.0 (Build 2026.09.27)',
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'ZIPgram',
                applicationVersion: '1.0.0+1',
                applicationIcon: const Icon(Icons.flash_on_rounded, color: AppColors.primaryBlue, size: 36),
                children: [
                  const Text('A modern, blazingly fast messaging experience powered by Flutter & Dart.'),
                ],
              );
            },
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
