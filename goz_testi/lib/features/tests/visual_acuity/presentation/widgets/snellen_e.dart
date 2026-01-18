import 'package:flutter/material.dart';
import 'package:goz_testi/core/theme/app_colors.dart';

/// Snellen E Letter Widget
/// 
/// Renders the optotype "E" used in Snellen eye charts.
/// Can be rotated to face any of the 4 cardinal directions.
class SnellenE extends StatelessWidget {
  final double size;
  final double rotation; // in degrees: 0=right, 90=down, 180=left, 270=up
  final Color color;

  const SnellenE({
    super.key,
    required this.size,
    this.rotation = 0,
    this.color = AppColors.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation * 3.14159 / 180, // Convert degrees to radians
      child: CustomPaint(
        size: Size(size, size),
        painter: SnellenEPainter(color: color),
      ),
    );
  }
}

/// Custom painter for the Snellen E optotype
/// 
/// Draws the E according to standard Snellen proportions:
/// - The E is 5 units tall
/// - Each stroke and gap is 1 unit
/// - The opening faces right (0 degrees)
class SnellenEPainter extends CustomPainter {
  final Color color;

  SnellenEPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Calculate unit size (the E is 5 units × 5 units)
    final unit = size.width / 5;

    // Draw the vertical bar (left side)
    canvas.drawRect(
      Rect.fromLTWH(0, 0, unit, size.height),
      paint,
    );

    // Draw top horizontal bar
    canvas.drawRect(
      Rect.fromLTWH(unit, 0, size.width - unit, unit),
      paint,
    );

    // Draw middle horizontal bar
    canvas.drawRect(
      Rect.fromLTWH(unit, unit * 2, size.width - unit, unit),
      paint,
    );

    // Draw bottom horizontal bar
    canvas.drawRect(
      Rect.fromLTWH(unit, unit * 4, size.width - unit, unit),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant SnellenEPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

