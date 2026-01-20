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

/// Peripheral Vision Test Page
enum PeripheralPhase { info, instructions, testing }

class PeripheralVisionPage extends StatefulWidget {
  const PeripheralVisionPage({super.key});

  @override
  State<PeripheralVisionPage> createState() => _PeripheralVisionPageState();
}

class _PeripheralVisionPageState extends State<PeripheralVisionPage>
    with SingleTickerProviderStateMixin {
  PeripheralPhase _currentPhase = PeripheralPhase.info;
  int _currentQuestion = 0;
  int _correctAnswers = 0;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  final Random _random = Random();
  // Empty shapes (hollow) - these are the targets
  final List<String> _emptyShapes = ['○', '□', '△', '◇'];
  // Filled shapes - these are distractors
  final List<String> _filledShapes = ['●', '■', '▲', '◆', '★'];
  String? _targetShape;
  List<Offset> _shapePositions = [];
  List<String> _shapeAtPosition = []; // Which shape is at each position
  int? _selectedPosition;
  int? _correctPositionIndex; // Which position has the target shape

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
      _currentPhase = PeripheralPhase.instructions;
    });
  }

  void _startTest() async {
    // Check if user can start test
    final canStart = await TestLimitChecker.canStartTest(context);
    if (!canStart) {
      return; // User chose not to start or limit reached
    }
    
    setState(() {
      _currentPhase = PeripheralPhase.testing;
      _currentQuestion = 0;
      _correctAnswers = 0;
      _generateQuestion();
    });
    _animationController.forward(from: 0);
  }

  void _generateQuestion() {
    // Select random empty (hollow) shape as target
    _targetShape = _emptyShapes[_random.nextInt(_emptyShapes.length)];
    _selectedPosition = null;
    _correctPositionIndex = null;
    _shapeAtPosition = [];
  }
  
  void _calculatePositions(Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    // Distance from center (in pixels) - closer to center
    final distance = 120.0;
    
    // Generate 4 positions: top, right, bottom, left (cardinal directions)
    final positions = [
      Offset(centerX, centerY - distance), // Top
      Offset(centerX + distance, centerY), // Right
      Offset(centerX, centerY + distance), // Bottom
      Offset(centerX - distance, centerY), // Left
    ];
    
    // Select random target position
    _correctPositionIndex = _random.nextInt(4);
    
    // Create list of shapes for each position
    // Target position gets the empty shape, others get filled shapes
    final filledShapesCopy = List<String>.from(_filledShapes);
    filledShapesCopy.shuffle(_random);
    
    _shapeAtPosition = [];
    for (int i = 0; i < 4; i++) {
      if (i == _correctPositionIndex) {
        _shapeAtPosition.add(_targetShape!); // Empty shape at target position
      } else {
        _shapeAtPosition.add(filledShapesCopy[i % filledShapesCopy.length]); // Filled shapes at other positions
      }
    }
    
    // Shuffle positions and shapes together, but track target position
    final positionShapePairs = List.generate(4, (i) => {
      'position': positions[i],
      'shape': _shapeAtPosition[i],
      'isTarget': i == _correctPositionIndex,
    });
    
    positionShapePairs.shuffle(_random);
    
    // Find new index of target after shuffle
    for (int i = 0; i < positionShapePairs.length; i++) {
      if (positionShapePairs[i]['isTarget'] == true) {
        _correctPositionIndex = i;
        break;
      }
    }
    
    _shapePositions = positionShapePairs.map((p) => p['position'] as Offset).toList();
    _shapeAtPosition = positionShapePairs.map((p) => p['shape'] as String).toList();
  }

  void _onPositionSelected(int index) {
    setState(() {
      _selectedPosition = index;
    });
    
    // Check if correct
    if (index == _correctPositionIndex) {
      _correctAnswers++;
    }
    
    // Automatically move to next question
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        if (_currentQuestion < 9) {
          setState(() {
            _currentQuestion++;
            _selectedPosition = null;
            _shapePositions = []; // Reset positions to recalculate
            _generateQuestion();
          });
          _animationController.forward(from: 0);
        } else {
          _finishTest();
        }
      }
    });
  }

  void _finishTest() {
    final percentage = (_correctAnswers / 10 * 100).round();
    String diagnosis;
    
    if (percentage >= 80) {
      diagnosis = 'Periferik görüşünüz normal görünüyor';
    } else if (percentage >= 60) {
      diagnosis = 'Hafif periferik görüş sorunu olabilir';
    } else {
      diagnosis = 'Periferik görüş sorunu var. Göz doktoruna danışın.';
    }
    
    context.pushReplacement(
      AppRoutes.result,
      extra: {
        'testType': 'peripheral_vision',
        'score': _correctAnswers, // Use correct answers count, not percentage
        'totalQuestions': 10,
        'details': {
          'percentage': percentage,
          'diagnosis': diagnosis,
          'correctAnswers': _correctAnswers,
          'totalQuestions': 10,
        },
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (_currentPhase) {
      case PeripheralPhase.info:
        return _buildInfoScreen();
      case PeripheralPhase.instructions:
        return _buildInstructionsScreen();
      case PeripheralPhase.testing:
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
        title: Text(AppLocalizations.of(context)!.peripheralVisionTitle),
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
                    LucideIcons.scan,
                    size: 48,
                    color: AppColors.medicalBlue,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                l10n.peripheralVisionInfoTitle,
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
                      l10n.peripheralVisionInfoDesc,
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
                              l10n.peripheralVisionInfoTip,
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
    return Scaffold(
      backgroundColor: AppColors.cleanWhite,
      appBar: AppBar(
        backgroundColor: AppColors.cleanWhite,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        title: Text(AppLocalizations.of(context)!.peripheralVisionTitle),
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
                    LucideIcons.scan,
                    size: 48,
                    color: AppColors.medicalBlue,
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
                      icon: LucideIcons.target,
                      text: AppLocalizations.of(context)!.peripheralVisionInstruction1,
                    ),
                    const SizedBox(height: 16),
                    _buildInstructionItem(
                      icon: LucideIcons.eye,
                      text: AppLocalizations.of(context)!.peripheralVisionInstruction2,
                    ),
                    const SizedBox(height: 16),
                    _buildInstructionItem(
                      icon: LucideIcons.scan,
                      text: AppLocalizations.of(context)!.peripheralVisionInstruction3,
                    ),
                    const SizedBox(height: 16),
                    _buildInstructionItem(
                      icon: LucideIcons.mousePointer,
                      text: AppLocalizations.of(context)!.peripheralVisionInstruction4,
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
                backgroundColor: AppColors.medicalBlue,
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

  Widget _buildTestScreen() {
    final size = MediaQuery.of(context).size;
    
    // Calculate positions if not already done
    if (_shapePositions.isEmpty || _correctPositionIndex == null || _shapeAtPosition.isEmpty) {
      _calculatePositions(size);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(LucideIcons.x),
          onPressed: () => context.pop(),
        ),
        title: Text(
          AppLocalizations.of(context)!.questionNumber(_currentQuestion + 1, 10),
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (_currentQuestion + 1) / 10,
              backgroundColor: AppColors.backgroundGrey,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.medicalBlue),
              minHeight: 4,
            ),
            
            Expanded(
              child: Stack(
                children: [
                  // Center fixation point
                  Center(
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  
                  // Shapes at peripheral positions
                  if (_shapePositions.isNotEmpty && _targetShape != null && _shapeAtPosition.isNotEmpty)
                    ..._shapePositions.asMap().entries.map((entry) {
                      final index = entry.key;
                      final position = entry.value;
                      final isTarget = index == _correctPositionIndex;
                      final shape = _shapeAtPosition[index];
                      
                      return Positioned(
                        left: position.dx - 30,
                        top: position.dy - 30,
                        child: GestureDetector(
                          onTap: () => _onPositionSelected(index),
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: _selectedPosition == index
                                  ? AppColors.medicalBlue
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _selectedPosition == index
                                    ? AppColors.medicalBlue
                                    : AppColors.borderLight,
                                width: _selectedPosition == index ? 3 : 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                shape,
                                style: GoogleFonts.inter(
                                  fontSize: 32,
                                  color: _selectedPosition == index
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  
                  // Instruction text
                  Positioned(
                    bottom: 100,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.peripheralVisionQuestion,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

