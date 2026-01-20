import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:goz_testi/core/theme/app_colors.dart';
import 'package:goz_testi/core/constants/app_strings.dart';
import 'package:goz_testi/core/router/app_router.dart';
import 'package:goz_testi/core/utils/screen_calibration.dart';
import 'package:goz_testi/core/widgets/app_button.dart';
import 'package:goz_testi/features/tests/common/utils/test_limit_checker.dart';
import 'package:goz_testi/l10n/app_localizations.dart';

/// Visual Acuity Test Page (Percentage Based)
/// 
/// Tests user's visual acuity for both eyes separately.
/// Fixed 10 questions per eye. Result is percentage based.
class VisualAcuityPage extends StatefulWidget {
  const VisualAcuityPage({super.key});

  @override
  State<VisualAcuityPage> createState() => _VisualAcuityPageState();
}

enum TestPhase {
  info, // NEW: Information screen before instructions
  instructionsLeft,
  testingLeft,
  instructionsRight,
  testingRight,
  finished
}

class _VisualAcuityPageState extends State<VisualAcuityPage>
    with SingleTickerProviderStateMixin {
  
  TestPhase _currentPhase = TestPhase.info;
  bool _showDistanceDialog = false;
  
  // Question tracking
  int _currentQuestionIndex = 1;
  final int _totalQuestionsPerEye = 10;
  
  // Difficulty Level (1-10) - Matches question index
  int _currentLevel = 1; 
  
  // Results
  int _leftEyeCorrectCount = 0;
  int _rightEyeCorrectCount = 0;
  
  // Standard Sloan Letters
  final List<String> _letterPool = ['C', 'D', 'E', 'F', 'H', 'K', 'N', 'O', 'P', 'R', 'S', 'V', 'Z'];
  
  String _currentLetter = 'E';
  List<String> _answerOptions = [];
  
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startLeftEyeTest() async {
    // Check if user can start test (only check for first eye)
    if (_currentPhase == TestPhase.instructionsLeft) {
      final canStart = await TestLimitChecker.canStartTest(context);
      if (!canStart) {
        return; // User chose not to start or limit reached
      }
    }
    
    setState(() {
      _currentPhase = TestPhase.testingLeft;
      _currentQuestionIndex = 1;
      _currentLevel = 1;
      _leftEyeCorrectCount = 0;
      _generateNewQuestion();
    });
  }

  void _startRightEyeTest() {
    // No need to check again for second eye, already checked for first eye
    setState(() {
      _currentPhase = TestPhase.testingRight;
      _currentQuestionIndex = 1;
      _currentLevel = 1;
      _rightEyeCorrectCount = 0;
      _generateNewQuestion();
    });
  }

  void _generateNewQuestion() {
    _currentLetter = _letterPool[_random.nextInt(_letterPool.length)];
    
    Set<String> options = {_currentLetter};
    while (options.length < 4) {
      options.add(_letterPool[_random.nextInt(_letterPool.length)]);
    }
    
    _answerOptions = options.toList()..shuffle();
    _animationController.forward(from: 0);
  }

  void _onOptionSelected(String selectedLetter) {
    final isCorrect = selectedLetter == _currentLetter;
    _processAnswer(isCorrect);
  }

  void _onNotSure() {
    _processAnswer(false);
  }

  void _processAnswer(bool isCorrect) {
    if (isCorrect) {
      if (_currentPhase == TestPhase.testingLeft) {
        _leftEyeCorrectCount++;
      } else {
        _rightEyeCorrectCount++;
      }
    }
    
    if (_currentQuestionIndex >= _totalQuestionsPerEye) {
      _completePhase();
    } else {
      setState(() {
        _currentQuestionIndex++;
        _currentLevel = _currentQuestionIndex; 
        _generateNewQuestion();
      });
    }
  }

  void _completePhase() {
    if (_currentPhase == TestPhase.testingLeft) {
      setState(() {
        _currentPhase = TestPhase.instructionsRight;
        _showDistanceDialog = false; // Reset for right eye dialog
      });
      // Show dialog for right eye after build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showDistanceInstructionDialog(isRightEyeClosed: false);
      });
    } else {
      _finishTest();
    }
  }

  void _finishTest() {
    // Percentage calculation (Exact)
    final leftPercentage = (_leftEyeCorrectCount / _totalQuestionsPerEye * 100).round();
    final rightPercentage = (_rightEyeCorrectCount / _totalQuestionsPerEye * 100).round();
    
    // Metric Acuity (e.g., 5/10)
    // We assume 10 correct answers = 10/10 vision
    final leftAcuity = ScreenCalibration.levelToMetricAcuity(_leftEyeCorrectCount);
    final rightAcuity = ScreenCalibration.levelToMetricAcuity(_rightEyeCorrectCount);
    
    context.pushReplacement(
      AppRoutes.result,
      extra: {
        'testType': 'visual_acuity',
        'score': _leftEyeCorrectCount + _rightEyeCorrectCount, // Use correct count, not percentage
        'totalQuestions': _totalQuestionsPerEye * 2,
        'details': {
          'leftEyeScore': leftPercentage,
          'rightEyeScore': rightPercentage,
          'leftEyeAcuity': leftAcuity,
          'rightEyeAcuity': rightAcuity,
          'isPercentageBased': true,
        },
      },
    );
  }

  void _onInfoContinue() async {
    // Check if user can start test
    final canStart = await TestLimitChecker.canStartTest(context);
    if (!canStart) {
      return; // User chose not to start or limit reached
    }
    
    setState(() {
      _currentPhase = TestPhase.instructionsLeft;
    });
    
    // Show dialog after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showDistanceInstructionDialog(isRightEyeClosed: true);
    });
  }
  
  void _onRightEyeInstructionsContinue() {
    // Show dialog after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showDistanceInstructionDialog(isRightEyeClosed: false);
    });
  }
  
  void _showDistanceInstructionDialog({required bool isRightEyeClosed}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _DistanceInstructionDialog(
        isRightEyeClosed: isRightEyeClosed,
        onConfirm: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (_currentPhase) {
      case TestPhase.info:
        return _buildInfoScreen();
      case TestPhase.instructionsLeft:
        return _buildInstructionScreen(
          title: AppLocalizations.of(context)!.visualAcuityLeftEyeTitle,
          instruction: AppLocalizations.of(context)!.visualAcuityLeftEyeInstruction,
          subInstruction: AppLocalizations.of(context)!.visualAcuityLeftEyeSubInstruction,
          onStart: _startLeftEyeTest,
          isRightEyeClosed: true,
          onShowDialog: () => _showDistanceInstructionDialog(isRightEyeClosed: true),
        );
      case TestPhase.instructionsRight:
        return _buildInstructionScreen(
          title: AppLocalizations.of(context)!.visualAcuityRightEyeTitle,
          instruction: AppLocalizations.of(context)!.visualAcuityRightEyeInstruction,
          subInstruction: AppLocalizations.of(context)!.visualAcuityRightEyeSubInstruction,
          onStart: _startRightEyeTest,
          isRightEyeClosed: false,
          onShowDialog: () => _showDistanceInstructionDialog(isRightEyeClosed: false),
        );
      case TestPhase.testingLeft:
      case TestPhase.testingRight:
        return _buildTestScreen();
      default:
        return const Scaffold();
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
        title: Text(l10n.visualAcuityTitle),
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
                    LucideIcons.eye,
                    size: 48,
                    color: AppColors.medicalBlue,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                l10n.visualAcuityInfoTitle,
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
                      l10n.visualAcuityInfoDesc,
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
                              l10n.visualAcuityInfoTip,
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
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.warningYellowPale,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            LucideIcons.alertCircle,
                            color: AppColors.warningYellow,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              l10n.visualAcuityInfoWarning,
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionScreen({
    required String title,
    required String instruction,
    required String subInstruction,
    required VoidCallback onStart,
    required bool isRightEyeClosed,
    VoidCallback? onShowDialog,
  }) {
    // Show dialog when screen is built (only once)
    if (onShowDialog != null && !_showDistanceDialog) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _showDistanceDialog = true;
          });
          onShowDialog();
        }
      });
    }
    return Scaffold(
      backgroundColor: AppColors.cleanWhite,
      appBar: AppBar(backgroundColor: AppColors.cleanWhite),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
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
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Sol göz
                      Positioned(
                        left: 20,
                        child: isRightEyeClosed
                            ? // Sol göz testi: Sol göz açık
                              Icon(
                                LucideIcons.eye,
                                size: 32,
                                color: AppColors.medicalBlue,
                              )
                            : // Sağ göz testi: Sol göz el ile kapalı
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Icon(
                                    LucideIcons.eye,
                                    size: 32,
                                    color: AppColors.medicalBlue.withOpacity(0.3),
                                  ),
                                  Icon(
                                    LucideIcons.hand,
                                    size: 28,
                                    color: AppColors.medicalBlue,
                                  ),
                                ],
                              ),
                      ),
                      // Sağ göz
                      Positioned(
                        right: 20,
                        child: isRightEyeClosed
                            ? // Sol göz testi: Sağ göz el ile kapalı
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Icon(
                                    LucideIcons.eye,
                                    size: 32,
                                    color: AppColors.medicalBlue.withOpacity(0.3),
                                  ),
                                  Icon(
                                    LucideIcons.hand,
                                    size: 28,
                                    color: AppColors.medicalBlue,
                                  ),
                                ],
                              )
                            : // Sağ göz testi: Sağ göz açık
                              Icon(
                                LucideIcons.eye,
                                size: 32,
                                color: AppColors.medicalBlue,
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                title,
                style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.warningYellowPale,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      instruction,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context)!.questionsDuringTest(_totalQuestionsPerEye),
                      style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              AppButton(
                text: AppLocalizations.of(context)!.startButton,
                icon: LucideIcons.play,
                onPressed: onStart,
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestScreen() {
    final l10n = AppLocalizations.of(context)!;
    // Map question index directly to 1-10 scale
    final difficultyLevel = _currentQuestionIndex; 
    final fontSize = ScreenCalibration.getSnellenSize(context, difficultyLevel);
    final isLeftTest = _currentPhase == TestPhase.testingLeft;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.medicalBluePale,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isLeftTest ? l10n.leftEyeLabel : l10n.rightEyeLabel,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.medicalBlue,
                ),
              ),
            ),
            const Spacer(),
            Text(
              l10n.questionNumber(_currentQuestionIndex, _totalQuestionsPerEye),
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(
              value: _currentQuestionIndex / _totalQuestionsPerEye,
              backgroundColor: AppColors.backgroundGrey,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.medicalBlue),
              minHeight: 4,
            ),
            
            Expanded(
              flex: 3,
              child: Center(
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      _currentLetter,
                      style: GoogleFonts.inter( // Using Inter for cleaner edges
                        fontSize: fontSize,
                        fontWeight: FontWeight.w700, // Slightly less bold for clarity
                        color: Colors.black,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.backgroundGrey.withOpacity(0.5),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Column(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.visualAcuityQuestionText,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 4,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.0,
                        physics: const NeverScrollableScrollPhysics(),
                        children: _answerOptions.map((letter) {
                          return _buildOptionButton(letter);
                        }).toList(),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _onNotSure,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(
                            color: AppColors.borderLight,
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          l10n.notSure,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(String letter) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      child: InkWell(
        onTap: () => _onOptionSelected(letter),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.borderLight,
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              letter,
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Dialog for showing distance instruction with selfie-like visual
class _DistanceInstructionDialog extends StatelessWidget {
  final bool isRightEyeClosed;
  final VoidCallback onConfirm;

  const _DistanceInstructionDialog({
    required this.isRightEyeClosed,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final eyeText = isRightEyeClosed 
        ? l10n.visualAcuityDistanceDialogContent
        : l10n.visualAcuityDistanceDialogContentLeft;

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
                  // Smartphone icon (held in front)
                  Positioned(
                    top: 10,
                    child: Transform.rotate(
                      angle: -0.1, // Slight angle for natural look
                      child: Icon(
                        LucideIcons.smartphone,
                        size: 40,
                        color: AppColors.medicalBlue,
                      ),
                    ),
                  ),
                  // Hand icon (holding phone)
                  Positioned(
                    top: 25,
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
              l10n.visualAcuityDistanceDialogTitle,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              eyeText,
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
                  onConfirm();
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
                  l10n.okay,
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
