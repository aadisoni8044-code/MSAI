import 'package:flutter/material.dart';

class PermissionService {
  bool _cameraGranted = true;
  bool _microphoneGranted = true;
  bool _photosGranted = true;
  bool _notificationsGranted = true;

  bool get cameraGranted => _cameraGranted;
  bool get microphoneGranted => _microphoneGranted;
  bool get photosGranted => _photosGranted;
  bool get notificationsGranted => _notificationsGranted;

  Future<bool> requestCameraPermission() async {
    _cameraGranted = true;
    return true;
  }

  Future<bool> requestMicrophonePermission() async {
    _microphoneGranted = true;
    return true;
  }

  Future<bool> requestPhotosPermission() async {
    _photosGranted = true;
    return true;
  }

  void toggleCamera(bool val) => _cameraGranted = val;
  void toggleMicrophone(bool val) => _microphoneGranted = val;
  void togglePhotos(bool val) => _photosGranted = val;
  void toggleNotifications(bool val) => _notificationsGranted = val;

  static Future<void> showPermissionDialog({
    required BuildContext context,
    required String title,
    required String description,
    required VoidCallback onGrant,
  }) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(description),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onGrant();
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Allow Access'),
          ),
        ],
      ),
    );
  }
}
