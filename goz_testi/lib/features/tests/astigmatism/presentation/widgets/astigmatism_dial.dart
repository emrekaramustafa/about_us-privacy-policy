import 'dart:math';
import 'package:flutter/material.dart';
import 'package:goz_testi/core/theme/app_colors.dart';

/// Astigmatism Dial Widget
/// 
/// Displays a radial line dial for astigmatism testing.
/// Lines radiate from a central point at even intervals.
class AstigmatismDial extends StatelessWidget {
  final double size;
  final Set<int> selectedLines;
  final Function(int) onLineSelected;
  final int lineCount;

  const AstigmatismDial({
    super.key,
    required this.size,
    required this.selectedLines,
    required this.onLineSelected,
    this.lineCount = 12,
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
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: AppColors.borderLight,
          width: 2,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Lines
          CustomPaint(
            size: Size(size, size),
            painter: AstigmatismDialPainter(
              lineCount: lineCount,
              selectedLines: selectedLines,
            ),
          ),
          
          // Clickable overlays for each line
          ...List.generate(lineCount, (index) {
            final angle = (index * 180 / lineCount) * pi / 180;
            return _buildClickableLineArea(index, angle);
          }),
          
          // Center dot
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: AppColors.textPrimary,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClickableLineArea(int index, double angle) {
    final isSelected = selectedLines.contains(index);
    
    return Transform.rotate(
      angle: angle,
      child: GestureDetector(
        onTap: () => onLineSelected(index),
        child: Container(
          width: size - 40,
          height: 40,
          color: isSelected
              ? AppColors.warningYellow.withOpacity(0.2)
              : Colors.transparent,
        ),
      ),
    );
  }
}

/// Custom painter for the astigmatism dial lines
class AstigmatismDialPainter extends CustomPainter {
  final int lineCount;
  final Set<int> selectedLines;

  AstigmatismDialPainter({
    required this.lineCount,
    required this.selectedLines,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;

    for (int i = 0; i < lineCount; i++) {
      final angle = i * pi / lineCount;
      final isSelected = selectedLines.contains(i);
      
      final paint = Paint()
        ..color = isSelected ? AppColors.warningYellow : AppColors.textPrimary
        ..strokeWidth = isSelected ? 4 : 2.5
        ..strokeCap = StrokeCap.round;

      // Calculate start and end points
      final start = Offset(
        center.dx + cos(angle) * 15,
        center.dy + sin(angle) * 15,
      );
      final end = Offset(
        center.dx + cos(angle) * radius,
        center.dy + sin(angle) * radius,
      );

      // Draw line in both directions
      final startOpposite = Offset(
        center.dx - cos(angle) * 15,
        center.dy - sin(angle) * 15,
      );
      final endOpposite = Offset(
        center.dx - cos(angle) * radius,
        center.dy - sin(angle) * radius,
      );

      canvas.drawLine(start, end, paint);
      canvas.drawLine(startOpposite, endOpposite, paint);
      
      // Draw clock position numbers
      _drawClockNumber(canvas, size, i);
    }
  }

  void _drawClockNumber(Canvas canvas, Size size, int lineIndex) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    
    // Calculate angle for clock position
    final angle = lineIndex * pi / 12 - pi / 2;
    
    // Map line index to clock hour (12-position clock)
    final clockHour = ((lineIndex + 6) % 12);
    if (clockHour == 0 || clockHour == 3 || clockHour == 6 || clockHour == 9) {
      return; // Skip some numbers for cleaner look
    }
    
    final position = Offset(
      center.dx + cos(angle) * radius,
      center.dy + sin(angle) * radius,
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text: (clockHour == 0 ? 12 : clockHour).toString(),
        style: TextStyle(
          color: AppColors.textTertiary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        position.dx - textPainter.width / 2,
        position.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant AstigmatismDialPainter oldDelegate) {
    return oldDelegate.selectedLines != selectedLines;
  }
}

