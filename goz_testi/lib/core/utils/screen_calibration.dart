import 'package:flutter/material.dart';

/// Screen Calibration Utility
class ScreenCalibration {
  ScreenCalibration._();

  static const double standardViewingDistanceCm = 40.0;
  static const double referenceScreenWidth = 393.0;
  
  static double getCalibrationFactor(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth / referenceScreenWidth;
  }
  
  static double calibratedFontSize(BuildContext context, double baseFontSize) {
    final factor = getCalibrationFactor(context);
    return baseFontSize * factor;
  }
  
  static double calibratedSize(BuildContext context, double baseSize) {
    final factor = getCalibrationFactor(context);
    return baseSize * factor;
  }
  
  /// Get the Letter size for a specific acuity level
  /// First question starts at 24pt (same as option buttons)
  /// Each subsequent question decreases by 2pt
  static double getSnellenSize(BuildContext context, int level) {
    // Start at 24pt (same as option button text size)
    // Decrease by 2pt per level: 24, 22, 20, 18, 16, 14, 12, 10, 8, 6
    const double startSize = 24.0;
    const double decreasePerLevel = 2.0;
    
    final safeLevel = level.clamp(1, 10);
    final baseSize = startSize - (safeLevel - 1) * decreasePerLevel;
    return calibratedSize(context, baseSize);
  }
  
  static String levelToMetricAcuity(int level) {
    final acuity = level.clamp(1, 10);
    return '$acuity/10';
  }
  
  static String getViewingDistanceRecommendation(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth < 350) {
      return '30 cm';
    } else if (screenWidth < 400) {
      return '35 cm';
    } else if (screenWidth < 450) {
      return '40 cm';
    } else {
      return '45 cm';
    }
  }
}
