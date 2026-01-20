import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:goz_testi/core/theme/app_colors.dart';
import 'package:goz_testi/core/router/app_router.dart';
import 'package:goz_testi/core/services/storage_service.dart';
import 'package:goz_testi/core/services/notification_service.dart';
import 'package:goz_testi/features/tests/common/presentation/providers/test_provider.dart';
import 'package:goz_testi/l10n/app_localizations.dart';

/// Test History Page
/// Displays all test results with statistics and trends
class TestHistoryPage extends ConsumerStatefulWidget {
  const TestHistoryPage({super.key});

  @override
  ConsumerState<TestHistoryPage> createState() => _TestHistoryPageState();
}

enum HistoryViewType { menu, tests, exercises }

class _TestHistoryPageState extends ConsumerState<TestHistoryPage> {
  final StorageService _storageService = StorageService();
  Map<String, dynamic>? _statistics;
  bool _isLoading = true;
  HistoryViewType _currentView = HistoryViewType.menu;
  String _selectedProfile = 'adult';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    // Load history from storage
    await ref.read(testHistoryProvider.notifier).refresh();
    
    // Load statistics
    final stats = await _storageService.getTestStatistics();
    
    // Load selected profile from notification service
    final notificationService = NotificationService();
    final profile = await notificationService.getSelectedProfile();
    _selectedProfile = profile ?? 'adult';
    
    if (mounted) {
      setState(() {
        _statistics = stats;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: AppColors.cleanWhite,
      appBar: AppBar(
        backgroundColor: AppColors.cleanWhite,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () {
            if (_currentView == HistoryViewType.menu) {
              context.pop();
            } else {
              setState(() => _currentView = HistoryViewType.menu);
            }
          },
        ),
        title: Text(
          _currentView == HistoryViewType.menu
              ? l10n.history
              : _currentView == HistoryViewType.tests
                  ? l10n.testHistory
                  : l10n.exerciseHistory,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          if (_currentView == HistoryViewType.tests)
            Builder(
              builder: (context) {
                final testHistory = ref.watch(testHistoryProvider);
                if (testHistory.isEmpty) return const SizedBox.shrink();
                return IconButton(
                  icon: const Icon(LucideIcons.trash2),
                  onPressed: () => _showClearHistoryDialog(),
                  color: AppColors.errorRed,
                );
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildCurrentView(),
    );
  }

  Widget _buildCurrentView() {
    switch (_currentView) {
      case HistoryViewType.menu:
        return _buildMenuView();
      case HistoryViewType.tests:
        return _buildTestsView();
      case HistoryViewType.exercises:
        return _buildExercisesView();
    }
  }

  Widget _buildMenuView() {
    final l10n = AppLocalizations.of(context)!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          _buildMenuCard(
            icon: LucideIcons.clipboardCheck,
            title: l10n.testHistory,
            subtitle: l10n.viewAllTestResults,
            gradient: LinearGradient(
              colors: [AppColors.medicalBlue, AppColors.medicalTeal],
            ),
            onTap: () {
              setState(() => _currentView = HistoryViewType.tests);
            },
          ),
          const SizedBox(height: 16),
          _buildMenuCard(
            icon: LucideIcons.activity,
            title: l10n.exerciseHistory,
            subtitle: l10n.viewExerciseHistoryCalendar,
            gradient: LinearGradient(
              colors: [AppColors.medicalTeal, AppColors.medicalBlue],
            ),
            onTap: () {
              setState(() => _currentView = HistoryViewType.exercises);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.medicalBlue.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              LucideIcons.chevronRight,
              color: Colors.white,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestsView() {
    final l10n = AppLocalizations.of(context)!;
    final history = ref.watch(testHistoryProvider);
    
    return history.isEmpty
        ? _buildEmptyState()
        : RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_statistics != null) _buildStatisticsCard(),
                  const SizedBox(height: 24),
                  _buildHistoryList(history),
                ],
              ),
            ),
          );
  }

  Widget _buildExercisesView() {
    return FutureBuilder<List<DateTime>>(
      future: _storageService.getExerciseHistory(_selectedProfile),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final exerciseDates = snapshot.data ?? [];
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildExerciseCalendar(exerciseDates),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExerciseCalendar(List<DateTime> exerciseDates) {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final firstDayOfMonth = DateTime(currentMonth.year, currentMonth.month, 1);
    final lastDayOfMonth = DateTime(currentMonth.year, currentMonth.month + 1, 0);
    
    // Get day of week for first day (Monday = 1, Sunday = 7)
    int firstDayWeekday = firstDayOfMonth.weekday;
    // Adjust to start from Monday (1 = Monday, 7 = Sunday)
    int startOffset = firstDayWeekday - 1;
    
    // Create a set of exercise dates for quick lookup
    final exerciseDateSet = exerciseDates.map((date) {
      return DateTime(date.year, date.month, date.day);
    }).toSet();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getMonthName(currentMonth.month, AppLocalizations.of(context)!) + ' ${currentMonth.year}',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              IconButton(
                icon: const Icon(LucideIcons.arrowLeft),
                onPressed: () {
                  // TODO: Navigate to previous month
                },
                color: AppColors.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Weekday headers
          Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              final weekdays = [
                l10n.weekdayMonday,
                l10n.weekdayTuesday,
                l10n.weekdayWednesday,
                l10n.weekdayThursday,
                l10n.weekdayFriday,
                l10n.weekdaySaturday,
                l10n.weekdaySunday,
              ];
              return Row(
                children: weekdays
                    .map((day) => Expanded(
                          child: Center(
                            child: Text(
                              day,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 8),
          // Calendar grid
          ...List.generate(6, (weekIndex) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: List.generate(7, (dayIndex) {
                  final dayNumber = weekIndex * 7 + dayIndex - startOffset + 1;
                  
                  if (dayNumber < 1 || dayNumber > lastDayOfMonth.day) {
                    return const Expanded(child: SizedBox());
                  }
                  
                  final currentDate = DateTime(
                    currentMonth.year,
                    currentMonth.month,
                    dayNumber,
                  );
                  
                  final isToday = currentDate.year == now.year &&
                      currentDate.month == now.month &&
                      currentDate.day == now.day;
                  
                  final hasExercise = exerciseDateSet.contains(currentDate);
                  
                  return Expanded(
                    child: Container(
                      height: 50,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: isToday
                            ? AppColors.medicalBlue.withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: isToday
                            ? Border.all(color: AppColors.medicalBlue, width: 2)
                            : null,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            dayNumber.toString(),
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: isToday
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isToday
                                  ? AppColors.medicalBlue
                                  : AppColors.textPrimary,
                            ),
                          ),
                          if (hasExercise)
                            Positioned(
                              bottom: 2,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: AppColors.successGreen,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  LucideIcons.check,
                                  size: 10,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
          const SizedBox(height: 16),
          // Legend
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: AppColors.successGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.check,
                  size: 10,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.exerciseDaysCompleted,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context)!;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.medicalBluePale,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.clipboardList,
                size: 60,
                color: AppColors.medicalBlue,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.noTestsYet,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.testResultsWillAppearHere,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.go(AppRoutes.home),
              icon: const Icon(LucideIcons.eye),
              label: Text(AppLocalizations.of(context)!.startTest),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.medicalBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCard() {
    final l10n = AppLocalizations.of(context)!;
    final stats = _statistics!;
    final totalTests = stats['totalTests'] as int;
    final averageScore = stats['averageScore'] as double;
    final testsByType = stats['testsByType'] as Map<String, int>;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.medicalBlue, AppColors.medicalTeal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.medicalBlue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.statistics,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  l10n.totalTests,
                  totalTests.toString(),
                  LucideIcons.clipboardCheck,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  l10n.averageScore,
                  '${averageScore.toStringAsFixed(0)}%',
                  LucideIcons.trendingUp,
                ),
              ),
            ],
          ),
          if (testsByType.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(color: Colors.white30),
            const SizedBox(height: 8),
            Text(
              l10n.testTypesByType,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: testsByType.entries.map((entry) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_getTestName(entry.key, l10n)}: ${entry.value}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.white,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(List<TestResult> history) {
    final l10n = AppLocalizations.of(context)!;
    // Group by date
    final groupedHistory = <DateTime, List<TestResult>>{};
    for (final result in history) {
      final date = DateTime(result.dateTime.year, result.dateTime.month, result.dateTime.day);
      groupedHistory.putIfAbsent(date, () => []).add(result);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.history,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ...groupedHistory.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateHeader(entry.key),
              const SizedBox(height: 8),
              ...entry.value.map((result) => _buildHistoryItem(result)),
              const SizedBox(height: 16),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildDateHeader(DateTime date) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    String dateText;
    if (dateOnly == today) {
      dateText = l10n.today;
    } else if (dateOnly == yesterday) {
      dateText = l10n.yesterday;
    } else {
      // Use simple format to avoid locale issues
      final day = date.day;
      final month = _getMonthName(date.month, l10n);
      final year = date.year;
      dateText = '$day $month $year';
    }
    
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        dateText,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildHistoryItem(TestResult result) {
    final l10n = AppLocalizations.of(context)!;
    final color = _getStatusColor(result.percentage);
    final hour = result.dateTime.hour.toString().padLeft(2, '0');
    final minute = result.dateTime.minute.toString().padLeft(2, '0');
    final time = '$hour:$minute';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getTestIcon(result.testType),
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getTestName(result.testType, l10n),
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '%${result.percentage.round()}',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              Text(
                '${result.score}/${result.totalQuestions}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(double percentage) {
    if (percentage == 100) return AppColors.successGreen;
    if (percentage >= 80) return AppColors.medicalBlue;
    if (percentage >= 50) return AppColors.warningYellow;
    return AppColors.errorRed;
  }

  IconData _getTestIcon(String testType) {
    switch (testType) {
      case 'visual_acuity':
        return LucideIcons.eye;
      case 'color_vision':
        return LucideIcons.palette;
      case 'astigmatism':
        return LucideIcons.focus;
      case 'stereopsis':
        return LucideIcons.layers;
      case 'near_vision':
        return LucideIcons.bookOpen;
      case 'macular':
        return LucideIcons.grid;
      case 'peripheral_vision':
        return LucideIcons.scan;
      case 'eye_movement':
        return LucideIcons.move;
      default:
        return LucideIcons.clipboardCheck;
    }
  }

  String _getTestName(String testType, AppLocalizations l10n) {
    switch (testType) {
      case 'visual_acuity':
        return l10n.visualAcuityTitle;
      case 'color_vision':
        return l10n.colorVisionTitle;
      case 'astigmatism':
        return l10n.astigmatismTitle;
      case 'stereopsis':
      case 'binocular_vision':
        return l10n.stereopsisTitle;
      case 'near_vision':
        return l10n.nearVisionTitle;
      case 'macular':
        return l10n.macularTitle;
      case 'peripheral_vision':
        return l10n.peripheralVisionTitle;
      case 'eye_movement':
        return l10n.eyeMovementTitle;
      default:
        return 'Test';
    }
  }

  void _showClearHistoryDialog() {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n.clearHistory,
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        content: Text(
          l10n.confirmClearHistory,
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              l10n.cancel,
              style: GoogleFonts.inter(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _storageService.clearTestHistory();
              await ref.read(testHistoryProvider.notifier).refresh();
              setState(() => _statistics = null);
              if (mounted) {
                final l10n = AppLocalizations.of(context)!;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.success)),
                );
              }
            },
            child: Text(
              l10n.clear,
              style: GoogleFonts.inter(color: AppColors.errorRed),
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month, AppLocalizations l10n) {
    switch (month) {
      case 1:
        return l10n.monthJanuary;
      case 2:
        return l10n.monthFebruary;
      case 3:
        return l10n.monthMarch;
      case 4:
        return l10n.monthApril;
      case 5:
        return l10n.monthMay;
      case 6:
        return l10n.monthJune;
      case 7:
        return l10n.monthJuly;
      case 8:
        return l10n.monthAugust;
      case 9:
        return l10n.monthSeptember;
      case 10:
        return l10n.monthOctober;
      case 11:
        return l10n.monthNovember;
      case 12:
        return l10n.monthDecember;
      default:
        return '';
    }
  }
}
