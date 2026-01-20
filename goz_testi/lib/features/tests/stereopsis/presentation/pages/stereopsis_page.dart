import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:goz_testi/core/theme/app_colors.dart';
import 'package:goz_testi/core/router/app_router.dart';
import 'package:goz_testi/core/widgets/app_button.dart';
import 'package:goz_testi/features/tests/common/utils/test_limit_checker.dart';
import 'package:goz_testi/l10n/app_localizations.dart';

/// Stereopsis (Visual Tracking Game) Test Page
enum StereopsisPhase { info, instructions, testing }

class StereopsisPage extends StatefulWidget {
  const StereopsisPage({super.key});

  @override
  State<StereopsisPage> createState() => _StereopsisPageState();
}

class _StereopsisPageState extends State<StereopsisPage>
    with SingleTickerProviderStateMixin {
  StereopsisPhase _currentPhase = StereopsisPhase.info;
  int _currentQuestion = 0;
  int _correctAnswers = 0;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  final Random _random = Random();
  
  // Speed levels: milliseconds between movements (lower = faster)
  // Much faster and smoother
  final List<int> _speedLevels = [
    100, 80, 60, 50, 40, 35, 30, 25, 20, 15
  ];
  
  // Movement duration: how long the ball moves (seconds)
  final List<int> _durationLevels = [
    4, 4, 3, 3, 3, 2, 2, 2, 2, 2
  ];
  
  Offset _ballPosition = Offset.zero;
  int _currentShapeIndex = 0; // Which shape the ball is under (0, 1, or 2)
  int? _selectedShapeIndex;
  bool _isMoving = false;
  Timer? _movementTimer;
  Timer? _speedTimer;
  DateTime? _movementStartTime;
  
  // Three shapes: Hat, Star, Heart
  final List<Map<String, dynamic>> _shapes = [
    {'name': 'Şapka', 'icon': LucideIcons.crown, 'color': AppColors.medicalBlue},
    {'name': 'Yıldız', 'icon': LucideIcons.star, 'color': AppColors.medicalTeal},
    {'name': 'Kalp', 'icon': LucideIcons.heart, 'color': AppColors.premiumGold},
  ];

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
    _animationController.forward();
  }

  @override
  void dispose() {
    _movementTimer?.cancel();
    _speedTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _onInfoContinue() async {
    // Check if user can start test
    final canStart = await TestLimitChecker.canStartTest(context);
    if (!canStart) {
      return; // User chose not to start or limit reached
    }
    
    setState(() {
      _currentPhase = StereopsisPhase.instructions;
    });
  }

  void _startTest() async {
    // Check if user can start test
    final canStart = await TestLimitChecker.canStartTest(context);
    if (!canStart) {
      return; // User chose not to start or limit reached
    }
    
    setState(() {
      _currentPhase = StereopsisPhase.testing;
      _currentQuestion = 0;
      _correctAnswers = 0;
      _startMovement();
    });
  }

  void _startMovement() {
    if (!mounted) return;
    
    final size = MediaQuery.of(context).size;
    final speed = _speedLevels[_currentQuestion];
    final duration = _durationLevels[_currentQuestion];
    
    // Cancel previous timers
    _movementTimer?.cancel();
    _speedTimer?.cancel();
    
    // Start with random shape
    _currentShapeIndex = _random.nextInt(3);
    _selectedShapeIndex = null;
    
    // Calculate initial position (center of current shape, behind the shape)
    final shapeWidth = (size.width - 48) / 3;
    final ballY = size.height * 0.5; // Center vertically in the shape area
    _ballPosition = Offset(
      (_currentShapeIndex * shapeWidth) + (shapeWidth / 2) + 24 - 25, // -25 to center the 50px ball
      ballY - 25, // -25 to center the 50px ball
    );
    
    setState(() {
      _isMoving = true;
    });
    
    _movementStartTime = DateTime.now();
    
    // Move ball between shapes
    _speedTimer = Timer.periodic(Duration(milliseconds: speed), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      // Check if duration elapsed
      if (_movementStartTime != null) {
        final elapsed = DateTime.now().difference(_movementStartTime!).inSeconds;
        if (elapsed >= duration) {
          timer.cancel();
          if (mounted) {
            setState(() {
              _isMoving = false;
            });
          }
          return;
        }
      }
      
      // Move to next shape (randomly)
      if (mounted) {
        setState(() {
          // 70% chance to move to next/prev, 30% chance to stay
          if (_random.nextDouble() < 0.7) {
            if (_random.nextBool()) {
              // Move to next
              _currentShapeIndex = (_currentShapeIndex + 1) % 3;
            } else {
              // Move to previous
              _currentShapeIndex = (_currentShapeIndex - 1 + 3) % 3;
            }
          }
          
          // Update ball position (smooth animation)
          final shapeWidth = (size.width - 48) / 3;
          final ballY = size.height * 0.5; // Center vertically in the shape area
          _ballPosition = Offset(
            (_currentShapeIndex * shapeWidth) + (shapeWidth / 2) + 24 - 25, // -25 to center the 50px ball
            ballY - 25, // -25 to center the 50px ball
          );
        });
      }
    });
  }

  void _onShapeSelected(int index) {
    if (_isMoving) return; // Can't select while moving
    
    setState(() {
      _selectedShapeIndex = index;
    });
    
    // Check if correct
    final isCorrect = index == _currentShapeIndex;
    if (isCorrect) {
      _correctAnswers++;
    }
    
    // Automatically move to next question
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        if (_currentQuestion < _speedLevels.length - 1) {
          setState(() {
            _currentQuestion++;
            _selectedShapeIndex = null;
          });
          _startMovement();
          _animationController.forward(from: 0);
        } else {
          _finishTest();
        }
      }
    });
  }

  void _finishTest() {
    final l10n = AppLocalizations.of(context)!;
    final percentage = (_correctAnswers / _speedLevels.length * 100).round();
    String diagnosis;
    
    if (percentage >= 80) {
      diagnosis = l10n.stereopsisDiagnosisNormal;
    } else if (percentage >= 60) {
      diagnosis = l10n.stereopsisDiagnosisMild;
    } else {
      diagnosis = l10n.stereopsisDiagnosisLow;
    }
    
    context.pushReplacement(
      AppRoutes.result,
      extra: {
        'testType': 'stereopsis',
        'score': _correctAnswers, // Use correct answers count, not percentage
        'totalQuestions': _speedLevels.length,
        'details': {
          'percentage': percentage,
          'diagnosis': diagnosis,
          'correctAnswers': _correctAnswers,
          'totalQuestions': _speedLevels.length,
        },
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (_currentPhase) {
      case StereopsisPhase.info:
        return _buildInfoScreen();
      case StereopsisPhase.instructions:
        return _buildInstructionsScreen();
      case StereopsisPhase.testing:
        return _buildTestScreen();
    }
  }

  Widget _buildInfoScreen() {
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
                  color: AppColors.medicalTealPale,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    LucideIcons.move,
                    size: 48,
                    color: AppColors.medicalTeal,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                AppLocalizations.of(context)!.stereopsisInfoTitle,
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
                            'Test Hakkında',
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
                      AppLocalizations.of(context)!.stereopsisInfoDesc,
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
                              AppLocalizations.of(context)!.stereopsisInfoTip,
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
                text: AppLocalizations.of(context)!.continueText,
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
                  color: AppColors.medicalTealPale,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    LucideIcons.move,
                    size: 48,
                    color: AppColors.medicalTeal,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                AppLocalizations.of(context)!.testInstructions,
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
                      text: AppLocalizations.of(context)!.stereopsisInstruction1,
                    ),
                    const SizedBox(height: 16),
                    _buildInstructionItem(
                      icon: LucideIcons.move,
                      text: AppLocalizations.of(context)!.stereopsisInstruction2,
                    ),
                    const SizedBox(height: 16),
                    _buildInstructionItem(
                      icon: LucideIcons.mousePointer,
                      text: AppLocalizations.of(context)!.stereopsisInstruction3,
                    ),
                    const SizedBox(height: 16),
                    _buildInstructionItem(
                      icon: LucideIcons.alertCircle,
                      text: AppLocalizations.of(context)!.stereopsisInstruction4,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              AppButton(
                text: AppLocalizations.of(context)!.startButton,
                icon: LucideIcons.play,
                onPressed: _startTest,
                width: double.infinity,
                backgroundColor: AppColors.medicalTeal,
              ),
              const SizedBox(height: 24),
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
    final size = MediaQuery.of(context).size;
    final shapeWidth = (size.width - 48) / 3;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(LucideIcons.x),
          onPressed: () => context.pop(),
        ),
        title: Text(
          AppLocalizations.of(context)!.questionNumber(_currentQuestion + 1, _speedLevels.length),
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (_currentQuestion + 1) / _speedLevels.length,
              backgroundColor: AppColors.backgroundGrey,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.medicalTeal),
              minHeight: 4,
            ),
            
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!_isMoving && _selectedShapeIndex == null)
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          AppLocalizations.of(context)!.stereopsisQuestion,
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    
                    const SizedBox(height: 40),
                    
                    // Three shapes with ball
                    SizedBox(
                      height: 250,
                      child: Stack(
                        children: [
                          // Moving ball (behind shapes)
                          if (_ballPosition != Offset.zero && _isMoving)
                            AnimatedPositioned(
                              duration: Duration(milliseconds: _speedLevels[_currentQuestion]),
                              curve: Curves.easeInOut,
                              left: _ballPosition.dx,
                              top: _ballPosition.dy,
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: AppColors.medicalTeal,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.medicalTeal.withOpacity(0.7),
                                      blurRadius: 20,
                                      spreadRadius: 8,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          
                          // Shapes row (on top of ball)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: _shapes.asMap().entries.map((entry) {
                              final index = entry.key;
                              final shape = entry.value;
                              final isSelected = _selectedShapeIndex == index;
                              final isBallUnder = _isMoving && _currentShapeIndex == index;
                              
                              return GestureDetector(
                                onTap: () => _onShapeSelected(index),
                                child: Container(
                                  width: shapeWidth - 16,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? shape['color'].withOpacity(0.1)
                                        : (isBallUnder ? shape['color'].withOpacity(0.05) : Colors.transparent),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        shape['icon'],
                                        size: 80,
                                        color: shape['color'],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        shape['name'],
                                        style: GoogleFonts.inter(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: shape['color'],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    
                    if (_isMoving)
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          AppLocalizations.of(context)!.stereopsisTracking,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
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
}
