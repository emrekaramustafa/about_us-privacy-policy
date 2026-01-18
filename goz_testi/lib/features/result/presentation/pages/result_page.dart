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
import 'package:goz_testi/features/tests/common/presentation/providers/test_provider.dart';

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
      
      // Refresh daily count provider
      ref.invalidate(dailyTestCountProvider);
      
      // Show soft gate if needed (after result screen is shown)
      if (dailyCount >= 3 && !isPremium && mounted) {
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
    if (isColorVision) {
      if (percentage == 100) return 'Testi Başarıyla Geçtiniz';
      return 'Renk Körlüğü Şüphesi';
    }
    if (percentage == 100) return 'Mükemmel Görüş';
    if (percentage >= 90) return 'Çok İyi Görüş';
    if (percentage >= 80) return 'İyi Görüş';
    if (percentage >= 60) return 'Göz Doktoruna Görünmelisin';
    if (percentage >= 40) return 'Lens/Gözlük Şart';
    return 'Hemen Randevu Al';
  }
  
  String _getRecommendationText(int percentage, {bool isColorVision = false}) {
    if (isColorVision) {
      if (percentage == 100) {
        return 'Renk görüşünüz normal görünüyor. Düzenli kontroller için göz doktorunuza danışın.';
      }
      return 'Renk körlüğü şüphesi var. Lütfen doktorunuza görünün.';
    }
    return 'Bu sonuçlar bilgilendirme amaçlıdır. Kesin tanı için göz doktoruna başvurun.';
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
  
  String? _getNextTestName() {
    if (widget.testType == 'visual_acuity') return AppStrings.colorVisionTitle;
    if (widget.testType == 'color_vision') return AppStrings.astigmatismTitle;
    if (widget.testType == 'astigmatism') return AppStrings.stereopsisTitle;
    if (widget.testType == 'stereopsis' || widget.testType == 'binocular_vision') return AppStrings.nearVisionTitle;
    if (widget.testType == 'near_vision') return AppStrings.macularTitle;
    if (widget.testType == 'macular') return AppStrings.peripheralVisionTitle;
    if (widget.testType == 'peripheral_vision') return AppStrings.eyeMovementTitle;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isDualEyeTest = widget.testType == 'visual_acuity';
    final isColorVision = widget.testType == 'color_vision';
    final nextTestName = _getNextTestName();
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
                AppStrings.resultsTitle,
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
                    ? 'Görme Keskinliği Analizi' 
                    : isColorVision 
                        ? 'Renk Körlüğü Testi Sonucu'
                        : 'Test Sonucu',
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
                        'Sol Göz',
                        widget.details!['leftEyeScore'] as int,
                        widget.details!['leftEyeAcuity'] as String,
                        delay: 0.0,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildPercentageCard(
                        'Sağ Göz',
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
                                      ? 'Önemli Uyarı'
                                      : 'Öneri',
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
                              text: '${AppStrings.nextTest}: $nextTestName',
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
                                text: '${AppStrings.nextTest}: $nextTestName',
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
                      text: AppStrings.retakeTest,
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
                      text: 'Ana Menü',
                      icon: LucideIcons.home,
                      isOutlined: true,
                      onPressed: () => context.go(AppRoutes.home),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPercentageCard(String title, int score, String secondaryInfo, {required double delay}) {
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
                'Snellen: $secondaryInfo',
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
                  '${widget.details!['correctAnswers'] ?? widget.score} / ${widget.details!['totalPlates'] ?? widget.totalQuestions} Doğru',
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
                Text(
                  'Detaylı Analiz',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (isPremium) ...[
                  const Spacer(),
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
                      Text(
                        'Detaylı Analizi Görüntüle',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
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
                      'Detaylı analizi görmek için',
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
                                    'Reklam İzle',
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
                  'Önceki Test ile Karşılaştırma',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Önceki: %$previousPercentage → Şimdi: %$currentPercentage '
                  '(${difference > 0 ? '+' : ''}$difference%)',
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
                'Son 7 Test Ortalaması',
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
                'Detaylı Öneriler',
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
    if (isColorVision) {
      if (percentage == 100) {
        return 'Mükemmel renk görüşüne sahipsiniz. Düzenli kontrollerle bu durumu koruyabilirsiniz.';
      } else if (percentage >= 80) {
        return 'Renk görüşünüz normal seviyede. Ancak bazı renkleri ayırt etmekte zorlanıyorsanız göz doktoruna danışmanız önerilir.';
      } else {
        return 'Renk görüşünde eksiklik olabilir. Mutlaka bir göz doktoruna başvurun ve detaylı muayene yaptırın.';
      }
    } else {
      if (percentage >= 90) {
        return 'Görme keskinliğiniz çok iyi seviyede. Düzenli göz muayeneleri ile bu durumu koruyabilirsiniz.';
      } else if (percentage >= 70) {
        return 'Görme keskinliğiniz orta seviyede. Göz doktoruna danışarak daha detaylı değerlendirme yaptırmanız önerilir.';
      } else {
        return 'Görme keskinliğiniz düşük seviyede. Acilen bir göz doktoruna başvurmanız ve muayene olmanız gerekmektedir.';
      }
    }
  }

  Future<void> _watchAdForDetailedAnalysis() async {
    if (!_adService.isRewardedAdReady) {
      await _adService.loadRewardedAd();
      if (!_adService.isRewardedAdReady) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reklam yüklenemedi. Lütfen daha sonra tekrar deneyin.'),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reklam gösterilemedi. Lütfen tekrar deneyin.'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }
}
