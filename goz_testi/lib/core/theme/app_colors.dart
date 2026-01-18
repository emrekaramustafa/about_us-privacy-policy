import 'package:flutter/material.dart';

/// Application Color Palette
/// 
/// Medical-grade color scheme with clean whites and calming blues.
/// Designed for clarity and accessibility in eye testing scenarios.
class AppColors {
  AppColors._();

  // Primary Colors - Medical Blue Palette
  static const Color medicalBlue = Color(0xFF2563EB);
  static const Color medicalBlueDark = Color(0xFF1D4ED8);
  static const Color medicalBlueLight = Color(0xFF3B82F6);
  static const Color medicalBluePale = Color(0xFFDBEAFE);
  
  // Secondary Colors - Medical Teal
  static const Color medicalTeal = Color(0xFF0D9488);
  static const Color medicalTealLight = Color(0xFF14B8A6);
  static const Color medicalTealPale = Color(0xFFCCFBF1);
  
  // Neutral Colors
  static const Color cleanWhite = Color(0xFFFAFAFA);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color backgroundGrey = Color(0xFFF5F5F5);
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color borderMedium = Color(0xFFD1D5DB);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textDisabled = Color(0xFFD1D5DB);
  
  // Status Colors
  static const Color successGreen = Color(0xFF10B981);
  static const Color successGreenPale = Color(0xFFD1FAE5);
  static const Color warningYellow = Color(0xFFF59E0B);
  static const Color warningYellowPale = Color(0xFFFEF3C7);
  static const Color errorRed = Color(0xFFEF4444);
  static const Color errorRedPale = Color(0xFFFEE2E2);
  static const Color infoBlue = Color(0xFF3B82F6);
  static const Color infoBluePale = Color(0xFFDBEAFE);
  
  // Premium/Gold Colors
  static const Color premiumGold = Color(0xFFD97706);
  static const Color premiumGoldLight = Color(0xFFFBBF24);
  static const Color premiumGoldPale = Color(0xFFFEF3C7);
  
  // Gradient Colors for Cards
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [medicalBlue, medicalBlueDark],
  );
  
  static const LinearGradient tealGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [medicalTeal, Color(0xFF0F766E)],
  );
  
  static const LinearGradient premiumGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [premiumGold, Color(0xFFB45309)],
  );
  
  // Ishihara Test Colors (Color blindness test specific)
  static const Color ishiharaRed = Color(0xFFE53935);
  static const Color ishiharaGreen = Color(0xFF43A047);
  static const Color ishiharaOrange = Color(0xFFFF9800);
  static const Color ishiharaYellow = Color(0xFFFFEB3B);
  static const Color ishiharaBrown = Color(0xFF795548);
  static const Color ishiharaGrey = Color(0xFF9E9E9E);
}

