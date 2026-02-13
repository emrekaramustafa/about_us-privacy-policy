import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';

/// Sound Service
/// Manages haptic feedback and system sounds for answer feedback
class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  bool _isEnabled = true; // Can be toggled by user settings

  /// Enable or disable sounds
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  bool get isEnabled => _isEnabled;

  /// Play a button click sound
  Future<void> playButtonClick() async {
    if (!_isEnabled || kIsWeb) return;
    
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      // Silently fail
    }
  }

  /// Play a success sound - light haptic feedback
  Future<void> playSuccess() async {
    if (!_isEnabled || kIsWeb) return;
    
    try {
      // Light haptic for success
      await HapticFeedback.lightImpact();
      // Short delay then another light tap for "double tap" success feel
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.lightImpact();
    } catch (e) {
      // Silently fail
    }
  }

  /// Play an error sound - heavy haptic feedback + vibration
  Future<void> playError() async {
    if (!_isEnabled || kIsWeb) return;
    
    try {
      // Heavy haptic for error - more noticeable
      await HapticFeedback.heavyImpact();
      // Vibration pattern for error feel
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.heavyImpact();
    } catch (e) {
      // Silently fail
    }
  }

  /// Play a custom sound from assets (now uses haptic)
  Future<void> playSound(String assetPath) async {
    if (!_isEnabled || kIsWeb) return;
    
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      // Silently fail
    }
  }

  /// Play system click sound
  Future<void> playSystemClick() async {
    if (!_isEnabled || kIsWeb) return;
    
    try {
      await HapticFeedback.selectionClick();
    } catch (e) {
      // Silently fail
    }
  }

  /// Play system alert sound
  Future<void> playSystemAlert() async {
    if (!_isEnabled || kIsWeb) return;
    
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      // Silently fail
    }
  }

  /// Dispose resources
  void dispose() {
    // No resources to dispose now
  }
}
