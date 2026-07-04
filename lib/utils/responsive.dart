import 'package:flutter/material.dart';

extension ResponsiveExtension on BuildContext {
  // Screen size accessors
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;

  // Percentage-based sizing helpers
  double wp(double percent) => screenWidth * (percent / 100);
  double hp(double percent) => screenHeight * (percent / 100);

  // Scalable pixel / font size helper
  // Base width standard set to 375.0 (iPhone / typical phone dimensions)
  double sp(double size) {
    final double textScale = MediaQuery.textScalerOf(this).scale(size);
    final double scaleFactor = screenWidth / 375.0;
    // Clamp the scaling factor to prevent overly giant or minuscule text on tablets/foldables
    final double clampedScale = scaleFactor.clamp(0.85, 1.3);
    return textScale * clampedScale;
  }

  // Device orientation / layout helper
  bool get isLandscape => MediaQuery.orientationOf(this) == Orientation.landscape;

  // Breakpoints
  bool get isMobile => screenWidth < 600;
  bool get isTablet => screenWidth >= 600 && screenWidth < 1024;
  bool get isDesktop => screenWidth >= 1024;
}
