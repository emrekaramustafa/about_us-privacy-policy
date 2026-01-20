import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:goz_testi/core/theme/app_colors.dart';
import 'package:goz_testi/core/constants/app_strings.dart';
import 'package:goz_testi/core/router/app_router.dart';
import 'package:goz_testi/core/widgets/app_button.dart';
import 'package:goz_testi/features/tests/common/utils/test_limit_checker.dart';
import 'package:goz_testi/l10n/app_localizations.dart';
import 'package:goz_testi/features/tests/common/utils/test_limit_checker.dart';

/// Vergence Test Page - Convergence/Divergence Test
enum VergencePhase { info, instructions, testing }
enum VergenceType { convergence, divergence }

class BinocularVisionPage extends StatefulWidget {
  const BinocularVisionPage({super.key});

  @override
  State<BinocularVisionPage> createState() => _BinocularVisionPageState();
}

class _BinocularVisionPageState extends State<BinocularVisionPage>
    with TickerProviderStateMixin {
  VergencePhase _currentPhase = VergencePhase.info;
  VergenceType _currentTestType = VergenceType.convergence;
  int _currentQuestion = 0;
  int _correctAnswers = 0;
  bool _hasDiplopia = false;
  double _targetSize = 60.0;
  double _targetPosition = 0.5; // 0.0 = far, 1.0 = near
  
  late AnimationController _animationController;
  late AnimationController _movementController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _sizeAnimation;
  late Animation<double> _positionAnimation;
  
  List<Map<String, dynamic>> _getTestQuestions(AppLocalizations l10n) {
    return [
      {
        'type': VergenceType.convergence,
        'instruction': l10n.vergenceQuestionConverge,
        'target': '●',
        'minSize': 40.0,
        'maxSize': 120.0,
      },
      {
        'type': VergenceType.divergence,
        'instruction': l10n.vergenceQuestionDiverge,
        'target': '■',
        'minSize': 120.0,
        'maxSize': 40.0,
      },
      {
        'type': VergenceType.convergence,
        'instruction': l10n.vergenceQuestionFinal,
        'target': '▲',
        'minSize': 35.0,
        'maxSize': 110.0,
      },
    ];
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _movementController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    
    _sizeAnimation = Tween<double>(begin: 60.0, end: 120.0).animate(
      CurvedAnimation(parent: _movementController, curve: Curves.easeInOut),
    );
    
    _positionAnimation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _movementController, curve: Curves.easeInOut),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _movementController.dispose();
    super.dispose();
  }

  void _onInfoContinue() async {
    final canStart = await TestLimitChecker.canStartTest(context);
    if (!canStart) return;
    
    setState(() {
      _currentPhase = VergencePhase.instructions;
    });
  }

  void _startTest() async {
    final canStart = await TestLimitChecker.canStartTest(context);
    if (!canStart) return;
    
    setState(() {
      _currentPhase = VergencePhase.testing;
      _currentQuestion = 0;
      _correctAnswers = 0;
      _hasDiplopia = false;
      _loadQuestion();
    });
    _animationController.forward(from: 0);
  }

  void _loadQuestion() {
    final l10n = AppLocalizations.of(context)!;
    final testQuestions = _getTestQuestions(l10n);
    
    if (_currentQuestion >= testQuestions.length) {
      _finishTest();
      return;
    }
    
    final question = testQuestions[_currentQuestion];
    _currentTestType = question['type'] as VergenceType;
    
    if (_currentTestType == VergenceType.convergence) {
      _targetSize = question['minSize'] as double;
      _targetPosition = 0.3;
      _sizeAnimation = Tween<double>(
        begin: question['minSize'] as double,
        end: question['maxSize'] as double,
      ).animate(CurvedAnimation(
        parent: _movementController,
        curve: Curves.easeInOut,
      ));
      _positionAnimation = Tween<double>(begin: 0.3, end: 0.7).animate(
        CurvedAnimation(parent: _movementController, curve: Curves.easeInOut),
      );
    } else {
      _targetSize = question['maxSize'] as double;
      _targetPosition = 0.7;
      _sizeAnimation = Tween<double>(
        begin: question['maxSize'] as double,
        end: question['minSize'] as double,
      ).animate(CurvedAnimation(
        parent: _movementController,
        curve: Curves.easeInOut,
      ));
      _positionAnimation = Tween<double>(begin: 0.7, end: 0.3).animate(
        CurvedAnimation(parent: _movementController, curve: Curves.easeInOut),
      );
    }
    
    _movementController.reset();
    _movementController.repeat(reverse: true);
  }

  void _onDiplopiaAnswer(bool hasDiplopia) {
    setState(() {
      _hasDiplopia = hasDiplopia;
    });
    
    // If no diplopia, it's a correct answer
    if (!hasDiplopia) {
      _correctAnswers++;
    }
    
    // Move to next question
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _currentQuestion++;
          _hasDiplopia = false;
        });
        _loadQuestion();
        _animationController.forward(from: 0);
      }
    });
  }

  void _finishTest() {
    _movementController.stop();
    
    final l10n = AppLocalizations.of(context)!;
    final testQuestions = _getTestQuestions(l10n);
    final percentage = (_correctAnswers / testQuestions.length * 100).round();
    String diagnosis;
    
    if (percentage >= 80) {
      diagnosis = l10n.vergenceDiagnosisNormal;
    } else if (percentage >= 60) {
      diagnosis = l10n.vergenceDiagnosisMild;
    } else {
      diagnosis = l10n.vergenceDiagnosisSevere;
    }
    
    context.pushReplacement(
      AppRoutes.result,
      extra: {
        'testType': 'binocular_vision',
        'score': _correctAnswers,
        'totalQuestions': testQuestions.length,
        'details': {
          'percentage': percentage,
          'diagnosis': diagnosis,
          'correctAnswers': _correctAnswers,
          'totalQuestions': testQuestions.length,
          'hasDiplopia': _hasDiplopia,
        },
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (_currentPhase) {
      case VergencePhase.info:
        return _buildInfoScreen();
      case VergencePhase.instructions:
        return _buildInstructionsScreen();
      case VergencePhase.testing:
        return _buildTestScreen();
    }
  }

  Widget _buildInfoScreen() {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: AppColors.cleanWhite,
      appBar: AppBar(
        backgroundColor: AppColors.cleanWhite,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        title: Text(AppLocalizations.of(context)!.stereopsisTitle),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 100,
                height: 100,
                margin: const EdgeInsets.only(top: 20),
                decoration: BoxDecoration(
                  color: AppColors.medicalBluePale,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    LucideIcons.move,
                    size: 48,
                    color: AppColors.medicalBlue,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                l10n.vergenceInfoTitle,
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.infoBluePale,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            LucideIcons.info,
                            color: AppColors.infoBlue,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            l10n.vergenceInfoSectionTitle,
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.vergenceInfoDesc,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        height: 1.6,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.successGreenPale,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            LucideIcons.checkCircle,
                            color: AppColors.successGreen,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              l10n.vergenceInfoTip,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                height: 1.5,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              AppButton(
                text: l10n.continueText,
                icon: LucideIcons.arrowRight,
                onPressed: _onInfoContinue,
                width: double.infinity,
                backgroundColor: AppColors.medicalBlue,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionsScreen() {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: AppColors.cleanWhite,
      appBar: AppBar(
        backgroundColor: AppColors.cleanWhite,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        title: Text(l10n.stereopsisTitle),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 100,
                height: 100,
                margin: const EdgeInsets.only(top: 20),
                decoration: BoxDecoration(
                  color: AppColors.medicalBluePale,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    LucideIcons.move,
                    size: 48,
                    color: AppColors.medicalBlue,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                l10n.testInstructions,
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInstructionItem(
                      icon: LucideIcons.eye,
                      text: l10n.vergenceInstruction1,
                    ),
                    const SizedBox(height: 16),
                    _buildInstructionItem(
                      icon: LucideIcons.move,
                      text: l10n.vergenceInstruction2,
                    ),
                    const SizedBox(height: 16),
                    _buildInstructionItem(
                      icon: LucideIcons.alertCircle,
                      text: l10n.vergenceInstruction3,
                    ),
                    const SizedBox(height: 16),
                    _buildInstructionItem(
                      icon: LucideIcons.target,
                      text: l10n.vergenceInstruction4,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              AppButton(
                text: l10n.startButton,
                icon: LucideIcons.play,
                onPressed: _startTest,
                width: double.infinity,
                backgroundColor: AppColors.medicalBlue,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestScreen() {
    final l10n = AppLocalizations.of(context)!;
    final testQuestions = _getTestQuestions(l10n);
    
    if (_currentQuestion >= testQuestions.length) {
      return const SizedBox();
    }
    
    final question = testQuestions[_currentQuestion];
    final target = question['target'] as String;
    final instruction = question['instruction'] as String;
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(LucideIcons.x, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.questionNumber(_currentQuestion + 1, testQuestions.length),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              LinearProgressIndicator(
                value: (_currentQuestion + 1) / testQuestions.length,
                backgroundColor: Colors.grey.shade800,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.medicalBlue),
                minHeight: 4,
              ),
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        instruction,
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      
                      // Animated target
                      SizedBox(
                        height: 300,
                        child: AnimatedBuilder(
                          animation: _movementController,
                          builder: (context, child) {
                            final size = _sizeAnimation.value;
                            final position = _positionAnimation.value;
                            
                            return Align(
                              alignment: Alignment(0, position * 2 - 1),
                              child: Container(
                                width: size,
                                height: size,
                                decoration: BoxDecoration(
                                  color: AppColors.medicalBlue,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.medicalBlue.withValues(alpha: 0.5),
                                      blurRadius: 30,
                                      spreadRadius: 10,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    target,
                                    style: GoogleFonts.inter(
                                      fontSize: size * 0.6,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      
                      const SizedBox(height: 60),
                      
                      Text(
                        l10n.vergenceDiplopiaQuestion,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Diplopia buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => _onDiplopiaAnswer(false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: !_hasDiplopia 
                                    ? AppColors.successGreen 
                                    : Colors.grey.shade800,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: !_hasDiplopia 
                                      ? AppColors.successGreen 
                                      : Colors.grey.shade700,
                                  width: !_hasDiplopia ? 3 : 1,
                                ),
                              ),
                              child: Text(
                                l10n.no,
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: () => _onDiplopiaAnswer(true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: _hasDiplopia 
                                    ? AppColors.errorRed 
                                    : Colors.grey.shade800,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _hasDiplopia 
                                      ? AppColors.errorRed 
                                      : Colors.grey.shade700,
                                  width: _hasDiplopia ? 3 : 1,
                                ),
                              ),
                              child: Text(
                                l10n.yes,
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionItem({required IconData icon, required String text}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.medicalBluePale,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: AppColors.medicalBlue),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}
