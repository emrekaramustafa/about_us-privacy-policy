import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:goz_testi/core/services/storage_service.dart';

import 'package:goz_testi/core/services/purchase_service.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// Test State Management
/// 
/// Manages the overall testing state including completed tests count
/// and premium status.

/// Keeps track of completed tests
final completedTestsProvider = StateProvider<int>((ref) => 0);

/// Premium status provider
final isPremiumProvider = StateNotifierProvider<PremiumStatusNotifier, bool>((ref) {
  return PremiumStatusNotifier();
});

/// Daily test count provider
final dailyTestCountProvider = FutureProvider<int>((ref) async {
  final storageService = StorageService();
  return await storageService.getDailyTestCount();
});

/// Remaining test credits provider
final remainingTestCreditsProvider = FutureProvider<int>((ref) async {
  final storageService = StorageService();
  return await storageService.getRemainingTestCredits();
});

/// Premium product details provider
final premiumProductProvider = FutureProvider<ProductDetails?>((ref) async {
  final purchaseService = PurchaseService();
  return await purchaseService.getPremiumProduct();
});

/// Test history provider - loads from storage on first access
final testHistoryProvider = StateNotifierProvider<TestHistoryNotifier, List<TestResult>>((ref) {
  return TestHistoryNotifier();
});

/// Test History Notifier
class TestHistoryNotifier extends StateNotifier<List<TestResult>> {
  final StorageService _storageService = StorageService();
  bool _isInitialized = false;

  TestHistoryNotifier() : super([]) {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    if (_isInitialized) return;
    final history = await _storageService.getTestHistory();
    state = history;
    _isInitialized = true;
  }

  Future<void> refresh() async {
    final history = await _storageService.getTestHistory();
    state = history;
  }
}

/// Test result model
class TestResult {
  final String testType;
  final DateTime dateTime;
  final int score;
  final int totalQuestions;
  final Map<String, dynamic>? details;

  TestResult({
    required this.testType,
    required this.dateTime,
    required this.score,
    required this.totalQuestions,
    this.details,
  });

  double get percentage => totalQuestions > 0 ? score / totalQuestions * 100 : 0;

  String get testName {
    switch (testType) {
      case 'visual_acuity':
        return 'Görme Keskinliği';
      case 'color_vision':
        return 'Renk Körlüğü';
      case 'astigmatism':
        return 'Astigmat';
      case 'stereopsis':
      case 'binocular_vision':
        return 'Vergence Testi';
      case 'near_vision':
        return 'Yakın Görme';
      case 'macular':
        return 'Makula';
      case 'peripheral_vision':
        return 'Periferik Görüş';
      case 'eye_movement':
        return 'Hareket Takip';
      case 'contrast':
        return 'Kontrast Hassasiyeti';
      default:
        return 'Test';
    }
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'testType': testType,
      'dateTime': dateTime.toIso8601String(),
      'score': score,
      'totalQuestions': totalQuestions,
      'details': details,
    };
  }

  /// Create from JSON
  factory TestResult.fromJson(Map<String, dynamic> json) {
    return TestResult(
      testType: json['testType'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
      score: json['score'] as int,
      totalQuestions: json['totalQuestions'] as int,
      details: json['details'] as Map<String, dynamic>?,
    );
  }
}

/// Premium Status Notifier
class PremiumStatusNotifier extends StateNotifier<bool> {
  final StorageService _storageService = StorageService();
  bool _isInitialized = false;

  PremiumStatusNotifier() : super(false) {
    // Load premium status immediately
    _loadPremiumStatus();
  }

  Future<void> _loadPremiumStatus() async {
    if (_isInitialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      // Always start as false (premium resets on app start)
      final isPremium = prefs.getBool('is_premium') ?? false;
      state = isPremium;
      _isInitialized = true;
      debugPrint('Premium status loaded: $isPremium');
    } catch (e) {
      debugPrint('Error loading premium status: $e');
      state = false;
      _isInitialized = true;
    }
  }

  Future<void> setPremium(bool value) async {
    try {
      state = value;
      // Always persist premium status to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_premium', value);
      debugPrint('Premium status set and persisted: $value');
    } catch (e) {
      debugPrint('Error setting premium status: $e');
    }
  }

  Future<void> refresh() async {
    _isInitialized = false; // Reset to force reload
    await _loadPremiumStatus();
  }
}

/// Check if user should see paywall
bool shouldShowPaywall(int completedTests, bool isPremium) {
  return !isPremium && completedTests >= 2;
}

