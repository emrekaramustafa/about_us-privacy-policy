import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:goz_testi/core/router/app_router.dart';
import 'package:goz_testi/core/services/storage_service.dart';
import 'package:goz_testi/features/tests/common/presentation/providers/test_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Test Limit Checker
/// 
/// Utility class to check if user can start a test based on daily limits
class TestLimitChecker {
  /// Check if user can start a test
  /// Returns true if user can start, false otherwise
  /// If false, shows dialog or navigates to daily test info page
  /// 
  /// Can work with or without WidgetRef (uses ProviderScope if ref not provided)
  static Future<bool> canStartTest(BuildContext context, [WidgetRef? ref]) async {
    bool isPremium = false;
    
    // ALWAYS check SharedPreferences FIRST (most reliable source of truth)
    // This ensures premium status is checked even if provider state is stale
    try {
      final prefs = await SharedPreferences.getInstance();
      isPremium = prefs.getBool('is_premium') ?? false;
      debugPrint('Premium status from SharedPreferences (primary check): $isPremium');
    } catch (e) {
      debugPrint('Error accessing SharedPreferences: $e');
    }
    
    // Also check provider as secondary source (for real-time updates)
    // But SharedPreferences takes precedence since it's the source of truth
    if (!isPremium) {
      if (ref != null) {
        try {
          final providerPremium = ref.read(isPremiumProvider);
          if (providerPremium) {
            isPremium = true;
            debugPrint('Premium status confirmed from provider: $isPremium');
          }
        } catch (e) {
          debugPrint('Error reading premium from provider: $e');
        }
      } else {
        // Try to get from ProviderScope if available
        try {
          final container = ProviderScope.containerOf(context, listen: false);
          final providerPremium = container.read(isPremiumProvider);
          if (providerPremium) {
            isPremium = true;
            debugPrint('Premium status confirmed from ProviderScope: $isPremium');
          }
        } catch (e) {
          debugPrint('ProviderScope not available: $e');
        }
      }
    }
    
    // Premium users can always start tests
    if (isPremium) {
      return true;
    }
    
    // Check daily test count
    try {
      final storageService = StorageService();
      final dailyCount = await storageService.getDailyTestCount();
      
      // If daily limit reached (3 tests), show dialog
      if (dailyCount >= 3) {
        return await _showTestLimitDialog(context);
      }
    } catch (e) {
      // If daily count check fails, allow test to proceed (fail open)
      debugPrint('Error checking daily test count: $e');
    }
    
    return true;
  }
  
  /// Show dialog when test limit is reached
  static Future<bool> _showTestLimitDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Günlük Test Kotası Doldu'),
        content: const Text(
          'Bugün 3 reklamsız test hakkınızı kullandınız. Daha fazla test yapmak için reklam izleyebilir veya Premium olabilirsiniz.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // Don't start test
              context.push(AppRoutes.dailyTestInfo);
            },
            child: const Text('Reklam İzle / Premium'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Don't start test
            child: const Text('İptal'),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }
}
