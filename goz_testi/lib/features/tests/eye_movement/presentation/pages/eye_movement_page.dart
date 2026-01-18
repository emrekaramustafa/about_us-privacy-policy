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

/// Eye Movement (Smooth Pursuit) Test Page
enum EyeMovementPhase { info, instructions, testing }

class EyeMovementPage extends StatefulWidget {
  const EyeMovementPage({super.key});

  @override
  State<EyeMovementPage> createState() => _EyeMovementPageState();
}

class _EyeMovementPageState extends State<EyeMovementPage>
    with SingleTickerProviderStateMixin {
  EyeMovementPhase _currentPhase = EyeMovementPhase.info;
  int _currentQuestion = 0;
  int _correctAnswers = 0;
  
  late AnimationController _animationController;
  
  Offset _ballPosition = Offset.zero;
  Offset _ballVelocity = Offset.zero;
  bool _isMoving = false;
  bool? _canFollow;
  Timer? _movementTimer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _movementTimer?.cancel();
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
      _currentPhase = EyeMovementPhase.instructions;
    });
  }

  void _startTest() async {
    // Check if user can start test
    final canStart = await TestLimitChecker.canStartTest(context);
    if (!canStart) {
      return; // User chose not to start or limit reached
    }
    
    setState(() {
      _currentPhase = EyeMovementPhase.testing;
      _currentQuestion = 0;
      _correctAnswers = 0;
      _startMovement();
    });
  }

  void _startMovement() {
    if (!mounted) return;
    
    final size = MediaQuery.of(context).size;
    final ballRadius = 18.0; // Smaller ball - harder to track
    
    // Cancel previous timer if exists
    _movementTimer?.cancel();
    
    // Calculate speed based on question number (faster each question)
    // Start faster and increase more aggressively
    final baseSpeed = 600.0 + (_currentQuestion * 150.0); // Starts at 600, increases by 150 each question
    
    // Random initial position
    // Leave space at bottom for buttons and safe area (about 200px from bottom)
    final bottomLimit = size.height - ballRadius - 200;
    final random = Random(_currentQuestion * 7);
    _ballPosition = Offset(
      ballRadius + random.nextDouble() * (size.width - ballRadius * 2),
      ballRadius + random.nextDouble() * (bottomLimit - ballRadius),
    );
    
    // Random initial velocity
    final angle = random.nextDouble() * 2 * pi;
    _ballVelocity = Offset(
      cos(angle) * baseSpeed,
      sin(angle) * baseSpeed,
    );
    
    setState(() {
      _isMoving = true;
      _canFollow = null;
    });
    
    // Movement duration: shorter and gets shorter each question
    final duration = 3500 - (_currentQuestion * 300); // 3.5s, 3.2s, 2.9s, 2.6s, 2.3s
    final startTime = DateTime.now();
    final screenSize = size; // Capture size for timer
    
    _movementTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      final elapsed = DateTime.now().difference(startTime).inMilliseconds;
      if (elapsed >= duration) {
        timer.cancel();
        if (mounted) {
          setState(() {
            _isMoving = false;
          });
        }
        return;
      }
      
      final deltaTime = 0.016; // 16ms = ~60fps
      final directionRandom = Random(_currentQuestion * 7 + elapsed); // Random for direction changes
      
      // Add complexity: occasional sudden direction changes (zigzag pattern)
      final elapsedRatio = elapsed / duration;
      final shouldChangeDirection = (elapsedRatio * 10).floor() % 3 == 0 && 
                                     directionRandom.nextDouble() < 0.12; // 12% chance every ~0.3s
      
      // Update position
      var newX = _ballPosition.dx + _ballVelocity.dx * deltaTime;
      var newY = _ballPosition.dy + _ballVelocity.dy * deltaTime;
      var newVelX = _ballVelocity.dx;
      var newVelY = _ballVelocity.dy;
      
      // Sudden direction change for complexity (after initial 0.5s)
      if (shouldChangeDirection && elapsed > 500) {
        final newAngle = directionRandom.nextDouble() * 2 * pi;
        final currentSpeed = sqrt(newVelX * newVelX + newVelY * newVelY);
        newVelX = cos(newAngle) * currentSpeed;
        newVelY = sin(newAngle) * currentSpeed;
      }
      
      // Bounce off walls with slight speed increase
      // Leave space at bottom for buttons and safe area (about 200px from bottom)
      final bottomLimit = screenSize.height - ballRadius - 200;
      
      if (newX <= ballRadius || newX >= screenSize.width - ballRadius) {
        newVelX = -newVelX * 1.05; // Slight speed increase on bounce
        newX = newX <= ballRadius ? ballRadius : screenSize.width - ballRadius;
      }
      if (newY <= ballRadius || newY >= bottomLimit) {
        newVelY = -newVelY * 1.05; // Slight speed increase on bounce
        newY = newY <= ballRadius ? ballRadius : bottomLimit;
      }
      
      if (mounted) {
        setState(() {
          _ballPosition = Offset(newX, newY);
          _ballVelocity = Offset(newVelX, newVelY);
        });
      }
    });
  }

  void _onAnswerSelected(bool canFollow) {
    setState(() {
      _canFollow = canFollow;
    });
    
    // Normal vision should be able to follow (canFollow = true)
    if (canFollow) {
      _correctAnswers++;
    }
    
    // Automatically move to next question
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _movementTimer?.cancel();
        if (_currentQuestion < 4) {
          setState(() {
            _currentQuestion++;
          });
          _startMovement();
        } else {
          _finishTest();
        }
      }
    });
  }

  void _finishTest() {
    final percentage = (_correctAnswers / 5 * 100).round();
    String diagnosis;
    
    if (percentage >= 80) {
      diagnosis = 'Göz hareket takip yeteneğiniz normal görünüyor';
    } else if (percentage >= 60) {
      diagnosis = 'Hafif göz hareket sorunu olabilir';
    } else {
      diagnosis = 'Göz hareket sorunu var. Göz doktoruna danışın.';
    }
    
    context.pushReplacement(
      AppRoutes.result,
      extra: {
        'testType': 'eye_movement',
        'score': _correctAnswers, // Use correct answers count, not percentage
        'totalQuestions': 5,
        'details': {
          'percentage': percentage,
          'diagnosis': diagnosis,
          'correctAnswers': _correctAnswers,
          'totalQuestions': 5,
        },
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (_currentPhase) {
      case EyeMovementPhase.info:
        return _buildInfoScreen();
      case EyeMovementPhase.instructions:
        return _buildInstructionsScreen();
      case EyeMovementPhase.testing:
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
        title: const Text('Hareket Takip Testi'),
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
                  color: AppColors.premiumGoldPale,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    LucideIcons.move,
                    size: 48,
                    color: AppColors.premiumGold,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Hareket Takip Testi Nedir?',
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
                      'Smooth pursuit (düzgün takip) testi, gözlerin hareket eden nesneleri takip etme yeteneğini ölçer. Bu test, göz kası koordinasyonu ve nörolojik sorunları değerlendirmeye yardımcı olur.',
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
                              'Sağlıklı bir birey, hareket eden nesneyi başını hareket ettirmeden sadece gözleriyle takip edebilmelidir.',
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
                text: 'Devam Et',
                icon: LucideIcons.arrowRight,
                onPressed: _onInfoContinue,
                width: double.infinity,
                backgroundColor: AppColors.premiumGold,
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
        title: const Text('Hareket Takip Testi'),
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
                  color: AppColors.premiumGoldPale,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    LucideIcons.move,
                    size: 48,
                    color: AppColors.premiumGold,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Test Talimatları',
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
                      text: 'Her iki gözünüzü açık tutun',
                    ),
                    const SizedBox(height: 16),
                    _buildInstructionItem(
                      icon: LucideIcons.move,
                      text: 'Hareket eden topu sadece gözlerinizle takip edin',
                    ),
                    const SizedBox(height: 16),
                    _buildInstructionItem(
                      icon: LucideIcons.ban,
                      text: 'Başınızı hareket ettirmeyin',
                    ),
                    const SizedBox(height: 16),
                    _buildInstructionItem(
                      icon: LucideIcons.mousePointer,
                      text: 'Topu takip edip edemediğinizi belirtin',
                    ),
                  ],
                ),
              ),
              const Spacer(),
              AppButton(
                text: 'Testi Başlat',
                icon: LucideIcons.play,
                onPressed: _startTest,
                width: double.infinity,
                backgroundColor: AppColors.premiumGold,
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
            color: AppColors.premiumGoldPale,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: AppColors.premiumGold),
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(LucideIcons.x),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Soru ${_currentQuestion + 1} / 5',
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (_currentQuestion + 1) / 5,
              backgroundColor: AppColors.backgroundGrey,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.premiumGold),
              minHeight: 4,
            ),
            
            Expanded(
              child: Stack(
                children: [
                  // Moving ball
                  if (_ballPosition != Offset.zero)
                    Positioned(
                      left: _ballPosition.dx - 18,
                      top: _ballPosition.dy - 18,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.premiumGold,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.premiumGold.withOpacity(0.5),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                      ),
                    ),
                  
                  // Instruction
                  if (!_isMoving && _canFollow == null)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Topu takip edebildiniz mi?',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  
                  // Options (shown after movement)
                  if (!_isMoving && _canFollow == null)
                    Positioned(
                      bottom: 100,
                      left: 0,
                      right: 0,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            AppButton(
                              text: 'Evet, Takip Edebiliyorum',
                              icon: LucideIcons.check,
                              onPressed: () => _onAnswerSelected(true),
                              width: double.infinity,
                              backgroundColor: AppColors.successGreen,
                            ),
                            
                            const SizedBox(height: 16),
                            
                            AppButton(
                              text: 'Hayır, Takip Edemiyorum',
                              icon: LucideIcons.x,
                              onPressed: () => _onAnswerSelected(false),
                              width: double.infinity,
                              isOutlined: true,
                              backgroundColor: AppColors.errorRed,
                              textColor: AppColors.errorRed,
                            ),
                          ],
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

