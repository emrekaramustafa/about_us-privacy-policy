import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:goz_testi/core/theme/app_colors.dart';
import 'package:goz_testi/core/constants/app_strings.dart';
import 'package:goz_testi/core/router/app_router.dart';
import 'package:goz_testi/core/widgets/app_button.dart';
import 'package:goz_testi/core/services/sound_service.dart';
import 'package:goz_testi/features/tests/common/utils/test_limit_checker.dart';
import 'package:goz_testi/l10n/app_localizations.dart';

/// Near Vision Test Page
enum NearVisionPhase { info, instructions, testing }

class NearVisionPage extends StatefulWidget {
  const NearVisionPage({super.key});

  @override
  State<NearVisionPage> createState() => _NearVisionPageState();
}

class _NearVisionPageState extends State<NearVisionPage>
    with TickerProviderStateMixin {
  NearVisionPhase _currentPhase = NearVisionPhase.info;
  int _currentQuestion = 0;
  int _correctAnswers = 0;
  bool _showDistanceDialog = false;
  
  // Answer feedback state
  int? _selectedAnswerIndex;
  bool? _isAnswerCorrect;
  bool _showFeedback = false;
  bool _isProcessingAnswer = false;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // Shake animation for wrong answers
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  
  final SoundService _soundService = SoundService();

  // Font sizes for near vision test (decreasing)
  // Starting from question 2 (20) with same difficulty progression
  // Each level is approximately 15-20% smaller than previous
  final List<double> _fontSizes = [
    20, 17, 14, 12, 10, 8.5, 7, 6, 5, 4.5
  ];
  
  List<String> _getWords(AppLocalizations l10n) {
    return [
      l10n.nearVisionWord1,
      l10n.nearVisionWord2,
      l10n.nearVisionWord3,
      l10n.nearVisionWord4,
      l10n.nearVisionWord5,
      l10n.nearVisionWord6,
      l10n.nearVisionWord7,
      l10n.nearVisionWord8,
      l10n.nearVisionWord9,
      l10n.nearVisionWord10,
    ];
  }
  
  String? _currentWord;
  List<String> _options = [];
  int? _selectedAnswer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    
    // Shake animation controller
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _onInfoContinue() async {
    // Check if user can start test
    final canStart = await TestLimitChecker.canStartTest(context);
    if (!canStart) {
      return; // User chose not to start or limit reached
    }
    
    setState(() {
      _currentPhase = NearVisionPhase.instructions;
    });
    
    // Show dialog after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showDistanceInstructionDialog();
    });
  }
  
  void _showDistanceInstructionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _DistanceInstructionDialog(
        onConfirm: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _startTest() async {
    // Check if user can start test
    final canStart = await TestLimitChecker.canStartTest(context);
    if (!canStart) {
      return; // User chose not to start or limit reached
    }
    
    setState(() {
      _currentPhase = NearVisionPhase.testing;
      _currentQuestion = 0;
      _correctAnswers = 0;
      _generateQuestion();
    });
    
    _animationController.forward(from: 0);
  }

  void _generateQuestion() {
    final l10n = AppLocalizations.of(context)!;
    final words = _getWords(l10n);
    final random = _currentQuestion * 7;
    _currentWord = words[random % words.length];
    
    // Generate options (correct + 3 wrong)
    final allWords = List<String>.from(words);
    allWords.remove(_currentWord);
    allWords.shuffle();
    
    _options = [_currentWord!, ...allWords.take(3)];
    _options.shuffle();
    _selectedAnswer = null;
  }

  void _onAnswerSelected(int index) async {
    if (_isProcessingAnswer) return; // Prevent double tap
    
    final isCorrect = _options[index] == _currentWord;
    
    setState(() {
      _isProcessingAnswer = true;
      _selectedAnswerIndex = index;
      _selectedAnswer = index;
      _isAnswerCorrect = isCorrect;
      _showFeedback = true;
    });
    
    // Play sound
    if (isCorrect) {
      _soundService.playSuccess();
      _correctAnswers++;
    } else {
      _soundService.playError();
      // Start shake animation
      _shakeController.forward(from: 0);
    }
    
    // Wait for feedback to be visible
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Reset feedback state and move to next question
    if (mounted) {
      setState(() {
        _selectedAnswerIndex = null;
        _isAnswerCorrect = null;
        _showFeedback = false;
        _isProcessingAnswer = false;
      });
      _onNextQuestion();
    }
  }

  void _onNextQuestion() {
    if (_currentQuestion < _fontSizes.length - 1) {
      setState(() {
        _currentQuestion++;
        _selectedAnswer = null; // Reset selection
        _generateQuestion();
      });
      _animationController.forward(from: 0);
    } else {
      _finishTest();
    }
  }

  void _finishTest() {
    final l10n = AppLocalizations.of(context)!;
    final percentage = (_correctAnswers / _fontSizes.length * 100).round();
    String diagnosis;
    
    if (percentage >= 80) {
      diagnosis = l10n.nearVisionDiagnosisNormal;
    } else if (percentage >= 60) {
      diagnosis = l10n.nearVisionDiagnosisMild;
    } else {
      diagnosis = l10n.nearVisionDiagnosisSevere;
    }
    
    context.pushReplacement(
      AppRoutes.result,
      extra: {
        'testType': 'near_vision',
        'score': _correctAnswers, // Use correct answers count, not percentage
        'totalQuestions': _fontSizes.length,
        'details': {
          'percentage': percentage,
          'diagnosis': diagnosis,
          'correctAnswers': _correctAnswers,
          'totalQuestions': _fontSizes.length,
        },
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (_currentPhase) {
      case NearVisionPhase.info:
        return _buildInfoScreen();
      case NearVisionPhase.instructions:
        return _buildInstructionsScreen();
      case NearVisionPhase.testing:
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
        title: Text(l10n.nearVisionTitle),
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
                  color: AppColors.medicalTealPale,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    LucideIcons.bookOpen,
                    size: 48,
                    color: AppColors.medicalTeal,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                l10n.nearVisionInfoTitle,
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
                            l10n.testAbout,
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
                      l10n.nearVisionInfoDesc,
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
                              l10n.nearVisionInfoTip,
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
                backgroundColor: AppColors.medicalTeal,
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
        title: Text(l10n.nearVisionTitle),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 100,
                height: 100,
                margin: const EdgeInsets.only(top: 20),
                decoration: BoxDecoration(
                  color: AppColors.medicalTealPale,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    LucideIcons.bookOpen,
                    size: 48,
                    color: AppColors.medicalTeal,
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
                      icon: LucideIcons.ruler,
                      text: l10n.nearVisionInstruction1,
                    ),
                    const SizedBox(height: 16),
                    _buildInstructionItem(
                      icon: LucideIcons.eye,
                      text: l10n.nearVisionInstruction2,
                    ),
                    const SizedBox(height: 16),
                    _buildInstructionItem(
                      icon: LucideIcons.mousePointer,
                      text: l10n.nearVisionInstruction3,
                    ),
                    const SizedBox(height: 16),
                    _buildInstructionItem(
                      icon: LucideIcons.alertCircle,
                      text: l10n.nearVisionInstruction4,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              AppButton(
                text: l10n.startButton,
                icon: LucideIcons.play,
                onPressed: _startTest,
                width: double.infinity,
                backgroundColor: AppColors.medicalTeal,
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
            color: AppColors.medicalTealPale,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: AppColors.medicalTeal),
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

  Widget _buildTestScreen() {
    final fontSize = _fontSizes[_currentQuestion];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(LucideIcons.x),
          onPressed: () => context.pop(),
        ),
        title: Text(
          AppLocalizations.of(context)!.questionNumber(_currentQuestion + 1, _fontSizes.length),
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (_currentQuestion + 1) / _fontSizes.length,
              backgroundColor: AppColors.backgroundGrey,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.medicalTeal),
              minHeight: 4,
            ),
            
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Word Display
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _currentWord ?? AppLocalizations.of(context)!.nearVisionWord1,
                        style: GoogleFonts.inter(
                          fontSize: fontSize,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  Text(
                    AppLocalizations.of(context)!.nearVisionQuestion,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Options
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: _options.asMap().entries.map((entry) {
                        final index = entry.key;
                        final word = entry.value;
                        
                        return _buildOptionButton(index, word);
                      }).toList(),
                    ),
                  ),
                  
                  // Button removed - automatic progression on selection
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildOptionButton(int index, String word) {
    final isSelected = _selectedAnswerIndex == index;
    final isCorrect = _isAnswerCorrect == true && isSelected;
    final isWrong = _isAnswerCorrect == false && isSelected;
    
    // Determine border color
    Color borderColor = AppColors.borderLight;
    double borderWidth = 1;
    if (_showFeedback && isSelected) {
      borderColor = isCorrect ? AppColors.successGreen : AppColors.errorRed;
      borderWidth = 3;
    }
    
    Widget buttonContent = Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: _isProcessingAnswer ? null : () => _onAnswerSelected(index),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor,
              width: borderWidth,
            ),
          ),
          child: Center(
            child: Text(
              word,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
    
    // Apply shake animation for wrong answers
    if (_showFeedback && isWrong) {
      return AnimatedBuilder(
        animation: _shakeAnimation,
        builder: (context, child) {
          final shakeOffset = sin(_shakeAnimation.value * pi * 4) * 8;
          return Transform.translate(
            offset: Offset(shakeOffset, 0),
            child: child,
          );
        },
        child: buttonContent,
      );
    }
    
    return buttonContent;
  }
}

/// Dialog for showing distance instruction with selfie-like visual for near vision
class _DistanceInstructionDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const _DistanceInstructionDialog({
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Selfie-like visual
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.medicalBluePale,
                shape: BoxShape.circle,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // User/Person icon (body)
                  Positioned(
                    bottom: 15,
                    child: Icon(
                      LucideIcons.user,
                      size: 50,
                      color: AppColors.medicalBlue,
                    ),
                  ),
                  // Smartphone icon (held closer - near vision)
                  Positioned(
                    top: 25,
                    child: Transform.rotate(
                      angle: -0.1,
                      child: Icon(
                        LucideIcons.smartphone,
                        size: 40,
                        color: AppColors.medicalBlue,
                      ),
                    ),
                  ),
                  // Hand icon (holding phone closer)
                  Positioned(
                    top: 35,
                    right: 20,
                    child: Icon(
                      LucideIcons.hand,
                      size: 24,
                      color: AppColors.medicalBlue.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.nearVisionDistanceDialogTitle,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.nearVisionDistanceDialogContent,
              style: GoogleFonts.inter(
                fontSize: 15,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.medicalBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  AppLocalizations.of(context)!.okay,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
