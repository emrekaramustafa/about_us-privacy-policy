import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:goz_testi/core/theme/app_colors.dart';
import 'package:goz_testi/core/constants/app_strings.dart';
import 'package:goz_testi/core/router/app_router.dart';
import 'package:goz_testi/core/widgets/app_button.dart';
import 'package:goz_testi/core/services/storage_service.dart';
import 'package:goz_testi/core/services/ad_service.dart';
import 'package:goz_testi/core/services/rating_service.dart';
import 'package:goz_testi/features/tests/common/presentation/providers/test_provider.dart';
import 'package:goz_testi/l10n/app_localizations.dart';

class ResultPage extends ConsumerStatefulWidget {
  final String testType;
  final int score;
  final int totalQuestions;
  final Map<String, dynamic>? details;

  const ResultPage({
    super.key,
    required this.testType,
    required this.score,
    required this.totalQuestions,
    this.details,
  });

  @override
  ConsumerState<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends ConsumerState<ResultPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final StorageService _storageService = StorageService();
  final AdService _adService = AdService();
  final RatingService _ratingService = RatingService();
  bool _isSaving = false;
  bool _hasUnlockedDetailedAnalysis = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animationController.forward();
    _saveTestResult();
  }

  Future<void> _saveTestResult() async {
    if (_isSaving) return;
    
    setState(() => _isSaving = true);
    
    try {
      // Create TestResult
      final result = TestResult(
        testType: widget.testType,
        dateTime: DateTime.now(),
        score: widget.score,
        totalQuestions: widget.totalQuestions,
        details: widget.details,
      );
      
      // Save to storage
      await _storageService.saveTestResult(result);
      
      // Update provider
      await ref.read(testHistoryProvider.notifier).refresh();
      
      // Update completed tests count
      final history = ref.read(testHistoryProvider);
      final uniqueTests = history.map((r) => r.testType).toSet().length;
      ref.read(completedTestsProvider.notifier).state = uniqueTests;
      
      // Increment daily test count
      await _storageService.incrementDailyTestCount();
      
      // Check if soft gate should be shown
      final dailyCount = await _storageService.getDailyTestCount();
      final isPremium = ref.read(isPremiumProvider);
      
      // Refresh daily count and remaining credits provider
      ref.invalidate(dailyTestCountProvider);
      ref.invalidate(remainingTestCreditsProvider);
      
      // Show rating dialog for color vision test (if not already rated)
      if (widget.testType == 'color_vision' && mounted) {
        Future.delayed(const Duration(milliseconds: 1500), () async {
          if (mounted) {
            await _ratingService.showRatingDialog(context);
          }
        });
      }
      
      // Show soft gate if needed (after result screen is shown)
      // Show after 3 free tests are completed (then ads can be watched)
      if (dailyCount >= 3 && dailyCount < 21 && !isPremium && mounted) {
        // Wait a bit for result screen to show, then navigate to soft gate
        // Use pushReplacement to replace result screen with soft gate
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            context.pushReplacement(AppRoutes.softGate);
          }
        });
      }
    } catch (e) {
      // Silently fail - don't interrupt user experience
      debugPrint('Error saving test result: $e');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getStatusColor(int percentage) {
    if (percentage == 100) return AppColors.successGreen;
    if (percentage >= 80) return AppColors.medicalBlue;
    if (percentage >= 50) return AppColors.warningYellow;
    return AppColors.errorRed;
  }

  String _getStatusText(int percentage, {bool isColorVision = false}) {
    final l10n = AppLocalizations.of(context)!;
    if (isColorVision) {
      if (percentage == 100) return l10n.resultStatusColorPassed;
      return l10n.resultStatusColorSuspicion;
    }
    if (percentage == 100) return l10n.resultStatusPerfect;
    if (percentage >= 90) return l10n.resultStatusVeryGood;
    if (percentage >= 80) return l10n.resultStatusGood;
    if (percentage >= 60) return l10n.resultStatusSeeDoctor;
    if (percentage >= 40) return l10n.resultStatusNeedGlasses;
    return l10n.resultStatusUrgent;
  }
  
  String _getRecommendationText(int percentage, {bool isColorVision = false}) {
    final l10n = AppLocalizations.of(context)!;
    if (isColorVision) {
      if (percentage == 100) {
        return l10n.resultRecommendationColorNormal;
      }
      return l10n.resultRecommendationColorSuspicion;
    }
    return l10n.resultRecommendationGeneral;
  }

  void _goToNextTest() {
    if (widget.testType == 'visual_acuity') {
      context.pushReplacement(AppRoutes.colorVision);
    } else if (widget.testType == 'color_vision') {
      context.pushReplacement(AppRoutes.astigmatism);
    } else if (widget.testType == 'astigmatism') {
      context.pushReplacement(AppRoutes.stereopsis);
    } else if (widget.testType == 'stereopsis' || widget.testType == 'binocular_vision') {
      context.pushReplacement(AppRoutes.nearVision);
    } else if (widget.testType == 'near_vision') {
      context.pushReplacement(AppRoutes.macular);
    } else if (widget.testType == 'macular') {
      context.pushReplacement(AppRoutes.peripheralVision);
    } else if (widget.testType == 'peripheral_vision') {
      context.pushReplacement(AppRoutes.eyeMovement);
    } else {
      context.go(AppRoutes.home);
    }
  }
  
  String? _getNextTestName(AppLocalizations l10n) {
    if (widget.testType == 'visual_acuity') return l10n.colorVisionTitle;
    if (widget.testType == 'color_vision') return l10n.astigmatismTitle;
    if (widget.testType == 'astigmatism') return l10n.stereopsisTitle;
    if (widget.testType == 'stereopsis' || widget.testType == 'binocular_vision') return l10n.nearVisionTitle;
    if (widget.testType == 'near_vision') return l10n.macularTitle;
    if (widget.testType == 'macular') return l10n.peripheralVisionTitle;
    if (widget.testType == 'peripheral_vision') return l10n.eyeMovementTitle;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDualEyeTest = widget.testType == 'visual_acuity';
    final isColorVision = widget.testType == 'color_vision';
    final nextTestName = _getNextTestName(l10n);
    final percentage = widget.details != null && widget.details!['percentage'] != null
        ? widget.details!['percentage'] as int
        : ((widget.score / widget.totalQuestions) * 100).round();

    return Scaffold(
      backgroundColor: AppColors.cleanWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              
              Text(
                l10n.resultsTitle,
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 8),
              
              Text(
                isDualEyeTest 
                    ? l10n.resultSubtitleVisualAcuity
                    : isColorVision 
                        ? l10n.resultSubtitleColorVision
                        : l10n.resultSubtitleGeneral,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 40),

              if (isDualEyeTest) ...[
                Row(
                  children: [
                    Expanded(
                      child: _buildPercentageCard(
                        l10n.leftEyeLabel,
                        widget.details!['leftEyeScore'] as int,
                        widget.details!['leftEyeAcuity'] as String,
                        delay: 0.0,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildPercentageCard(
                        l10n.rightEyeLabel,
                        widget.details!['rightEyeScore'] as int,
                        widget.details!['rightEyeAcuity'] as String,
                        delay: 0.2,
                      ),
                    ),
                  ],
                ),
              ] else ...[
                _buildSingleResultCard(percentage, isColorVision: isColorVision),
              ],
              
              const SizedBox(height: 32),
              
              // Recommendation Box
              FadeTransition(
                opacity: CurvedAnimation(
                  parent: _animationController,
                  curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
                ),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isColorVision && percentage < 100
                          ? AppColors.errorRed.withOpacity(0.3)
                          : AppColors.borderLight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isColorVision && percentage < 100
                                  ? AppColors.errorRedPale
                                  : AppColors.infoBluePale,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              isColorVision && percentage < 100
                                  ? LucideIcons.alertCircle
                                  : LucideIcons.stethoscope,
                              color: isColorVision && percentage < 100
                                  ? AppColors.errorRed
                                  : AppColors.infoBlue,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isColorVision && percentage < 100
                                      ? l10n.resultImportantWarning
                                      : l10n.resultRecommendation,
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _getRecommendationText(percentage, isColorVision: isColorVision),
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Detailed Analysis Section (Locked for free users)
              _buildDetailedAnalysisSection(percentage, isColorVision),
              
              const SizedBox(height: 40),
              
              // NEXT TEST BUTTON (Primary Action)
              // Only show if user hasn't reached daily limit or is premium
              Consumer(
                builder: (context, ref, child) {
                  final isPremium = ref.watch(isPremiumProvider);
                  final dailyCountAsync = ref.watch(dailyTestCountProvider);
                  
                  return dailyCountAsync.when(
                    data: (count) {
                      // Hide next test button if limit reached and not premium
                      if (count >= 3 && !isPremium) {
                        return const SizedBox.shrink();
                      }
                      
                      if (nextTestName != null) {
                        return Column(
                          children: [
                            AppButton(
                              text: '${l10n.nextTest}: $nextTestName',
                              icon: LucideIcons.arrowRight,
                              onPressed: _goToNextTest,
                              width: double.infinity,
                              backgroundColor: AppColors.medicalBlue,
                            ),
                            const SizedBox(height: 16),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => nextTestName != null
                        ? Column(
                            children: [
                              AppButton(
                                text: '${l10n.nextTest}: $nextTestName',
                                icon: LucideIcons.arrowRight,
                                onPressed: _goToNextTest,
                                width: double.infinity,
                                backgroundColor: AppColors.medicalBlue,
                              ),
                              const SizedBox(height: 16),
                            ],
                          )
                        : const SizedBox.shrink(),
                  );
                },
              ),
              
              // SECONDARY ACTIONS
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: l10n.retakeTest,
                      icon: LucideIcons.refreshCw,
                      isOutlined: true,
                      onPressed: () {
                        if (widget.testType == 'visual_acuity') {
                          context.pushReplacement(AppRoutes.visualAcuity);
                        } else if (widget.testType == 'color_vision') {
                          context.pushReplacement(AppRoutes.colorVision);
                        } else if (widget.testType == 'astigmatism') {
                          context.pushReplacement(AppRoutes.astigmatism);
                        } else if (widget.testType == 'stereopsis' || widget.testType == 'binocular_vision') {
                          context.pushReplacement(AppRoutes.stereopsis);
                        } else if (widget.testType == 'near_vision') {
                          context.pushReplacement(AppRoutes.nearVision);
                        } else if (widget.testType == 'macular') {
                          context.pushReplacement(AppRoutes.macular);
                        } else if (widget.testType == 'peripheral_vision') {
                          context.pushReplacement(AppRoutes.peripheralVision);
                        } else if (widget.testType == 'eye_movement') {
                          context.pushReplacement(AppRoutes.eyeMovement);
                        } else {
                          context.go(AppRoutes.home);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      text: l10n.resultHomeMenu,
                      icon: LucideIcons.home,
                      isOutlined: true,
                      onPressed: () => context.go(AppRoutes.home),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Medical Disclaimer Footer
              FadeTransition(
                opacity: CurvedAnimation(
                  parent: _animationController,
                  curve: const Interval(0.8, 1.0),
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.warningYellow.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.warningYellow.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        LucideIcons.alertTriangle,
                        size: 20,
                        color: AppColors.warningYellow,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.resultMedicalDisclaimer,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPercentageCard(String title, int score, String secondaryInfo, {required double delay}) {
    final l10n = AppLocalizations.of(context)!;
    final color = _getStatusColor(score);
    
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _animationController,
        curve: Interval(delay, 1.0, curve: Curves.easeOut),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: Interval(delay, 1.0, curve: Curves.easeOut),
        )),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.5), width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      value: score / 100,
                      strokeWidth: 8,
                      backgroundColor: color.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Text(
                    '%$score',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              Text(
                _getStatusText(score),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 4),
              
              Text(
                l10n.resultSnellen(secondaryInfo),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSingleResultCard(int percentage, {bool isColorVision = false}) {
    final l10n = AppLocalizations.of(context)!;
    final color = _getStatusColor(percentage);
    
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOut),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.0, 1.0, curve: Curves.easeOut),
        )),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.5), width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: percentage / 100,
                      strokeWidth: 10,
                      backgroundColor: color.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Text(
                    '%$percentage',
                    style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              Text(
                _getStatusText(percentage, isColorVision: isColorVision),
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
              
              if (isColorVision) ...[
                const SizedBox(height: 8),
                Text(
                  l10n.resultCorrectAnswers(
                    widget.details!['correctAnswers'] ?? widget.score,
                    widget.details!['totalPlates'] ?? widget.totalQuestions,
                  ),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailedAnalysisSection(int percentage, bool isColorVision) {
    final l10n = AppLocalizations.of(context)!;
    final isPremium = ref.watch(isPremiumProvider);
    final canViewDetailed = isPremium || _hasUnlockedDetailedAnalysis;
    
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: canViewDetailed 
                ? AppColors.medicalBlue.withOpacity(0.3)
                : AppColors.borderLight,
          ),
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
              children: [
                Icon(
                  LucideIcons.barChart3,
                  color: canViewDetailed 
                      ? AppColors.medicalBlue
                      : AppColors.textSecondary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    l10n.resultDetailedAnalysis,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isPremium) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: AppColors.premiumGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          LucideIcons.crown,
                          size: 12,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Premium',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            if (canViewDetailed) ...[
              // Show button to navigate to detailed analysis page
              GestureDetector(
                onTap: () {
                  context.push(
                    AppRoutes.detailedAnalysis,
                    extra: {
                      'testType': widget.testType,
                      'score': widget.score,
                      'totalQuestions': widget.totalQuestions,
                      'details': widget.details,
                    },
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.medicalBlue,
                        AppColors.medicalTeal,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        LucideIcons.barChart3,
                        size: 20,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          l10n.resultViewDetailedAnalysis,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        LucideIcons.arrowRight,
                        size: 20,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // Show locked state
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.borderLight.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      LucideIcons.lock,
                      size: 32,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.resultDetailedAnalysisLocked,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _watchAdForDetailedAnalysis(),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.medicalBlue,
                                    AppColors.medicalTeal,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    LucideIcons.play,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    l10n.resultWatchAd,
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => context.push(AppRoutes.paywall),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                gradient: AppColors.premiumGradient,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    LucideIcons.crown,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Premium',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedAnalysisContent(int percentage, bool isColorVision) {
    // Get test history for comparison
    final history = ref.watch(testHistoryProvider);
    final sameTypeTests = history.where((r) => r.testType == widget.testType).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (sameTypeTests.length > 1) ...[
          // Comparison with previous tests
          _buildComparisonSection(sameTypeTests, percentage),
          const SizedBox(height: 16),
        ],
        // Trend analysis
        _buildTrendSection(sameTypeTests),
        const SizedBox(height: 16),
        // Detailed recommendations
        _buildDetailedRecommendations(percentage, isColorVision),
      ],
    );
  }

  Widget _buildComparisonSection(List<TestResult> tests, int currentPercentage) {
    final l10n = AppLocalizations.of(context)!;
    if (tests.length < 2) return const SizedBox.shrink();
    
    final previousTest = tests[1]; // Second most recent
    final previousPercentage = previousTest.percentage.round();
    final difference = currentPercentage - previousPercentage;
    final isImproving = difference > 0;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.infoBluePale,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            isImproving ? LucideIcons.trendingUp : LucideIcons.trendingDown,
            color: isImproving ? AppColors.successGreen : AppColors.errorRed,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.resultComparisonPrevious,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.resultComparisonText(previousPercentage, currentPercentage, '${difference > 0 ? '+' : ''}$difference'),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendSection(List<TestResult> tests) {
    final l10n = AppLocalizations.of(context)!;
    if (tests.length < 3) return const SizedBox.shrink();
    
    // Get last 7 tests
    final recentTests = tests.take(7).toList();
    final average = recentTests
        .map((t) => t.percentage)
        .reduce((a, b) => a + b) / recentTests.length;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.medicalTeal.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                LucideIcons.activity,
                size: 20,
                color: AppColors.medicalTeal,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.resultAverageLast7,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '%${average.round()}',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.medicalTeal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedRecommendations(int percentage, bool isColorVision) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warningYellow.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                LucideIcons.lightbulb,
                size: 20,
                color: AppColors.warningYellow,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.resultDetailedRecommendations,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _getDetailedRecommendationText(percentage, isColorVision),
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  String _getDetailedRecommendationText(int percentage, bool isColorVision) {
    final l10n = AppLocalizations.of(context)!;
    if (isColorVision) {
      if (percentage == 100) {
        return l10n.resultDetailedColorPerfect;
      } else if (percentage >= 80) {
        return l10n.resultDetailedColorNormal;
      } else {
        return l10n.resultDetailedColorDeficiency;
      }
    } else {
      if (percentage >= 90) {
        return l10n.resultDetailedAcuityVeryGood;
      } else if (percentage >= 70) {
        return l10n.resultDetailedAcuityModerate;
      } else {
        return l10n.resultDetailedAcuityLow;
      }
    }
  }

  Future<void> _watchAdForDetailedAnalysis() async {
    if (!_adService.isRewardedAdReady) {
      await _adService.loadRewardedAd();
      if (!_adService.isRewardedAdReady) {
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.adLoadFailed),
              backgroundColor: AppColors.errorRed,
            ),
          );
        }
        return;
      }
    }

    final success = await _adService.showRewardedAd(
      context: context,
      onRewarded: () {
        setState(() {
          _hasUnlockedDetailedAnalysis = true;
        });
        if (mounted) {
          // Navigate to detailed analysis page
          context.push(
            AppRoutes.detailedAnalysis,
            extra: {
              'testType': widget.testType,
              'score': widget.score,
              'totalQuestions': widget.totalQuestions,
              'details': widget.details,
            },
          );
        }
      },
    );

    if (!success && mounted) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.adFailed),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }
}
