import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:goz_testi/core/theme/app_colors.dart';
import 'package:goz_testi/core/router/app_router.dart';
import 'package:goz_testi/core/widgets/app_button.dart';
import 'package:goz_testi/core/services/sound_service.dart';
import 'package:goz_testi/features/tests/common/utils/test_limit_checker.dart';
import 'package:goz_testi/l10n/app_localizations.dart';

/// Peripheral Vision Test Page - Light Detection Test
enum PeripheralPhase { info, instructions, testing, waiting }

class PeripheralVisionPage extends StatefulWidget {
  const PeripheralVisionPage({super.key});

  @override
  State<PeripheralVisionPage> createState() => _PeripheralVisionPageState();
}

class _PeripheralVisionPageState extends State<PeripheralVisionPage>
    with TickerProviderStateMixin {
  PeripheralPhase _currentPhase = PeripheralPhase.info;
  int _currentRound = 0;
  final int _totalRounds = 12;
  int _correctAnswers = 0;
  int _missedLights = 0;
  List<int> _reactionTimes = [];
  
  // Light state
  bool _isLightVisible = false;
  int? _currentLightPosition; // 0-7 for 8 directions
  DateTime? _lightShowTime;
  Timer? _lightTimer;
  Timer? _waitTimer;
  
  // Animation
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  final Random _random = Random();
  final SoundService _soundService = SoundService();
  
  // 8 directions: top, top-right, right, bottom-right, bottom, bottom-left, left, top-left
  final List<String> _directionNames = [
    'Üst', 'Sağ Üst', 'Sağ', 'Sağ Alt', 'Alt', 'Sol Alt', 'Sol', 'Sol Üst'
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _lightTimer?.cancel();
    _waitTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _onInfoContinue() async {
    final canStart = await TestLimitChecker.canStartTest(context);
    if (!canStart) return;
    
    setState(() {
      _currentPhase = PeripheralPhase.instructions;
    });
  }

  void _startTest() async {
    final canStart = await TestLimitChecker.canStartTest(context);
    if (!canStart) return;
    
    setState(() {
      _currentPhase = PeripheralPhase.testing;
      _currentRound = 0;
      _correctAnswers = 0;
      _missedLights = 0;
      _reactionTimes = [];
    });
    
    _scheduleNextLight();
  }

  void _scheduleNextLight() {
    // Random delay between 1-3 seconds before showing next light
    final delay = 1000 + _random.nextInt(2000);
    
    setState(() {
      _currentPhase = PeripheralPhase.waiting;
      _isLightVisible = false;
      _currentLightPosition = null;
    });
    
    _waitTimer = Timer(Duration(milliseconds: delay), () {
      if (mounted) {
        _showLight();
      }
    });
  }

  void _showLight() {
    // Pick random direction (0-7)
    final position = _random.nextInt(8);
    
    setState(() {
      _currentPhase = PeripheralPhase.testing;
      _isLightVisible = true;
      _currentLightPosition = position;
      _lightShowTime = DateTime.now();
    });
    
    // Light disappears after 2 seconds if not tapped
    _lightTimer = Timer(const Duration(milliseconds: 2000), () {
      if (mounted && _isLightVisible) {
        _onLightMissed();
      }
    });
  }

  void _onLightTapped(int position) {
    if (!_isLightVisible || _currentLightPosition == null) return;
    
    _lightTimer?.cancel();
    
    final isCorrect = position == _currentLightPosition;
    final reactionTime = DateTime.now().difference(_lightShowTime!).inMilliseconds;
    
    if (isCorrect) {
      _correctAnswers++;
      _reactionTimes.add(reactionTime);
      _soundService.playSuccess();
    } else {
      _soundService.playError();
    }
    
    setState(() {
      _isLightVisible = false;
    });
    
    _nextRound();
  }

  void _onLightMissed() {
    _lightTimer?.cancel();
    _missedLights++;
    _soundService.playError();
    
    setState(() {
      _isLightVisible = false;
    });
    
    _nextRound();
  }

  void _nextRound() {
    if (_currentRound < _totalRounds - 1) {
      setState(() {
        _currentRound++;
      });
      _scheduleNextLight();
    } else {
      _finishTest();
    }
  }

  void _finishTest() {
    _lightTimer?.cancel();
    _waitTimer?.cancel();
    
    final percentage = (_correctAnswers / _totalRounds * 100).round();
    final avgReactionTime = _reactionTimes.isNotEmpty
        ? (_reactionTimes.reduce((a, b) => a + b) / _reactionTimes.length).round()
        : 0;
    
    String diagnosis;
    if (percentage >= 90) {
      diagnosis = 'Mükemmel periferik görüş';
    } else if (percentage >= 75) {
      diagnosis = 'Normal periferik görüş';
    } else if (percentage >= 50) {
      diagnosis = 'Hafif periferik görüş sorunu olabilir';
    } else {
      diagnosis = 'Periferik görüş kontrolü için göz doktoruna danışın';
    }
    
    context.pushReplacement(
      AppRoutes.result,
      extra: {
        'testType': 'peripheral_vision',
        'score': _correctAnswers,
        'totalQuestions': _totalRounds,
        'details': {
          'percentage': percentage,
          'diagnosis': diagnosis,
          'correctAnswers': _correctAnswers,
          'totalQuestions': _totalRounds,
          'missedLights': _missedLights,
          'averageReactionTime': avgReactionTime,
        },
      },
    );
  }

  Offset _getLightPosition(int index, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = min(size.width, size.height) * 0.35;
    
    // 8 directions starting from top, going clockwise
    final angles = [
      -pi / 2,           // Top (0)
      -pi / 4,           // Top-right (1)
      0,                  // Right (2)
      pi / 4,            // Bottom-right (3)
      pi / 2,            // Bottom (4)
      3 * pi / 4,        // Bottom-left (5)
      pi,                 // Left (6)
      -3 * pi / 4,       // Top-left (7)
    ];
    
    final angle = angles[index];
    return Offset(
      centerX + radius * cos(angle),
      centerY + radius * sin(angle),
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
      case PeripheralPhase.waiting:
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
        title: Text(l10n.peripheralVisionTitle),
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
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: AppColors.cleanWhite,
      appBar: AppBar(
        backgroundColor: AppColors.cleanWhite,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        title: Text(l10n.peripheralVisionTitle),
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
                    LucideIcons.lightbulb,
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
                      icon: LucideIcons.target,
                      number: '1',
                      text: l10n.peripheralVisionInstruction1,
                    ),
                    const SizedBox(height: 16),
                    _buildInstructionItem(
                      icon: LucideIcons.eye,
                      number: '2',
                      text: l10n.peripheralVisionInstruction2,
                    ),
                    const SizedBox(height: 16),
                    _buildInstructionItem(
                      icon: LucideIcons.zap,
                      number: '3',
                      text: l10n.peripheralVisionInstruction3,
                    ),
                    const SizedBox(height: 16),
                    _buildInstructionItem(
                      icon: LucideIcons.timer,
                      number: '4',
                      text: l10n.peripheralVisionInstruction4,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Visual demo
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  children: [
                    // Center point
                    Center(
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    // Demo light (küçük - kırmızının 1/5'i)
                    Positioned(
                      right: 40,
                      top: 40,
                      child: ScaleTransition(
                        scale: _pulseAnimation,
                        child: Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.yellow,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.yellow.withOpacity(0.9),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Demo text
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Text(
                        l10n.peripheralVisionDemoText,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
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

  Widget _buildInstructionItem({
    required IconData icon,
    required String number,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.medicalBlue,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              number,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTestScreen() {
    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.black,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(LucideIcons.x, color: Colors.white),
                    onPressed: () {
                      _lightTimer?.cancel();
                      _waitTimer?.cancel();
                      context.pop();
                    },
                  ),
                  Text(
                    l10n.questionNumber(_currentRound + 1, _totalRounds),
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '✓ $_correctAnswers',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.successGreen,
                    ),
                  ),
                ],
              ),
            ),
            
            // Progress bar
            LinearProgressIndicator(
              value: (_currentRound + 1) / _totalRounds,
              backgroundColor: Colors.grey[800],
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.medicalBlue),
              minHeight: 4,
            ),
            
            // Test area
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final testSize = Size(constraints.maxWidth, constraints.maxHeight);
                  
                  return Stack(
                    children: [
                      // Touch areas for 8 directions (invisible)
                      ...List.generate(8, (index) {
                        final position = _getLightPosition(index, testSize);
                        return Positioned(
                          left: position.dx - 40,
                          top: position.dy - 40,
                          child: GestureDetector(
                            onTap: () => _onLightTapped(index),
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                shape: BoxShape.circle,
                              ),
                              child: _isLightVisible && _currentLightPosition == index
                                  ? _buildLight()
                                  : null,
                            ),
                          ),
                        );
                      }),
                      
                      // Center fixation point
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withOpacity(0.5),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l10n.peripheralVisionFocusHere,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.white54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Status message
                      Positioned(
                        bottom: 40,
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
                              _isLightVisible
                                  ? l10n.peripheralVisionTapLight
                                  : l10n.peripheralVisionWaiting,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLight() {
    // Sarı ışık kırmızı noktanın 1/5'i kadar (kırmızı 20px, sarı 4px)
    return Center(
      child: Container(
        width: 4,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.yellow,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.yellow.withOpacity(0.8),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }
}
