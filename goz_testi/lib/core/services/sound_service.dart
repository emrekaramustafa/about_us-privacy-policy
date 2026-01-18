import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';

/// Sound Service
/// Manages button click sounds and other audio feedback
class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _isEnabled = true; // Can be toggled by user settings

  /// Enable or disable sounds
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  bool get isEnabled => _isEnabled;

  /// Play a button click sound
  /// Uses system sound if asset file is not available
  /// Web: Silently fails (not important for web)
  Future<void> playButtonClick() async {
    if (!_isEnabled) return;
    
    // Web: Skip sound (not important)
    if (kIsWeb) return;
    
    try {
      // Try to play asset sound first
      await _player.play(AssetSource('sounds/button_click.mp3'));
    } catch (e) {
      // If asset not found, use system sound as fallback
      try {
        await SystemSound.play(SystemSoundType.click);
      } catch (e) {
        // Silently fail if system sound also fails
      }
    }
  }

  /// Play a success sound
  /// Uses system sound if asset file is not available
  /// Web: Silently fails (not important for web)
  Future<void> playSuccess() async {
    if (!_isEnabled) return;
    
    // Web: Skip sound (not important)
    if (kIsWeb) return;
    
    try {
      await _player.play(AssetSource('sounds/success.mp3'));
    } catch (e) {
      // Fallback to system sound
      try {
        await SystemSound.play(SystemSoundType.click);
      } catch (e) {
        // Silently fail
      }
    }
  }

  /// Play an error sound
  /// Uses system sound if asset file is not available
  /// Web: Silently fails (not important for web)
  Future<void> playError() async {
    if (!_isEnabled) return;
    
    // Web: Skip sound (not important)
    if (kIsWeb) return;
    
    try {
      await _player.play(AssetSource('sounds/error.mp3'));
    } catch (e) {
      // Fallback to system alert sound
      try {
        await SystemSound.play(SystemSoundType.alert);
      } catch (e) {
        // Silently fail
      }
    }
  }

  /// Play a custom sound from assets
  /// 
  /// Example: playSound('sounds/custom_sound.mp3')
  /// If asset not found, falls back to system click sound
  /// Web: Silently fails (not important for web)
  Future<void> playSound(String assetPath) async {
    if (!_isEnabled) return;
    
    // Web: Skip sound (not important)
    if (kIsWeb) return;
    
    try {
      await _player.play(AssetSource(assetPath));
    } catch (e) {
      // Fallback to system sound
      try {
        await SystemSound.play(SystemSoundType.click);
      } catch (e) {
        // Silently fail
      }
    }
  }

  /// Play system click sound (always works, no asset needed)
  /// This is a simple beep sound that works on mobile platforms
  /// Web: Silently fails (not important for web)
  Future<void> playSystemClick() async {
    if (!_isEnabled) return;
    
    // Web: Skip sound (not important)
    if (kIsWeb) return;
    
    try {
      await SystemSound.play(SystemSoundType.click);
    } catch (e) {
      // Silently fail
    }
  }

  /// Play system alert sound (always works, no asset needed)
  /// Web: Silently fails (not important for web)
  Future<void> playSystemAlert() async {
    if (!_isEnabled) return;
    
    // Web: Skip sound (not important)
    if (kIsWeb) return;
    
    try {
      await SystemSound.play(SystemSoundType.alert);
    } catch (e) {
      // Silently fail
    }
  }

  /// Dispose resources
  void dispose() {
    _player.dispose();
  }
}
