import 'dart:math';
import 'package:flutter/material.dart';
import 'package:goz_testi/core/theme/app_colors.dart';

/// Ishihara Plate Widget
/// 
/// Generates a simulated Ishihara color blindness test plate
/// with colored dots and an embedded number.
class IshiharaPlate extends StatelessWidget {
  final int number;
  final double size;
  final int seed;

  const IshiharaPlate({
    super.key,
    required this.number,
    this.size = 300,
    this.seed = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipOval(
        child: CustomPaint(
          size: Size(size, size),
          painter: IshiharaPlatePainter(
            number: number,
            seed: seed,
          ),
        ),
      ),
    );
  }
}

/// Custom painter for Ishihara plate
class IshiharaPlatePainter extends CustomPainter {
  final int number;
  final int seed;
  final Random _random;

  IshiharaPlatePainter({
    required this.number,
    required this.seed,
  }) : _random = Random(seed * 1000 + number);

  // Color palette for normal vision number (red/orange)
  static const List<Color> numberColors = [
    Color(0xFFE53935), // Red
    Color(0xFFF44336), // Light Red
    Color(0xFFEF5350), // Even Lighter Red
    Color(0xFFFF5722), // Deep Orange
    Color(0xFFFF7043), // Light Deep Orange
  ];

  // Color palette for background (green/yellow-green)
  static const List<Color> backgroundColors = [
    Color(0xFF43A047), // Green
    Color(0xFF66BB6A), // Light Green
    Color(0xFF81C784), // Even Lighter Green
    Color(0xFF4CAF50), // Green
    Color(0xFFA5D6A7), // Pale Green
    Color(0xFFAED581), // Light Yellow-Green
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Generate dots covering the entire plate
    final List<_Dot> dots = [];
    
    // Create a grid of dots with some randomness
    final dotCount = 800;
    
    for (int i = 0; i < dotCount; i++) {
      // Random position within the circle
      double x, y;
      do {
        x = _random.nextDouble() * size.width;
        y = _random.nextDouble() * size.height;
      } while ((Offset(x, y) - center).distance > radius - 5);
      
      // Random size for variety
      final dotRadius = 4.0 + _random.nextDouble() * 8.0;
      
      // Check if this dot is part of the number
      final isNumberDot = _isPointInNumber(
        x - center.dx,
        y - center.dy,
        size.width,
        number,
      );
      
      // Select color based on whether it's part of the number
      final Color color;
      if (isNumberDot) {
        color = numberColors[_random.nextInt(numberColors.length)];
      } else {
        color = backgroundColors[_random.nextInt(backgroundColors.length)];
      }
      
      dots.add(_Dot(
        position: Offset(x, y),
        radius: dotRadius,
        color: color,
      ));
    }
    
    // Sort dots by size for better visual layering (smaller on top)
    dots.sort((a, b) => b.radius.compareTo(a.radius));
    
    // Draw all dots
    for (final dot in dots) {
      final paint = Paint()
        ..color = dot.color
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(dot.position, dot.radius, paint);
    }
  }

  /// Check if a point is within the number shape
  bool _isPointInNumber(double x, double y, double plateSize, int number) {
    // Normalize coordinates to -1 to 1 range
    final nx = x / (plateSize * 0.35);
    final ny = y / (plateSize * 0.35);
    
    // Simple number detection using regions
    final numStr = number.toString();
    final charCount = numStr.length;
    
    for (int i = 0; i < charCount; i++) {
      final char = numStr[i];
      // Calculate offset for multi-digit numbers
      final offsetX = (i - (charCount - 1) / 2) * 0.7;
      final localX = nx - offsetX;
      
      if (_isPointInDigit(localX, ny, char)) {
        return true;
      }
    }
    
    return false;
  }

  /// Check if a point is within a specific digit shape
  bool _isPointInDigit(double x, double y, String digit) {
    // Simplified digit detection using geometric shapes
    // Each digit is defined as a set of line segments and curves
    
    switch (digit) {
      case '0':
        // Oval shape
        return (x * x / 0.16 + y * y / 0.36).abs() < 1 &&
               (x * x / 0.06 + y * y / 0.2).abs() > 1;
      
      case '1':
        // Vertical line
        return x.abs() < 0.12 && y > -0.55 && y < 0.55;
      
      case '2':
        // Top curve + middle diagonal + bottom line
        final topArc = y > 0.1 && y < 0.5 && (x * x + (y - 0.3) * (y - 0.3)) < 0.12 && x > -0.05;
        final diagonal = y >= -0.3 && y <= 0.1 && (x + y * 0.6).abs() < 0.15;
        final bottom = y > -0.55 && y < -0.35 && x > -0.3 && x < 0.35;
        return topArc || diagonal || bottom;
      
      case '3':
        // Two arcs stacked
        final topArc = y > 0.15 && y < 0.55 && (x * x + (y - 0.35) * (y - 0.35)) < 0.1 && x > -0.1;
        final bottomArc = y > -0.55 && y < -0.15 && (x * x + (y + 0.35) * (y + 0.35)) < 0.1 && x > -0.1;
        final middle = y.abs() < 0.2 && x > -0.1 && x < 0.2;
        return topArc || bottomArc || middle;
      
      case '4':
        // Vertical + horizontal + diagonal
        final vertical = x > 0.1 && x < 0.25 && y > -0.55 && y < 0.55;
        final horizontal = y > -0.1 && y < 0.05 && x > -0.35 && x < 0.25;
        final diagonal = y > 0 && y < 0.5 && (x + y * 0.7).abs() < 0.12;
        return vertical || horizontal || diagonal;
      
      case '5':
        // Top line + middle curve + vertical
        final top = y > 0.35 && y < 0.55 && x > -0.25 && x < 0.25;
        final vertical = x > -0.25 && x < -0.1 && y > 0.1 && y < 0.5;
        final curve = y > -0.5 && y < 0.15 && (x * x + (y + 0.2) * (y + 0.2)) < 0.12 && x > -0.15;
        return top || vertical || curve;
      
      case '6':
        // Large oval with small curve at top
        final oval = (x * x / 0.1 + (y + 0.2) * (y + 0.2) / 0.15) < 1 &&
                     (x * x / 0.04 + (y + 0.2) * (y + 0.2) / 0.06) > 1;
        final topCurve = y > 0.2 && y < 0.55 && x > -0.25 && x < 0 && (x + 0.1).abs() < 0.15;
        return oval || topCurve;
      
      case '7':
        // Top line + diagonal
        final top = y > 0.35 && y < 0.55 && x > -0.25 && x < 0.3;
        final diagonal = y >= -0.55 && y <= 0.4 && (x - y * 0.4).abs() < 0.12;
        return top || diagonal;
      
      case '8':
        // Two circles stacked
        final topCircle = (x * x + (y - 0.28) * (y - 0.28)) < 0.08 &&
                          (x * x + (y - 0.28) * (y - 0.28)) > 0.03;
        final bottomCircle = (x * x + (y + 0.28) * (y + 0.28)) < 0.1 &&
                             (x * x + (y + 0.28) * (y + 0.28)) > 0.04;
        return topCircle || bottomCircle;
      
      case '9':
        // Small circle on top + tail
        final circle = (x * x / 0.1 + (y - 0.2) * (y - 0.2) / 0.15) < 1 &&
                       (x * x / 0.04 + (y - 0.2) * (y - 0.2) / 0.06) > 1;
        final tail = y < 0 && y > -0.55 && x > 0 && x < 0.25;
        return circle || tail;
      
      default:
        return false;
    }
  }

  @override
  bool shouldRepaint(covariant IshiharaPlatePainter oldDelegate) {
    return oldDelegate.number != number || oldDelegate.seed != seed;
  }
}

/// Helper class for dot data
class _Dot {
  final Offset position;
  final double radius;
  final Color color;

  _Dot({
    required this.position,
    required this.radius,
    required this.color,
  });
}

