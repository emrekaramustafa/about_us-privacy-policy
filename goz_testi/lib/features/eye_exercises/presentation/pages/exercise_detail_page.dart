import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:goz_testi/core/theme/app_colors.dart';
import 'package:goz_testi/core/router/app_router.dart';
import 'package:goz_testi/core/widgets/app_button.dart';
import 'package:goz_testi/features/eye_exercises/domain/models/exercise_model.dart';
import 'package:goz_testi/features/eye_exercises/domain/models/exercise_localizations.dart';
import 'package:goz_testi/features/eye_exercises/presentation/pages/exercise_completion_page.dart';
import 'package:goz_testi/l10n/app_localizations.dart';

/// Exercise Detail Page
/// Shows individual exercise with animations
class ExerciseDetailPage extends StatefulWidget {
  final ExerciseModel exercise;
  final String profile;
  final int exerciseIndex;
  final int totalExercises;

  const ExerciseDetailPage({
    super.key,
    required this.exercise,
    required this.profile,
    required this.exerciseIndex,
    required this.totalExercises,
  });

  @override
  State<ExerciseDetailPage> createState() => _ExerciseDetailPageState();
}

class _ExerciseDetailPageState extends State<ExerciseDetailPage>
    with TickerProviderStateMixin {
  late AnimationController _mainAnimationController;
  late AnimationController _glowController;
  late AnimationController _particleController;
  Timer? _timer;
  int _currentRepetition = 0;
  int _elapsedSeconds = 0;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    // Main animation with dynamic curves
    _mainAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    
    // Glow pulse animation
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);
    
    // Particle animation
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _startExercise();
  }

  void _startExercise() {
    // Yetişkin ve çocuk profilleri için timer başlatma - kullanıcı kendi hızında yapacak
    if (widget.profile == 'adult' || widget.profile == 'child') {
      return;
    }
    
    if (widget.exercise.duration > 0) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            _elapsedSeconds++;
            if (_elapsedSeconds >= widget.exercise.duration) {
              _completeExercise();
            }
          });
        }
      });
    }
  }

  void _completeExercise() {
    setState(() {
      _isCompleted = true;
    });
    _timer?.cancel();
    _mainAnimationController.stop();
  }

  void _onNext() {
    // Yetişkin ve çocuk profilleri için direkt sonraki egzersize geç
    if (widget.profile == 'adult' || widget.profile == 'child') {
      _navigateToNext();
      return;
    }

    // Ofis profili için eski mantık
    if (!_isCompleted) {
      if (widget.exercise.repetitions > 0) {
        setState(() {
          _currentRepetition++;
          if (_currentRepetition >= widget.exercise.repetitions) {
            _completeExercise();
          }
        });
      } else {
        _completeExercise();
      }
    } else {
      _navigateToNext();
    }
  }

  void _navigateToNext() {
    if (widget.exerciseIndex < widget.totalExercises - 1) {
      // Get next exercise
      List<ExerciseModel> exercises;
      switch (widget.profile) {
        case 'child':
          exercises = ExerciseData.getChildExercises();
          break;
        case 'adult':
          exercises = ExerciseData.getAdultExercises();
          break;
        case 'office':
          exercises = ExerciseData.getOfficeExercises();
          break;
        default:
          exercises = ExerciseData.getAdultExercises();
      }

      context.pushReplacement(
        AppRoutes.exerciseDetail,
        extra: {
          'exercise': exercises[widget.exerciseIndex + 1],
          'profile': widget.profile,
          'exerciseIndex': widget.exerciseIndex + 1,
          'totalExercises': widget.totalExercises,
        },
      );
    } else {
      // All exercises completed
      context.pushReplacement(
        AppRoutes.exerciseCompletion,
        extra: {'profile': widget.profile},
      );
    }
  }

  @override
  void dispose() {
    _mainAnimationController.dispose();
    _glowController.dispose();
    _particleController.dispose();
    _timer?.cancel();
    super.dispose();
  }
  
  // Helper method to get animation curve based on exercise type
  Curve _getAnimationCurve() {
    switch (widget.exercise.type) {
      case ExerciseType.blink:
      case ExerciseType.fastSlow:
        return Curves.elasticOut;
      case ExerciseType.nearFar:
      case ExerciseType.fingerTracking:
        return Curves.easeInOutBack;
      case ExerciseType.leftRight:
        return Curves.easeInOutSine; // Döngüsel hareket için
      case ExerciseType.upDown:
        return Curves.easeInOutSine; // Döngüsel hareket için
      case ExerciseType.circle:
      case ExerciseType.figureEight:
        return Curves.easeInOutCubic;
      default:
        return Curves.easeInOut;
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.exercise.duration > 0
        ? _elapsedSeconds / widget.exercise.duration
        : widget.exercise.repetitions > 0
            ? _currentRepetition / widget.exercise.repetitions
            : 0.0;

    return Scaffold(
      backgroundColor: AppColors.cleanWhite,
      body: SafeArea(
        child: Column(
          children: [
            // Enhanced Progress Bar
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.backgroundGrey,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: (widget.exerciseIndex + 1) / widget.totalExercises,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.medicalBlue,
                        AppColors.medicalTeal,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.medicalBlue.withOpacity(0.4),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Header
            LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = MediaQuery.of(context).size.width;
                final isSmallScreen = screenWidth < 400;
                final headerPadding = isSmallScreen ? 16.0 : 24.0;
                
                return Padding(
                  padding: EdgeInsets.all(headerPadding),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(LucideIcons.arrowLeft),
                        onPressed: () => context.pop(),
                      ),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.exerciseNumber(widget.exerciseIndex + 1, widget.totalExercises),
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(width: isSmallScreen ? 24 : 48),
                    ],
                  ),
                );
              },
            ),
            // Exercise Content
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final screenWidth = MediaQuery.of(context).size.width;
                  final isSmallScreen = screenWidth < 400;
                  final animationSize = isSmallScreen ? screenWidth * 0.7 : 280.0;
                  final spacing = isSmallScreen ? 16.0 : 24.0;
                  
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(spacing),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: isSmallScreen ? 10 : 20),
                        // Title - Animasyonun üstüne
                        Text(
                          ExerciseLocalizations.getTitle(context, widget.exercise.id),
                          style: GoogleFonts.inter(
                            fontSize: isSmallScreen ? 24 : 28,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: isSmallScreen ? 20 : 32),
                        // Large Animation Area with Gradient Background
                        Container(
                          width: animationSize,
                          height: animationSize,
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: [
                                _getExerciseColor().withOpacity(0.15),
                                _getExerciseColor().withOpacity(0.05),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.5, 1.0],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: _buildExerciseAnimation(),
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 16 : 24),
                        // Description Card with Shadow
                        Container(
                          padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _getExerciseColor().withOpacity(0.2),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _getExerciseColor().withOpacity(0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                          child: Text(
                            _getDescriptionWithRepetition(),
                            style: GoogleFonts.inter(
                              fontSize: isSmallScreen ? 16 : 18,
                              height: 1.6,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        // Benefit (Ne işe yarar?) - Enhanced
                        if (ExerciseLocalizations.getBenefit(context, widget.exercise.id) != null && ExerciseLocalizations.getBenefit(context, widget.exercise.id)!.isNotEmpty) ...[
                          SizedBox(height: isSmallScreen ? 16 : 20),
                          Container(
                            padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.medicalTeal.withOpacity(0.15),
                              AppColors.medicalBlue.withOpacity(0.1),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.medicalTeal.withOpacity(0.4),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.medicalTeal.withOpacity(0.1),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                              decoration: BoxDecoration(
                                color: AppColors.medicalTeal.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                LucideIcons.sparkles,
                                size: isSmallScreen ? 18 : 22,
                                color: AppColors.medicalTeal,
                              ),
                            ),
                            SizedBox(width: isSmallScreen ? 12 : 16),
                            Expanded(
                              child: Text(
                                ExerciseLocalizations.getBenefit(context, widget.exercise.id) ?? '',
                                style: GoogleFonts.inter(
                                  fontSize: isSmallScreen ? 13 : 15,
                                  height: 1.5,
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    SizedBox(height: isSmallScreen ? 20 : 32),
                    // Counter/Timer - Tüm profiller için göster (bilgi amaçlı)
                    _buildCounter(),
                    SizedBox(height: isSmallScreen ? 16 : 24),
                    // Progress Indicator (sadece ofis için)
                    if (widget.profile != 'adult' && widget.profile != 'child' && progress > 0)
                      Container(
                        width: 200,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.backgroundGrey,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: progress,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.medicalBlue,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Next Button
            Builder(
              builder: (context) {
                final screenWidth = MediaQuery.of(context).size.width;
                final isSmallScreen = screenWidth < 400;
                final buttonPadding = isSmallScreen ? 16.0 : 24.0;
                
                final l10n = AppLocalizations.of(context)!;
                
                if (widget.profile == 'adult' || widget.profile == 'child') {
                  // Yetişkin ve çocuk profilleri: "Sonraki" butonu her zaman görünür
                  return Padding(
                    padding: EdgeInsets.all(buttonPadding),
                    child: AppButton(
                      text: widget.exerciseIndex < widget.totalExercises - 1
                          ? l10n.exerciseNext
                          : l10n.exerciseComplete,
                      icon: LucideIcons.arrowRight,
                      onPressed: _onNext,
                      backgroundColor: AppColors.medicalBlue,
                    ),
                  );
                } else {
                  return Padding(
                    padding: EdgeInsets.all(buttonPadding),
                    child: AppButton(
                      text: _isCompleted
                          ? widget.exerciseIndex < widget.totalExercises - 1
                              ? l10n.exerciseNext
                              : l10n.exerciseComplete
                          : widget.exercise.repetitions > 0
                              ? l10n.exerciseDone(_currentRepetition, widget.exercise.repetitions)
                              : widget.exercise.duration > 0
                                  ? l10n.continueText
                                  : l10n.exerciseStart,
                      icon: _isCompleted
                          ? LucideIcons.arrowRight
                          : widget.exercise.repetitions > 0
                              ? LucideIcons.check
                              : LucideIcons.play,
                      onPressed: _onNext,
                      backgroundColor: AppColors.medicalBlue,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseAnimation() {
    switch (widget.exercise.type) {
      case ExerciseType.blink:
        return _BlinkAnimation(
          controller: _mainAnimationController,
          glowController: _glowController,
          particleController: _particleController,
        );
      case ExerciseType.nearFar:
        return _NearFarAnimation(
          controller: _mainAnimationController,
          glowController: _glowController,
          particleController: _particleController,
        );
      case ExerciseType.figureEight:
        return _FigureEightAnimation(
          controller: _mainAnimationController,
          glowController: _glowController,
        );
      case ExerciseType.leftRight:
        return _LeftRightAnimation(
          controller: _mainAnimationController,
          glowController: _glowController,
        );
      case ExerciseType.upDown:
        return _UpDownAnimation(
          controller: _mainAnimationController,
          glowController: _glowController,
        );
      case ExerciseType.circle:
        return _CircleAnimation(
          controller: _mainAnimationController,
          glowController: _glowController,
        );
      case ExerciseType.rest:
        return _RestAnimation(
          controller: _mainAnimationController,
          glowController: _glowController,
        );
      case ExerciseType.cloud:
        return _CloudAnimation(
          controller: _mainAnimationController,
          glowController: _glowController,
        );
      case ExerciseType.fastSlow:
        return _FastSlowAnimation(
          controller: _mainAnimationController,
          glowController: _glowController,
        );
      case ExerciseType.happy:
        return _HappyAnimation(
          controller: _mainAnimationController,
          glowController: _glowController,
        );
      case ExerciseType.fingerTracking:
        return _FingerTrackingAnimation(
          controller: _mainAnimationController,
          glowController: _glowController,
        );
      case ExerciseType.peripheral:
        return _PeripheralAnimation(
          controller: _mainAnimationController,
          glowController: _glowController,
        );
      case ExerciseType.palming:
        return _PalmingAnimation(
          controller: _mainAnimationController,
          glowController: _glowController,
        );
      case ExerciseType.breathing:
        return _BreathingAnimation(
          controller: _mainAnimationController,
          glowController: _glowController,
        );
      case ExerciseType.neckReset:
        return _NeckResetAnimation(
          controller: _mainAnimationController,
          glowController: _glowController,
        );
    }
  }
  
  Color _getExerciseColor() {
    switch (widget.exercise.type) {
      case ExerciseType.blink:
      case ExerciseType.fingerTracking:
      case ExerciseType.neckReset:
        return AppColors.medicalBlue;
      case ExerciseType.nearFar:
      case ExerciseType.figureEight:
      case ExerciseType.rest:
      case ExerciseType.cloud:
      case ExerciseType.happy:
      case ExerciseType.peripheral:
      case ExerciseType.palming:
      case ExerciseType.breathing:
        return AppColors.medicalTeal;
      case ExerciseType.fastSlow:
        return AppColors.premiumGold;
      default:
        return AppColors.medicalBlue;
    }
  }

  String _getDescriptionWithRepetition() {
    final l10n = AppLocalizations.of(context)!;
    String description = ExerciseLocalizations.getDescription(context, widget.exercise.id);
    
    // Çocuk profili için tekrar sayısını açıklamanın sonuna ekle
    if (widget.profile == 'child') {
      if (widget.exercise.repetitions > 0) {
        description = '$description (${widget.exercise.repetitions} ${l10n.repetitionText})';
      } else if (widget.exercise.duration > 0) {
        description = '$description (${widget.exercise.duration} ${l10n.secondText})';
      }
    }
    
    return description;
  }

  Widget _buildCounter() {
    // Çocuk profili için counter'ı gösterme (açıklamanın içinde)
    if (widget.profile == 'child') {
      return const SizedBox.shrink();
    }
    
    final l10n = AppLocalizations.of(context)!;
    
    // Yetişkin profili için tekrar sayısını göster (sadece bilgi amaçlı)
    if (widget.profile == 'adult') {
      if (widget.exercise.repetitions > 0) {
        return Text(
          '${widget.exercise.repetitions} ${l10n.repetitionText}',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.medicalBlue,
          ),
        );
      } else if (widget.exercise.duration > 0) {
        return Text(
          '${widget.exercise.duration} ${l10n.secondText}',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.medicalBlue,
          ),
        );
      }
      return const SizedBox.shrink();
    }
    
    // Ofis profili için eski mantık (kalan tekrar/süre)
    if (widget.exercise.repetitions > 0) {
      return Text(
        '${widget.exercise.repetitions - _currentRepetition} ${l10n.repetitionText} ${l10n.remainingText}',
        style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.medicalBlue,
        ),
      );
    } else if (widget.exercise.duration > 0) {
      return Text(
        '${widget.exercise.duration - _elapsedSeconds} ${l10n.secondText} ${l10n.remainingText}',
        style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.medicalBlue,
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

// Animation Widgets
class _BlinkAnimation extends StatelessWidget {
  final AnimationController controller;
  final AnimationController glowController;
  final AnimationController particleController;

  const _BlinkAnimation({
    required this.controller,
    required this.glowController,
    required this.particleController,
  });

  @override
  Widget build(BuildContext context) {
    final curve = CurvedAnimation(parent: controller, curve: Curves.elasticOut);
    final glowCurve = CurvedAnimation(parent: glowController, curve: Curves.easeInOut);
    
    return AnimatedBuilder(
      animation: Listenable.merge([controller, glowController, particleController]),
      builder: (context, child) {
        final scale = 0.7 + (curve.value * 0.5); // 0.7 -> 1.2 (bounce effect)
        final glowIntensity = 0.3 + (glowCurve.value * 0.4);
        
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer glow rings
            ...List.generate(3, (index) {
              final delay = index * 0.2;
              final adjustedValue = ((glowCurve.value + delay) % 1.0);
              return Transform.scale(
                scale: 1.0 + (adjustedValue * 0.6),
                child: Container(
                  width: 180 + (index * 20),
                  height: 180 + (index * 20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.medicalBlue.withOpacity(glowIntensity * (1.0 - index * 0.3)),
                      width: 2,
                    ),
                  ),
                ),
              );
            }),
            // Main icon with shadow and glow
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.medicalBlue.withOpacity(glowIntensity * 0.8),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                  BoxShadow(
                    color: AppColors.medicalTeal.withOpacity(glowIntensity * 0.5),
                    blurRadius: 50,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Transform.scale(
                scale: scale,
                child: Icon(
                  LucideIcons.eye,
                  size: 160,
                  color: AppColors.medicalBlue,
                ),
              ),
            ),
            // Particle sparkles
            ...List.generate(6, (index) {
              final angle = (index * 60) * 3.14159 / 180;
              final distance = 80 + (glowCurve.value * 20);
              final x = distance * (glowCurve.value * 2 - 1) * (index.isEven ? 1 : -1);
              final y = distance * (glowCurve.value * 2 - 1) * (index.isOdd ? 1 : -1);
              return Positioned(
                left: 140 + x,
                top: 140 + y,
                child: Opacity(
                  opacity: (1.0 - glowCurve.value).clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: 0.3 + (glowCurve.value * 0.7),
                    child: Icon(
                      LucideIcons.sparkle,
                      size: 16,
                      color: AppColors.medicalBlue.withOpacity(0.8),
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

class _NearFarAnimation extends StatelessWidget {
  final AnimationController controller;
  final AnimationController glowController;
  final AnimationController particleController;

  const _NearFarAnimation({
    required this.controller,
    required this.glowController,
    required this.particleController,
  });

  @override
  Widget build(BuildContext context) {
    // Döngüsel yakın-uzak hareket için easeInOut kullan
    final curve = CurvedAnimation(parent: controller, curve: Curves.easeInOut);
    final glowCurve = CurvedAnimation(parent: glowController, curve: Curves.easeInOut);
    
    return AnimatedBuilder(
      animation: Listenable.merge([controller, glowController, particleController]),
      builder: (context, child) {
        // Parmak yaklaşır ve uzaklaşır (döngüsel)
        // 0.0 -> 0.5: yaklaşır (büyür), 0.5 -> 1.0: uzaklaşır (küçülür)
        final scale = curve.value < 0.5
            ? 0.6 + (curve.value * 2 * 0.9) // 0.6 -> 1.5 (yaklaşır)
            : 1.5 - ((curve.value - 0.5) * 2 * 0.9); // 1.5 -> 0.6 (uzaklaşır)
        final glowIntensity = 0.4 + (glowCurve.value * 0.4);
        
        return Stack(
          alignment: Alignment.center,
          children: [
            // Glow trail
            Transform.scale(
              scale: scale * 0.8,
              child: Opacity(
                opacity: glowIntensity * 0.5,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.medicalTeal.withOpacity(glowIntensity),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Main finger icon - yaklaşır ve uzaklaşır
            Transform.scale(
              scale: scale,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.medicalTeal.withOpacity(glowIntensity * 0.8),
                      blurRadius: 25,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: Icon(
                  LucideIcons.pointer,
                  size: 140,
                  color: AppColors.medicalTeal,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FigureEightAnimation extends StatelessWidget {
  final AnimationController controller;
  final AnimationController glowController;

  const _FigureEightAnimation({
    required this.controller,
    required this.glowController,
  });

  @override
  Widget build(BuildContext context) {
    final curve = CurvedAnimation(parent: controller, curve: Curves.easeInOutCubic);
    final glowCurve = CurvedAnimation(parent: glowController, curve: Curves.easeInOut);
    
    return AnimatedBuilder(
      animation: Listenable.merge([controller, glowController]),
      builder: (context, child) {
        final glowIntensity = 0.4 + (glowCurve.value * 0.4);
        
        return Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.medicalTeal.withOpacity(glowIntensity * 0.6),
                blurRadius: 40,
                spreadRadius: 10,
              ),
            ],
          ),
          child: CustomPaint(
            size: const Size(200, 200),
            painter: _EightPainter(
              progress: curve.value,
              glowIntensity: glowIntensity,
            ),
          ),
        );
      },
    );
  }
}

class _EightPainter extends CustomPainter {
  final double progress;
  final double glowIntensity;

  _EightPainter({
    required this.progress,
    required this.glowIntensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 4;

    // Glow effect (outer)
    final glowPaint = Paint()
      ..color = AppColors.medicalTeal.withOpacity(glowIntensity * 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    // Main paint with gradient effect
    final paint = Paint()
      ..color = AppColors.medicalTeal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    // Draw figure 8 with animated path (YATAY - yan çevrilmiş)
    final path = Path();
    // Sol daire (yatay sekiz için)
    final leftCircle = Rect.fromCircle(
      center: Offset(center.dx - radius / 2, center.dy),
      radius: radius / 2,
    );
    // Sağ daire (yatay sekiz için)
    final rightCircle = Rect.fromCircle(
      center: Offset(center.dx + radius / 2, center.dy),
      radius: radius / 2,
    );

    // Animated drawing - yatay sekiz
    if (progress < 0.5) {
      // Sol daireyi çiz
      final leftProgress = progress * 2;
      path.addArc(leftCircle, 0, leftProgress * 2 * 3.14159);
    } else {
      // Her iki daireyi çiz
      path.addOval(leftCircle);
      final rightProgress = (progress - 0.5) * 2;
      path.addArc(rightCircle, 0, rightProgress * 2 * 3.14159);
    }

    // Draw glow
    canvas.drawPath(path, glowPaint);
    // Draw main path
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _LeftRightAnimation extends StatelessWidget {
  final AnimationController controller;
  final AnimationController glowController;

  const _LeftRightAnimation({
    required this.controller,
    required this.glowController,
  });

  @override
  Widget build(BuildContext context) {
    // Döngüsel hareket için easeInOutSine kullan
    final curve = CurvedAnimation(parent: controller, curve: Curves.easeInOutSine);
    final glowCurve = CurvedAnimation(parent: glowController, curve: Curves.easeInOut);
    
    return AnimatedBuilder(
      animation: Listenable.merge([controller, glowController]),
      builder: (context, child) {
        // Döngüsel sağa-sola hareket: -80'den +80'e yumuşak geçiş
        final offset = -80 + (curve.value * 160);
        final glowIntensity = 0.4 + (glowCurve.value * 0.4);
        
        return Stack(
          alignment: Alignment.center,
          children: [
            // Glow trail
            Transform.translate(
              offset: Offset(offset * 0.7, 0),
              child: Opacity(
                opacity: glowIntensity * 0.5,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.medicalBlue.withOpacity(glowIntensity),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Main eye icon
            Transform.translate(
              offset: Offset(offset, 0),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.medicalBlue.withOpacity(glowIntensity * 0.8),
                      blurRadius: 25,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: Icon(
                  LucideIcons.eye,
                  size: 140,
                  color: AppColors.medicalBlue,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _UpDownAnimation extends StatelessWidget {
  final AnimationController controller;
  final AnimationController glowController;

  const _UpDownAnimation({
    required this.controller,
    required this.glowController,
  });

  @override
  Widget build(BuildContext context) {
    // Döngüsel hareket için easeInOutSine kullan
    final curve = CurvedAnimation(parent: controller, curve: Curves.easeInOutSine);
    final glowCurve = CurvedAnimation(parent: glowController, curve: Curves.easeInOut);
    
    return AnimatedBuilder(
      animation: Listenable.merge([controller, glowController]),
      builder: (context, child) {
        // Döngüsel yukarı-aşağı hareket: -50'den +50'ye yumuşak geçiş
        final offset = -50 + (curve.value * 100);
        final glowIntensity = 0.4 + (glowCurve.value * 0.4);
        
        return Stack(
          alignment: Alignment.center,
          children: [
            // Glow trail
            Transform.translate(
              offset: Offset(0, offset * 0.7),
              child: Opacity(
                opacity: glowIntensity * 0.5,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.medicalBlue.withOpacity(glowIntensity),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Main icon
            Transform.translate(
              offset: Offset(0, offset),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.medicalBlue.withOpacity(glowIntensity * 0.8),
                      blurRadius: 25,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: Icon(
                  LucideIcons.arrowUpDown,
                  size: 140,
                  color: AppColors.medicalBlue,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CircleAnimation extends StatelessWidget {
  final AnimationController controller;
  final AnimationController glowController;

  const _CircleAnimation({
    required this.controller,
    required this.glowController,
  });

  @override
  Widget build(BuildContext context) {
    // Döngüsel hareket için linear curve kullan (sürekli dönüş için)
    final curve = CurvedAnimation(parent: controller, curve: Curves.linear);
    final glowCurve = CurvedAnimation(parent: glowController, curve: Curves.easeInOut);
    
    return AnimatedBuilder(
      animation: Listenable.merge([controller, glowController]),
      builder: (context, child) {
        // Top'un halka üzerinde dönmesi için açı
        final angle = curve.value * 2 * 3.14159;
        final glowIntensity = 0.4 + (glowCurve.value * 0.4);
        
        // En geniş halka (index 2): radius = (160 + 2*30) / 2 = 110
        final largestRingRadius = 110.0;
        
        // Top'un pozisyonu (en geniş halka üzerinde)
        final ballX = largestRingRadius * math.cos(angle);
        final ballY = largestRingRadius * math.sin(angle);
        
        return Stack(
          alignment: Alignment.center,
          children: [
            // Rotating glow rings (3 halka)
            ...List.generate(3, (index) {
              return Container(
                width: 160 + (index * 30),
                height: 160 + (index * 30),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.medicalBlue.withOpacity(glowIntensity * (1.0 - index * 0.25)),
                    width: 2,
                  ),
                ),
              );
            }),
            // Top (en geniş halka üzerinde dönen)
            Transform.translate(
              offset: Offset(ballX, ballY),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.medicalBlue,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.medicalBlue.withOpacity(glowIntensity * 0.8),
                      blurRadius: 15,
                      spreadRadius: 3,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _RestAnimation extends StatelessWidget {
  final AnimationController controller;
  final AnimationController glowController;

  const _RestAnimation({
    required this.controller,
    required this.glowController,
  });

  @override
  Widget build(BuildContext context) {
    final curve = CurvedAnimation(parent: controller, curve: Curves.easeInOut);
    final glowCurve = CurvedAnimation(parent: glowController, curve: Curves.easeInOut);
    
    return AnimatedBuilder(
      animation: Listenable.merge([controller, glowController]),
      builder: (context, child) {
        final opacity = 0.4 + (curve.value * 0.4);
        final glowIntensity = 0.3 + (glowCurve.value * 0.5);
        final scale = 0.95 + (glowCurve.value * 0.1);
        
        return Stack(
          alignment: Alignment.center,
          children: [
            // Pulsing glow rings
            ...List.generate(4, (index) {
              final delay = index * 0.25;
              final adjustedValue = ((glowCurve.value + delay) % 1.0);
              return Transform.scale(
                scale: 1.0 + (adjustedValue * 0.4),
                child: Opacity(
                  opacity: glowIntensity * (1.0 - index * 0.2),
                  child: Container(
                    width: 160 + (index * 25),
                    height: 160 + (index * 25),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.medicalTeal.withOpacity(glowIntensity * (1.0 - index * 0.2)),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              );
            }),
            // Main icon
            Opacity(
              opacity: opacity,
              child: Transform.scale(
                scale: scale,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.medicalTeal.withOpacity(glowIntensity * 0.8),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Icon(
                    LucideIcons.moon,
                    size: 160,
                    color: AppColors.medicalTeal,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CloudAnimation extends StatelessWidget {
  final AnimationController controller;
  final AnimationController glowController;

  const _CloudAnimation({
    required this.controller,
    required this.glowController,
  });

  @override
  Widget build(BuildContext context) {
    final curve = CurvedAnimation(parent: controller, curve: Curves.easeInOut);
    final glowCurve = CurvedAnimation(parent: glowController, curve: Curves.easeInOut);
    
    return AnimatedBuilder(
      animation: Listenable.merge([controller, glowController]),
      builder: (context, child) {
        final offset = -60 + (curve.value * 120);
        final glowIntensity = 0.4 + (glowCurve.value * 0.4);
        final scale = 0.9 + (glowCurve.value * 0.2);
        
        return Stack(
          alignment: Alignment.center,
          children: [
            // Glow trail
            Transform.translate(
              offset: Offset(offset * 0.6, 0),
              child: Opacity(
                opacity: glowIntensity * 0.4,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.medicalTeal.withOpacity(glowIntensity),
                        blurRadius: 35,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Main cloud
            Transform.translate(
              offset: Offset(offset, 0),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.medicalTeal.withOpacity(glowIntensity * 0.8),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Icon(
                    LucideIcons.cloud,
                    size: 150,
                    color: AppColors.medicalTeal,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FastSlowAnimation extends StatelessWidget {
  final AnimationController controller;
  final AnimationController glowController;

  const _FastSlowAnimation({
    required this.controller,
    required this.glowController,
  });

  @override
  Widget build(BuildContext context) {
    final curve = CurvedAnimation(parent: controller, curve: Curves.elasticOut);
    final glowCurve = CurvedAnimation(parent: glowController, curve: Curves.easeInOut);
    
    return AnimatedBuilder(
      animation: Listenable.merge([controller, glowController]),
      builder: (context, child) {
        final fastScale = 0.7 + (curve.value * 0.6); // Fast (zap)
        final slowScale = 1.3 - (curve.value * 0.6); // Slow (moon)
        final glowIntensity = 0.4 + (glowCurve.value * 0.4);
        
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Fast icon (zap) with glow
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.premiumGold.withOpacity(glowIntensity * 0.8),
                    blurRadius: 25,
                    spreadRadius: 8,
                  ),
                ],
              ),
              child: Transform.scale(
                scale: fastScale,
                child: Icon(
                  LucideIcons.zap,
                  size: 100,
                  color: AppColors.premiumGold,
                ),
              ),
            ),
            const SizedBox(width: 30),
            // Slow icon (moon) with glow
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.medicalTeal.withOpacity(glowIntensity * 0.8),
                    blurRadius: 25,
                    spreadRadius: 8,
                  ),
                ],
              ),
              child: Transform.scale(
                scale: slowScale,
                child: Icon(
                  LucideIcons.moon,
                  size: 100,
                  color: AppColors.medicalTeal,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _HappyAnimation extends StatelessWidget {
  final AnimationController controller;
  final AnimationController glowController;

  const _HappyAnimation({
    required this.controller,
    required this.glowController,
  });

  @override
  Widget build(BuildContext context) {
    final curve = CurvedAnimation(parent: controller, curve: Curves.easeInOut);
    final glowCurve = CurvedAnimation(parent: glowController, curve: Curves.easeInOut);
    
    return AnimatedBuilder(
      animation: Listenable.merge([controller, glowController]),
      builder: (context, child) {
        final scale = 0.85 + (curve.value * 0.25); // More dynamic scale
        final glowIntensity = 0.4 + (glowCurve.value * 0.5);
        final rotation = curve.value * 0.1; // Slight rotation
        
        return Stack(
          alignment: Alignment.center,
          children: [
            // Pulsing glow rings
            ...List.generate(3, (index) {
              final delay = index * 0.2;
              final adjustedValue = ((glowCurve.value + delay) % 1.0);
              return Transform.scale(
                scale: 1.0 + (adjustedValue * 0.5),
                child: Opacity(
                  opacity: glowIntensity * (1.0 - index * 0.3),
                  child: Container(
                    width: 140 + (index * 30),
                    height: 140 + (index * 30),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.medicalTeal.withOpacity(glowIntensity * (1.0 - index * 0.25)),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              );
            }),
            // Main heart icon
            Transform.rotate(
              angle: rotation,
              child: Transform.scale(
                scale: scale,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.medicalTeal.withOpacity(glowIntensity * 0.9),
                        blurRadius: 35,
                        spreadRadius: 12,
                      ),
                    ],
                  ),
                  child: Icon(
                    LucideIcons.heart,
                    size: 160,
                    color: AppColors.medicalTeal,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FingerTrackingAnimation extends StatelessWidget {
  final AnimationController controller;
  final AnimationController glowController;

  const _FingerTrackingAnimation({
    required this.controller,
    required this.glowController,
  });

  @override
  Widget build(BuildContext context) {
    final curve = CurvedAnimation(parent: controller, curve: Curves.easeInOut);
    final glowCurve = CurvedAnimation(parent: glowController, curve: Curves.easeInOut);
    
    return AnimatedBuilder(
      animation: Listenable.merge([controller, glowController]),
      builder: (context, child) {
        // Parmak iki göz arasına yaklaşır ve uzaklaşır (scale ile)
        // 0.0 -> 0.5: yaklaşır (büyür), 0.5 -> 1.0: uzaklaşır (küçülür)
        final scale = curve.value < 0.5
            ? 0.5 + (curve.value * 2 * 1.0) // 0.5 -> 1.5 (yaklaşır)
            : 1.5 - ((curve.value - 0.5) * 2 * 1.0); // 1.5 -> 0.5 (uzaklaşır)
        final glowIntensity = 0.4 + (glowCurve.value * 0.4);
        
        return Stack(
          alignment: Alignment.center,
          children: [
            // Sol göz
            Positioned(
              left: 80,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.medicalTeal.withOpacity(glowIntensity * 0.6),
                      blurRadius: 25,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  LucideIcons.eye,
                  size: 100,
                  color: AppColors.medicalTeal,
                ),
              ),
            ),
            // Sağ göz
            Positioned(
              right: 80,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.medicalTeal.withOpacity(glowIntensity * 0.6),
                      blurRadius: 25,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  LucideIcons.eye,
                  size: 100,
                  color: AppColors.medicalTeal,
                ),
              ),
            ),
            // Parmak - iki göz arasına yaklaşır ve uzaklaşır
            Transform.scale(
              scale: scale,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.medicalBlue.withOpacity(glowIntensity * 0.9),
                      blurRadius: 25,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: Icon(
                  LucideIcons.pointer,
                  size: 120,
                  color: AppColors.medicalBlue,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PeripheralAnimation extends StatelessWidget {
  final AnimationController controller;
  final AnimationController glowController;

  const _PeripheralAnimation({
    required this.controller,
    required this.glowController,
  });

  @override
  Widget build(BuildContext context) {
    final curve = CurvedAnimation(parent: controller, curve: Curves.easeInOut);
    final glowCurve = CurvedAnimation(parent: glowController, curve: Curves.easeInOut);
    
    return AnimatedBuilder(
      animation: Listenable.merge([controller, glowController]),
      builder: (context, child) {
        final glowIntensity = 0.4 + (glowCurve.value * 0.5);
        final positions = [
          const Offset(-80, -80), // Sol üst
          const Offset(80, -80),  // Sağ üst
          const Offset(-80, 80),  // Sol alt
          const Offset(80, 80),   // Sağ alt
        ];
        
        return Stack(
          alignment: Alignment.center,
          children: [
            // Main eye with glow
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.medicalBlue.withOpacity(glowIntensity * 0.7),
                    blurRadius: 30,
                    spreadRadius: 8,
                  ),
                ],
              ),
              child: Icon(
                LucideIcons.eye,
                size: 150,
                color: AppColors.medicalBlue,
              ),
            ),
            // Peripheral dots with glow and pulse
            ...List.generate(4, (index) {
              final delay = index * 0.25;
              final adjustedValue = ((curve.value + delay) % 1.0);
              final position = positions[index];
              return Positioned(
                left: 140 + position.dx,
                top: 140 + position.dy,
                child: Transform.scale(
                  scale: 0.5 + (adjustedValue * 0.8),
                  child: Opacity(
                    opacity: adjustedValue,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.medicalTeal.withOpacity(glowIntensity * adjustedValue),
                            blurRadius: 15,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: Icon(
                        LucideIcons.circle,
                        size: 28,
                        color: AppColors.medicalTeal,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

class _PalmingAnimation extends StatelessWidget {
  final AnimationController controller;
  final AnimationController glowController;

  const _PalmingAnimation({
    required this.controller,
    required this.glowController,
  });

  @override
  Widget build(BuildContext context) {
    final curve = CurvedAnimation(parent: controller, curve: Curves.easeInOut);
    final glowCurve = CurvedAnimation(parent: glowController, curve: Curves.easeInOut);
    
    return AnimatedBuilder(
      animation: Listenable.merge([controller, glowController]),
      builder: (context, child) {
        final opacity = 0.3 + (curve.value * 0.4);
        final glowIntensity = 0.3 + (glowCurve.value * 0.5);
        final scale = 0.85 + (glowCurve.value * 0.2);
        
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer glow rings
            ...List.generate(3, (index) {
              final delay = index * 0.2;
              final adjustedValue = ((glowCurve.value + delay) % 1.0);
              return Transform.scale(
                scale: 1.0 + (adjustedValue * 0.3),
                child: Opacity(
                  opacity: glowIntensity * (1.0 - index * 0.25),
                  child: Container(
                    width: 180 + (index * 25),
                    height: 180 + (index * 25),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.medicalTeal.withOpacity(glowIntensity * (1.0 - index * 0.25)),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              );
            }),
            // Hand icon
            Opacity(
              opacity: opacity,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.medicalTeal.withOpacity(glowIntensity * 0.7),
                      blurRadius: 35,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Icon(
                  LucideIcons.hand,
                  size: 150,
                  color: AppColors.medicalTeal,
                ),
              ),
            ),
            // Eye icon (inside)
            Opacity(
              opacity: opacity * 0.8,
              child: Transform.scale(
                scale: scale,
                child: Icon(
                  LucideIcons.eye,
                  size: 80,
                  color: AppColors.medicalBlue,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _BreathingAnimation extends StatelessWidget {
  final AnimationController controller;
  final AnimationController glowController;

  const _BreathingAnimation({
    required this.controller,
    required this.glowController,
  });

  @override
  Widget build(BuildContext context) {
    final curve = CurvedAnimation(parent: controller, curve: Curves.easeInOut);
    final glowCurve = CurvedAnimation(parent: glowController, curve: Curves.easeInOut);
    
    return AnimatedBuilder(
      animation: Listenable.merge([controller, glowController]),
      builder: (context, child) {
        final scale = 0.6 + (curve.value * 0.5); // Breathing effect
        final glowIntensity = 0.4 + (glowCurve.value * 0.5);
        
        return Stack(
          alignment: Alignment.center,
          children: [
            // Breathing circles (multiple rings)
            ...List.generate(4, (index) {
              final delay = index * 0.15;
              final adjustedValue = ((curve.value + delay) % 1.0);
              final ringScale = 0.5 + (adjustedValue * 0.6);
              return Transform.scale(
                scale: ringScale,
                child: Opacity(
                  opacity: (1.0 - adjustedValue) * glowIntensity,
                  child: Container(
                    width: 160 + (index * 20),
                    height: 160 + (index * 20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.medicalTeal.withOpacity(glowIntensity * (1.0 - index * 0.2)),
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.medicalTeal.withOpacity(glowIntensity * 0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            // Main eye icon
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.medicalTeal.withOpacity(glowIntensity * 0.8),
                    blurRadius: 30,
                    spreadRadius: 8,
                  ),
                ],
              ),
              child: Icon(
                LucideIcons.eye,
                size: 140,
                color: AppColors.medicalTeal,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _NeckResetAnimation extends StatelessWidget {
  final AnimationController controller;
  final AnimationController glowController;

  const _NeckResetAnimation({
    required this.controller,
    required this.glowController,
  });

  @override
  Widget build(BuildContext context) {
    final curve = CurvedAnimation(parent: controller, curve: Curves.easeInOut);
    final glowCurve = CurvedAnimation(parent: glowController, curve: Curves.easeInOut);
    
    return AnimatedBuilder(
      animation: Listenable.merge([controller, glowController]),
      builder: (context, child) {
        final rotation = -0.15 + (curve.value * 0.3); // Gentle rotation
        final scale = 0.85 + (glowCurve.value * 0.2);
        final glowIntensity = 0.4 + (glowCurve.value * 0.5);
        
        return Stack(
          alignment: Alignment.center,
          children: [
            // User icon with glow
            Transform.rotate(
              angle: rotation,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.medicalBlue.withOpacity(glowIntensity * 0.7),
                      blurRadius: 30,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: Icon(
                  LucideIcons.user,
                  size: 140,
                  color: AppColors.medicalBlue,
                ),
              ),
            ),
            // Eye icon (pulsing)
            Transform.scale(
              scale: scale,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.medicalTeal.withOpacity(glowIntensity * 0.8),
                      blurRadius: 25,
                      spreadRadius: 6,
                    ),
                  ],
                ),
                child: Icon(
                  LucideIcons.eye,
                  size: 80,
                  color: AppColors.medicalTeal,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
