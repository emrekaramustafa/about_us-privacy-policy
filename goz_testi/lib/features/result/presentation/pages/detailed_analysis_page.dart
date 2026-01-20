import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:goz_testi/core/theme/app_colors.dart';
import 'package:goz_testi/core/widgets/scroll_indicator.dart';
import 'package:goz_testi/l10n/app_localizations.dart';

/// Detailed Analysis Page
/// 
/// Shows comprehensive analysis for each test type including:
/// - Problem descriptions
/// - Possible consequences
/// - Treatment options
/// - Recommendations
class DetailedAnalysisPage extends ConsumerStatefulWidget {
  final String testType;
  final int score;
  final int totalQuestions;
  final Map<String, dynamic>? details;

  const DetailedAnalysisPage({
    super.key,
    required this.testType,
    required this.score,
    required this.totalQuestions,
    this.details,
  });

  @override
  ConsumerState<DetailedAnalysisPage> createState() => _DetailedAnalysisPageState();
}

class _DetailedAnalysisPageState extends ConsumerState<DetailedAnalysisPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final percentage = widget.details != null && widget.details!['percentage'] != null
        ? widget.details!['percentage'] as int
        : ((widget.score / widget.totalQuestions) * 100).round();

    return Scaffold(
      backgroundColor: AppColors.cleanWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            LucideIcons.arrowLeft,
            color: AppColors.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.detailedAnalysisTitle,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(24),
            child: FadeTransition(
              opacity: _animationController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTestHeader(percentage),
                  const SizedBox(height: 32),
                  _buildAnalysisContent(percentage),
                ],
              ),
            ),
          ),
          ScrollIndicator(scrollController: _scrollController),
        ],
      ),
    );
  }

  Widget _buildTestHeader(int percentage) {
    final l10n = AppLocalizations.of(context)!;
    String testName = _getTestName(l10n);
    IconData testIcon = _getTestIcon();
    Color testColor = _getTestColor();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            testColor.withOpacity(0.1),
            testColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: testColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: testColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              testIcon,
              size: 32,
              color: testColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  testName,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.detailedAnalysisResult(percentage),
                  style: GoogleFonts.inter(
                    fontSize: 14,
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

  Widget _buildAnalysisContent(int percentage) {
    final l10n = AppLocalizations.of(context)!;
    switch (widget.testType) {
      case 'visual_acuity':
        return _buildVisualAcuityAnalysis(percentage, l10n);
      case 'color_vision':
        return _buildColorVisionAnalysis(percentage, l10n);
      case 'astigmatism':
        return _buildAstigmatismAnalysis(percentage, l10n);
      case 'stereopsis':
      case 'binocular_vision':
        return _buildStereopsisAnalysis(percentage, l10n);
      case 'near_vision':
        return _buildNearVisionAnalysis(percentage, l10n);
      case 'macular':
        return _buildMacularAnalysis(percentage, l10n);
      case 'peripheral_vision':
        return _buildPeripheralVisionAnalysis(percentage, l10n);
      case 'eye_movement':
        return _buildEyeMovementAnalysis(percentage, l10n);
      default:
        return _buildGenericAnalysis(percentage, l10n);
    }
  }

  // Visual Acuity Analysis
  Widget _buildVisualAcuityAnalysis(int percentage, AppLocalizations l10n) {
    final isProblem = percentage < 70;
    final severity = percentage >= 90
        ? l10n.detailedAnalysisSeverityNormal
        : percentage >= 70
            ? l10n.detailedAnalysisSeverityMild
            : percentage >= 50
                ? l10n.detailedAnalysisSeverityModerate
                : l10n.detailedAnalysisSeveritySevere;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSection(
          title: l10n.detailedAnalysisVisualAcuityAssessment,
          icon: LucideIcons.eye,
          color: AppColors.medicalBlue,
          children: [
            _buildInfoCard(
              l10n.detailedAnalysisCurrentStatus,
              l10n.detailedAnalysisVisualAcuityStatus(percentage, severity),
              LucideIcons.info,
              AppColors.medicalBlue,
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (isProblem) ...[
          _buildSection(
            title: l10n.detailedAnalysisPossibleProblems,
            icon: LucideIcons.alertCircle,
            color: AppColors.errorRed,
            children: [
              _buildProblemCard(
                l10n.detailedAnalysisMyopia,
                l10n.detailedAnalysisMyopiaDesc,
                [
                  l10n.detailedAnalysisMyopiaSymptom1,
                  l10n.detailedAnalysisMyopiaSymptom2,
                  l10n.detailedAnalysisMyopiaSymptom3,
                  l10n.detailedAnalysisMyopiaSymptom4,
                ],
              ),
              const SizedBox(height: 12),
              _buildProblemCard(
                l10n.detailedAnalysisHypermetropia,
                l10n.detailedAnalysisHypermetropiaDesc,
                [
                  l10n.detailedAnalysisHypermetropiaSymptom1,
                  l10n.detailedAnalysisHypermetropiaSymptom2,
                  l10n.detailedAnalysisHypermetropiaSymptom3,
                  l10n.detailedAnalysisHypermetropiaSymptom4,
                ],
              ),
              const SizedBox(height: 12),
              _buildProblemCard(
                l10n.detailedAnalysisPresbyopia,
                l10n.detailedAnalysisPresbyopiaDesc,
                [
                  l10n.detailedAnalysisPresbyopiaSymptom1,
                  l10n.detailedAnalysisPresbyopiaSymptom2,
                  l10n.detailedAnalysisPresbyopiaSymptom3,
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: l10n.detailedAnalysisPossibleConsequences,
            icon: LucideIcons.trendingDown,
            color: AppColors.warningYellow,
            children: [
              _buildConsequenceCard(
                l10n.detailedAnalysisDailyLife,
                [
                  l10n.detailedAnalysisDailyLifeConsequence1,
                  l10n.detailedAnalysisDailyLifeConsequence2,
                  l10n.detailedAnalysisDailyLifeConsequence3,
                  l10n.detailedAnalysisDailyLifeConsequence4,
                ],
              ),
              const SizedBox(height: 12),
              _buildConsequenceCard(
                l10n.detailedAnalysisWorkLife,
                [
                  l10n.detailedAnalysisWorkLifeConsequence1,
                  l10n.detailedAnalysisWorkLifeConsequence2,
                  l10n.detailedAnalysisWorkLifeConsequence3,
                  l10n.detailedAnalysisWorkLifeConsequence4,
                ],
              ),
              const SizedBox(height: 12),
              _buildConsequenceCard(
                l10n.detailedAnalysisHealth,
                [
                  l10n.detailedAnalysisHealthConsequence1,
                  l10n.detailedAnalysisHealthConsequence2,
                  l10n.detailedAnalysisHealthConsequence3,
                  l10n.detailedAnalysisHealthConsequence4,
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
        _buildSection(
          title: l10n.detailedAnalysisTreatmentOptions,
          icon: LucideIcons.heart,
          color: AppColors.successGreen,
          children: [
            _buildSolutionCard(
              l10n.detailedAnalysisSolutionGlasses,
              l10n.detailedAnalysisSolutionGlassesDesc,
              LucideIcons.eye,
            ),
            const SizedBox(height: 12),
            _buildSolutionCard(
              l10n.detailedAnalysisSolutionContacts,
              l10n.detailedAnalysisSolutionContactsDesc,
              LucideIcons.circle,
            ),
            const SizedBox(height: 12),
            _buildSolutionCard(
              l10n.detailedAnalysisSolutionLaser,
              l10n.detailedAnalysisSolutionLaserDesc,
              LucideIcons.zap,
            ),
            const SizedBox(height: 12),
            _buildSolutionCard(
              l10n.detailedAnalysisSolutionExercises,
              l10n.detailedAnalysisSolutionExercisesDesc,
              LucideIcons.activity,
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildWarningCard(l10n),
      ],
    );
  }

  // Color Vision Analysis
  Widget _buildColorVisionAnalysis(int percentage, AppLocalizations l10n) {
    final hasProblem = percentage < 100;
    final severity = percentage >= 90
        ? l10n.detailedAnalysisSeverityMildShort
        : percentage >= 70
            ? l10n.detailedAnalysisSeverityModerateShort
            : l10n.detailedAnalysisSeveritySevereShort;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSection(
          title: l10n.detailedAnalysisColorVisionAssessment,
          icon: LucideIcons.palette,
          color: AppColors.medicalTeal,
          children: [
            _buildInfoCard(
              l10n.detailedAnalysisCurrentStatus,
              hasProblem
                  ? l10n.detailedAnalysisColorVisionDeficiency(severity)
                  : l10n.detailedAnalysisColorVisionNormal,
              LucideIcons.info,
              AppColors.medicalTeal,
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (hasProblem) ...[
          _buildSection(
            title: l10n.detailedAnalysisColorBlindnessTypes,
            icon: LucideIcons.layers,
            color: AppColors.premiumGold,
            children: [
              _buildColorBlindnessTypeCard(
                l10n.detailedAnalysisDeuteranopia,
                l10n.detailedAnalysisDeuteranopiaDesc,
                l10n.detailedAnalysisDeuteranopiaSymptom,
                AppColors.successGreen,
              ),
              const SizedBox(height: 12),
              _buildColorBlindnessTypeCard(
                l10n.detailedAnalysisProtanopia,
                l10n.detailedAnalysisProtanopiaDesc,
                l10n.detailedAnalysisProtanopiaSymptom,
                AppColors.errorRed,
              ),
              const SizedBox(height: 12),
              _buildColorBlindnessTypeCard(
                l10n.detailedAnalysisTritanopia,
                l10n.detailedAnalysisTritanopiaDesc,
                l10n.detailedAnalysisTritanopiaSymptom,
                AppColors.medicalBlue,
              ),
              const SizedBox(height: 12),
              _buildColorBlindnessTypeCard(
                l10n.detailedAnalysisAchromatopsia,
                l10n.detailedAnalysisAchromatopsiaDesc,
                l10n.detailedAnalysisAchromatopsiaSymptom,
                AppColors.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: l10n.detailedAnalysisPossibleConsequences,
            icon: LucideIcons.alertTriangle,
            color: AppColors.warningYellow,
            children: [
              _buildConsequenceCard(
                l10n.detailedAnalysisDailyLife,
                [
                  l10n.detailedAnalysisColorDailyLife1,
                  l10n.detailedAnalysisColorDailyLife2,
                  l10n.detailedAnalysisColorDailyLife3,
                  l10n.detailedAnalysisColorDailyLife4,
                ],
              ),
              const SizedBox(height: 12),
              _buildConsequenceCard(
                l10n.detailedAnalysisWorkLife,
                [
                  l10n.detailedAnalysisColorWorkLife1,
                  l10n.detailedAnalysisColorWorkLife2,
                  l10n.detailedAnalysisColorWorkLife3,
                  l10n.detailedAnalysisColorWorkLife4,
                ],
              ),
              const SizedBox(height: 12),
              _buildConsequenceCard(
                l10n.detailedAnalysisEducation,
                [
                  l10n.detailedAnalysisColorEducation1,
                  l10n.detailedAnalysisColorEducation2,
                  l10n.detailedAnalysisColorEducation3,
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
        _buildSection(
          title: l10n.detailedAnalysisManagement,
          icon: LucideIcons.lifeBuoy,
          color: AppColors.successGreen,
          children: [
            _buildSolutionCard(
              l10n.detailedAnalysisColorSolutionApps,
              l10n.detailedAnalysisColorSolutionAppsDesc,
              LucideIcons.smartphone,
            ),
            const SizedBox(height: 12),
            _buildSolutionCard(
              l10n.detailedAnalysisColorSolutionGlasses,
              l10n.detailedAnalysisColorSolutionGlassesDesc,
              LucideIcons.eye,
            ),
            const SizedBox(height: 12),
            _buildSolutionCard(
              l10n.detailedAnalysisColorSolutionCareer,
              l10n.detailedAnalysisColorSolutionCareerDesc,
              LucideIcons.briefcase,
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildInfoCard(
          l10n.detailedAnalysisColorImportantNote,
          l10n.detailedAnalysisColorImportantNoteText,
          LucideIcons.info,
          AppColors.medicalTeal,
        ),
        const SizedBox(height: 24),
        _buildWarningCard(l10n),
      ],
    );
  }

  // Astigmatism Analysis
  Widget _buildAstigmatismAnalysis(int percentage, AppLocalizations l10n) {
    final hasProblem = percentage < 80;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSection(
          title: l10n.detailedAnalysisAstigmatismAssessment,
          icon: LucideIcons.focus,
          color: AppColors.premiumGold,
          children: [
            _buildInfoCard(
              l10n.detailedAnalysisCurrentStatus,
              hasProblem
                  ? l10n.detailedAnalysisAstigmatismDetected
                  : l10n.detailedAnalysisAstigmatismNormal,
              LucideIcons.info,
              AppColors.premiumGold,
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (hasProblem) ...[
          _buildSection(
            title: l10n.detailedAnalysisAstigmatismTypes,
            icon: LucideIcons.layers,
            color: AppColors.medicalBlue,
            children: [
              _buildProblemCard(
                l10n.detailedAnalysisCornealAstigmatism,
                l10n.detailedAnalysisCornealAstigmatismDesc,
                [
                  l10n.detailedAnalysisCornealAstigmatismSymptom1,
                  l10n.detailedAnalysisCornealAstigmatismSymptom2,
                  l10n.detailedAnalysisCornealAstigmatismSymptom3,
                ],
              ),
              const SizedBox(height: 12),
              _buildProblemCard(
                l10n.detailedAnalysisLenticularAstigmatism,
                l10n.detailedAnalysisLenticularAstigmatismDesc,
                [
                  l10n.detailedAnalysisLenticularAstigmatismSymptom1,
                  l10n.detailedAnalysisLenticularAstigmatismSymptom2,
                  l10n.detailedAnalysisLenticularAstigmatismSymptom3,
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: l10n.detailedAnalysisAstigmatismConsequences,
            icon: LucideIcons.alertCircle,
            color: AppColors.warningYellow,
            children: [
              _buildConsequenceCard(
                l10n.detailedAnalysisAstigmatismVisionQuality,
                [
                  l10n.detailedAnalysisAstigmatismVisionQuality1,
                  l10n.detailedAnalysisAstigmatismVisionQuality2,
                  l10n.detailedAnalysisAstigmatismVisionQuality3,
                  l10n.detailedAnalysisAstigmatismVisionQuality4,
                ],
              ),
              const SizedBox(height: 12),
              _buildConsequenceCard(
                l10n.detailedAnalysisDailyLife,
                [
                  l10n.detailedAnalysisAstigmatismDailyLife1,
                  l10n.detailedAnalysisAstigmatismDailyLife2,
                  l10n.detailedAnalysisAstigmatismDailyLife3,
                  l10n.detailedAnalysisAstigmatismDailyLife4,
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: l10n.detailedAnalysisTreatmentOptions,
            icon: LucideIcons.heart,
            color: AppColors.successGreen,
            children: [
              _buildSolutionCard(
                l10n.detailedAnalysisAstigmatismSolutionCylindrical,
                l10n.detailedAnalysisAstigmatismSolutionCylindricalDesc,
                LucideIcons.eye,
              ),
              const SizedBox(height: 12),
              _buildSolutionCard(
                l10n.detailedAnalysisAstigmatismSolutionToric,
                l10n.detailedAnalysisAstigmatismSolutionToricDesc,
                LucideIcons.circle,
              ),
              const SizedBox(height: 12),
              _buildSolutionCard(
                l10n.detailedAnalysisAstigmatismSolutionLaser,
                l10n.detailedAnalysisAstigmatismSolutionLaserDesc,
                LucideIcons.zap,
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
        _buildWarningCard(l10n),
      ],
    );
  }

  // Other test analyses (simplified versions)
  Widget _buildStereopsisAnalysis(int percentage, AppLocalizations l10n) {
    return _buildGenericTestAnalysis(
      l10n.detailedAnalysisVergenceTest,
      percentage,
      l10n.detailedAnalysisVergenceTestDesc,
      l10n.detailedAnalysisVergenceTestConsequence,
      l10n,
    );
  }

  Widget _buildNearVisionAnalysis(int percentage, AppLocalizations l10n) {
    return _buildGenericTestAnalysis(
      l10n.detailedAnalysisNearVisionTest,
      percentage,
      l10n.detailedAnalysisNearVisionTestDesc,
      l10n.detailedAnalysisNearVisionTestConsequence,
      l10n,
    );
  }

  Widget _buildMacularAnalysis(int percentage, AppLocalizations l10n) {
    return _buildGenericTestAnalysis(
      l10n.detailedAnalysisMacularTest,
      percentage,
      l10n.detailedAnalysisMacularTestDesc,
      l10n.detailedAnalysisMacularTestConsequence,
      l10n,
    );
  }

  Widget _buildPeripheralVisionAnalysis(int percentage, AppLocalizations l10n) {
    return _buildGenericTestAnalysis(
      l10n.detailedAnalysisPeripheralVisionTest,
      percentage,
      l10n.detailedAnalysisPeripheralVisionTestDesc,
      l10n.detailedAnalysisPeripheralVisionTestConsequence,
      l10n,
    );
  }

  Widget _buildEyeMovementAnalysis(int percentage, AppLocalizations l10n) {
    return _buildGenericTestAnalysis(
      l10n.detailedAnalysisEyeMovementTest,
      percentage,
      l10n.detailedAnalysisEyeMovementTestDesc,
      l10n.detailedAnalysisEyeMovementTestConsequence,
      l10n,
    );
  }

  Widget _buildGenericTestAnalysis(
    String testName,
    int percentage,
    String description,
    String consequence,
    AppLocalizations l10n,
  ) {
    final hasProblem = percentage < 80;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSection(
          title: l10n.detailedAnalysisGenericTestAssessment(testName),
          icon: LucideIcons.activity,
          color: AppColors.medicalTeal,
          children: [
            _buildInfoCard(
              l10n.detailedAnalysisCurrentStatus,
              l10n.detailedAnalysisGenericTestResult(description, percentage),
              LucideIcons.info,
              AppColors.medicalTeal,
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (hasProblem) ...[
          _buildSection(
            title: l10n.detailedAnalysisGenericConsequences,
            icon: LucideIcons.alertCircle,
            color: AppColors.warningYellow,
            children: [
              _buildInfoCard(
                l10n.detailedAnalysisGenericEffects,
                consequence,
                LucideIcons.info,
                AppColors.warningYellow,
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
        _buildSection(
          title: l10n.detailedAnalysisRecommendations,
          icon: LucideIcons.heart,
          color: AppColors.successGreen,
          children: [
            _buildSolutionCard(
              l10n.detailedAnalysisGenericSolutionDoctor,
              l10n.detailedAnalysisGenericSolutionDoctorDesc,
              LucideIcons.stethoscope,
            ),
            const SizedBox(height: 12),
            _buildSolutionCard(
              l10n.detailedAnalysisGenericSolutionCheckups,
              l10n.detailedAnalysisGenericSolutionCheckupsDesc,
              LucideIcons.calendar,
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildWarningCard(l10n),
      ],
    );
  }

  Widget _buildGenericAnalysis(int percentage, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildInfoCard(
          l10n.detailedAnalysisGenericTestResultTitle,
          l10n.detailedAnalysisGenericTestResultText(percentage),
          LucideIcons.info,
          AppColors.medicalBlue,
        ),
        const SizedBox(height: 24),
        _buildWarningCard(l10n),
      ],
    );
  }

  // Helper widgets
  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildInfoCard(String title, String content, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProblemCard(String title, String description, List<String> symptoms) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.errorRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.errorRed.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.errorRed,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          ...symptoms.map((symptom) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      LucideIcons.circle,
                      size: 6,
                      color: AppColors.errorRed,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        symptom,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildConsequenceCard(String category, List<String> consequences) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warningYellow.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warningYellow.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            category,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.warningYellow,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          ...consequences.map((consequence) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      LucideIcons.alertTriangle,
                      size: 14,
                      color: AppColors.warningYellow,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        consequence,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildSolutionCard(String title, String description, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.successGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.successGreen.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.successGreen, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorBlindnessTypeCard(
    String title,
    String description,
    String symptom,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(LucideIcons.circle, size: 6, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  symptom,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWarningCard(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.warningYellow.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.warningYellow.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Icon(
            LucideIcons.alertCircle,
            size: 32,
            color: AppColors.warningYellow,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.detailedAnalysisWarning,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.detailedAnalysisWarningText,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getTestName(AppLocalizations l10n) {
    switch (widget.testType) {
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
        return l10n.detailedAnalysisGenericTestResultTitle;
    }
  }

  IconData _getTestIcon() {
    switch (widget.testType) {
      case 'visual_acuity':
        return LucideIcons.eye;
      case 'color_vision':
        return LucideIcons.palette;
      case 'astigmatism':
        return LucideIcons.focus;
      case 'stereopsis':
      case 'binocular_vision':
        return LucideIcons.eye;
      case 'near_vision':
        return LucideIcons.bookOpen;
      case 'macular':
        return LucideIcons.grid;
      case 'peripheral_vision':
        return LucideIcons.scan;
      case 'eye_movement':
        return LucideIcons.move;
      default:
        return LucideIcons.activity;
    }
  }

  Color _getTestColor() {
    switch (widget.testType) {
      case 'visual_acuity':
        return AppColors.medicalBlue;
      case 'color_vision':
        return AppColors.medicalTeal;
      case 'astigmatism':
        return AppColors.premiumGold;
      case 'stereopsis':
      case 'binocular_vision':
        return AppColors.medicalTeal;
      case 'near_vision':
        return AppColors.medicalBlue;
      case 'macular':
        return AppColors.medicalTeal;
      case 'peripheral_vision':
        return AppColors.medicalBlue;
      case 'eye_movement':
        return AppColors.premiumGold;
      default:
        return AppColors.medicalBlue;
    }
  }
}
