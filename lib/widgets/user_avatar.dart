import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';

class UserAvatar extends StatelessWidget {
  final String? url;
  final String name;
  final double radius;
  final bool isOnline;

  const UserAvatar({
    super.key,
    this.url,
    required this.name,
    this.radius = 24,
    this.isOnline = false,
  });

  @override
  Widget build(BuildContext context) {
    final initials = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Stack(
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: AppConstants.primaryColor,
          backgroundImage: (url != null && url!.isNotEmpty) ? NetworkImage(url!) : null,
          child: (url == null || url!.isEmpty)
              ? Text(
                  initials,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: radius * 0.8,
                  ),
                )
              : null,
        ),
        if (isOnline)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: radius * 0.6,
              height: radius * 0.6,
              decoration: BoxDecoration(
                color: Colors.greenAccent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
