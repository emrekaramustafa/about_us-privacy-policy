import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:goz_testi/features/tests/common/presentation/providers/test_provider.dart';

/// Storage Service
/// Manages persistent storage for test results and exercise history
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  /// Get SharedPreferences instance (for internal use)
  Future<SharedPreferences> _getSharedPreferences() async {
    return await SharedPreferences.getInstance();
  }

  static const String _testHistoryKey = 'test_history';
  static const String _exerciseHistoryKey = 'exercise_history';
  static const String _dailyTestCountKey = 'daily_test_count';
  static const String _extraTestCreditsKey = 'extra_test_credits'; // Reklam izlenerek kazanılan ekstra haklar
  static const String _lastResetDateKey = 'last_reset_date';
  static const String _hasSeenSoftGateTodayKey = 'has_seen_soft_gate_today';
  static const int _maxHistoryItems = 100; // Keep last 100 test results

  /// Save a test result
  Future<void> saveTestResult(TestResult result) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getTestHistory();
    
    // Add new result at the beginning
    history.insert(0, result);
    
    // Keep only last N items
    if (history.length > _maxHistoryItems) {
      history.removeRange(_maxHistoryItems, history.length);
    }
    
    // Save to SharedPreferences
    final jsonList = history.map((r) => _testResultToJson(r)).toList();
    await prefs.setString(_testHistoryKey, jsonEncode(jsonList));
  }

  /// Get all test results
  Future<List<TestResult>> getTestHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_testHistoryKey);
    
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    
    try {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList.map((json) => _testResultFromJson(json)).toList();
    } catch (e) {
      // If parsing fails, return empty list
      return [];
    }
  }

  /// Get test results by type
  Future<List<TestResult>> getTestHistoryByType(String testType) async {
    final history = await getTestHistory();
    return history.where((result) => result.testType == testType).toList();
  }

  /// Get latest test result for a specific test type
  Future<TestResult?> getLatestTestResult(String testType) async {
    final history = await getTestHistoryByType(testType);
    if (history.isEmpty) return null;
    return history.first; // Already sorted by date (newest first)
  }

  /// Clear all test history
  Future<void> clearTestHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_testHistoryKey);
  }

  /// Delete a specific test result
  Future<void> deleteTestResult(String testType, DateTime dateTime) async {
    final history = await getTestHistory();
    history.removeWhere((result) => 
      result.testType == testType && 
      result.dateTime.isAtSameMomentAs(dateTime)
    );
    
    final prefs = await SharedPreferences.getInstance();
    final jsonList = history.map((r) => _testResultToJson(r)).toList();
    await prefs.setString(_testHistoryKey, jsonEncode(jsonList));
  }

  /// Get test statistics
  Future<Map<String, dynamic>> getTestStatistics() async {
    final history = await getTestHistory();
    
    if (history.isEmpty) {
      return {
        'totalTests': 0,
        'averageScore': 0.0,
        'testsByType': <String, int>{},
        'lastTestDate': null,
      };
    }
    
    final totalTests = history.length;
    final averageScore = history.map((r) => r.percentage).reduce((a, b) => a + b) / totalTests;
    
    final testsByType = <String, int>{};
    for (final result in history) {
      testsByType[result.testType] = (testsByType[result.testType] ?? 0) + 1;
    }
    
    final lastTestDate = history.first.dateTime;
    
    return {
      'totalTests': totalTests,
      'averageScore': averageScore,
      'testsByType': testsByType,
      'lastTestDate': lastTestDate.toIso8601String(),
    };
  }

  /// Convert TestResult to JSON
  Map<String, dynamic> _testResultToJson(TestResult result) {
    return {
      'testType': result.testType,
      'dateTime': result.dateTime.toIso8601String(),
      'score': result.score,
      'totalQuestions': result.totalQuestions,
      'details': result.details,
    };
  }

  /// Convert JSON to TestResult
  TestResult _testResultFromJson(Map<String, dynamic> json) {
    return TestResult(
      testType: json['testType'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
      score: json['score'] as int,
      totalQuestions: json['totalQuestions'] as int,
      details: json['details'] as Map<String, dynamic>?,
    );
  }

  /// Save exercise completion
  Future<void> saveExerciseCompletion(String profile, DateTime dateTime) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getExerciseHistory(profile);
    
    // Check if already completed today
    final today = DateTime.now();
    final alreadyCompleted = history.any((date) =>
      date.year == today.year &&
      date.month == today.month &&
      date.day == today.day
    );
    
    if (!alreadyCompleted) {
      history.insert(0, dateTime);
      
      // Keep only last 90 days
      if (history.length > 90) {
        history.removeRange(90, history.length);
      }
      
      final jsonList = history.map((d) => d.toIso8601String()).toList();
      await prefs.setStringList('${_exerciseHistoryKey}_$profile', jsonList);
    }
  }

  /// Get exercise history for a profile
  Future<List<DateTime>> getExerciseHistory(String profile) async {
    final prefs = await SharedPreferences.getInstance();
    final dateStrings = prefs.getStringList('${_exerciseHistoryKey}_$profile') ?? [];
    
    return dateStrings.map((s) => DateTime.parse(s)).toList();
  }

  /// Get exercise statistics for a profile
  Future<Map<String, dynamic>> getExerciseStatistics(String profile) async {
    final history = await getExerciseHistory(profile);
    final now = DateTime.now();
    
    // Last 7 days
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    final last7Days = history.where((d) => d.isAfter(sevenDaysAgo)).length;
    
    // Last 30 days
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    final last30Days = history.where((d) => d.isAfter(thirtyDaysAgo)).length;
    
    // Current streak
    int streak = 0;
    DateTime? lastDate;
    for (final date in history) {
      if (lastDate == null) {
        lastDate = date;
        streak = 1;
      } else {
        final daysDiff = lastDate.difference(date).inDays;
        if (daysDiff == 1) {
          streak++;
          lastDate = date;
        } else {
          break;
        }
      }
    }
    
    return {
      'totalExercises': history.length,
      'last7Days': last7Days,
      'last30Days': last30Days,
      'currentStreak': streak,
      'lastExerciseDate': history.isNotEmpty ? history.first.toIso8601String() : null,
    };
  }

  /// Get daily test count for today
  Future<int> getDailyTestCount() async {
    await resetDailyCountsIfNeeded();
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_dailyTestCountKey) ?? 0;
  }

  /// Increment daily test count
  Future<void> incrementDailyTestCount() async {
    await resetDailyCountsIfNeeded();
    final prefs = await SharedPreferences.getInstance();
    final currentCount = prefs.getInt(_dailyTestCountKey) ?? 0;
    await prefs.setInt(_dailyTestCountKey, currentCount + 1);
  }

  /// Reset daily counts if needed (at midnight)
  Future<void> resetDailyCountsIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final lastResetDateStr = prefs.getString(_lastResetDateKey);
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    if (lastResetDateStr != null) {
      final lastResetDate = DateTime.parse(lastResetDateStr);
      final lastResetDay = DateTime(lastResetDate.year, lastResetDate.month, lastResetDate.day);
      
      // If it's a new day, reset counts
      if (today.isAfter(lastResetDay)) {
        await prefs.setInt(_dailyTestCountKey, 0);
        await prefs.setInt(_extraTestCreditsKey, 0);
        await prefs.setBool(_hasSeenSoftGateTodayKey, false);
        await prefs.setString(_lastResetDateKey, today.toIso8601String());
      }
    } else {
      // First time, set today as reset date
      await prefs.setString(_lastResetDateKey, today.toIso8601String());
    }
  }

  /// Check if user has seen soft gate today
  Future<bool> hasSeenSoftGateToday() async {
    await resetDailyCountsIfNeeded();
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasSeenSoftGateTodayKey) ?? false;
  }

  /// Mark soft gate as seen today
  Future<void> markSoftGateSeenToday() async {
    await resetDailyCountsIfNeeded();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSeenSoftGateTodayKey, true);
  }

  /// Add extra test credit (after watching ad)
  /// User can watch up to 18 ads to get 18 extra tests (3 free + 18 ads = 21 max)
  /// Increments extra credits counter
  Future<void> addExtraTestCredit() async {
    await resetDailyCountsIfNeeded();
    final prefs = await SharedPreferences.getInstance();
    final currentCount = prefs.getInt(_dailyTestCountKey) ?? 0;
    final currentCredits = prefs.getInt(_extraTestCreditsKey) ?? 0;
    
    // Maximum 21 tests per day (3 free + 18 ads)
    // Check if we can add more credits (total available = 3 free + credits)
    final totalAvailable = 3 + currentCredits;
    if (totalAvailable < 21) {
      // Increment extra credits (max 18 ads = 18 credits)
      final newCredits = (currentCredits + 1).clamp(0, 18);
      await prefs.setInt(_extraTestCreditsKey, newCredits);
      debugPrint('Extra test credit added. Credits: $currentCredits -> $newCredits, Test count: $currentCount');
    } else {
      debugPrint('Daily test limit reached (21). Cannot add more credits.');
    }
  }

  /// Get remaining test credits
  /// Returns: 3 (free) + extra credits - tests taken
  Future<int> getRemainingTestCredits() async {
    await resetDailyCountsIfNeeded();
    final prefs = await SharedPreferences.getInstance();
    final testCount = prefs.getInt(_dailyTestCountKey) ?? 0;
    final extraCredits = prefs.getInt(_extraTestCreditsKey) ?? 0;
    
    // Total available = 3 free + extra credits from ads
    final totalAvailable = 3 + extraCredits;
    // Remaining = total available - tests taken
    final remaining = (totalAvailable - testCount).clamp(0, 21);
    
    return remaining;
  }
}
