import 'package:flutter/material.dart';

/// Responsive breakpoints and helpers.
class Responsive {
  static int gridColumns(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w >= 1200) return 4;
    if (w >= 800) return 3;
    return 2;
  }

  static double gridAspectRatio(BuildContext context) {
    final cols = gridColumns(context);
    if (cols >= 3) return 0.70;
    return 0.62;
  }

  static bool isWide(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 800;
}
