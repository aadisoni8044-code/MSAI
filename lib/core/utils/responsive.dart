import 'package:flutter/material.dart';

enum DeviceType {
  mobile,
  tablet,
  desktop,
}

class ResponsiveLayout {
  static const double mobileBreakPoint = 600;
  static const double desktopBreakPoint = 1000;

  static DeviceType getDeviceType(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width < mobileBreakPoint) {
      return DeviceType.mobile;
    } else if (width < desktopBreakPoint) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  static bool isMobile(BuildContext context) =>
      getDeviceType(context) == DeviceType.mobile;

  static bool isTablet(BuildContext context) =>
      getDeviceType(context) == DeviceType.tablet;

  static bool isDesktop(BuildContext context) =>
      getDeviceType(context) == DeviceType.desktop;
}

class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, DeviceType deviceType) builder;

  const ResponsiveBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        DeviceType deviceType = DeviceType.mobile;
        if (constraints.maxWidth >= ResponsiveLayout.desktopBreakPoint) {
          deviceType = DeviceType.desktop;
        } else if (constraints.maxWidth >= ResponsiveLayout.mobileBreakPoint) {
          deviceType = DeviceType.tablet;
        }
        return builder(context, deviceType);
      },
    );
  }
}
