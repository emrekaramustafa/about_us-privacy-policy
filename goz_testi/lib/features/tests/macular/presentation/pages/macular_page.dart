import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:goz_testi/core/theme/app_colors.dart';
import 'package:goz_testi/core/constants/app_strings.dart';
import 'package:goz_testi/core/router/app_router.dart';
import 'package:goz_testi/core/widgets/app_button.dart';
import 'package:goz_testi/features/tests/common/utils/test_limit_checker.dart';

/// Macular Degeneration Test Page (Amsler Grid)
enum MacularPhase { info, instructions, testing }

class MacularPage extends StatefulWidget {
  const MacularPage({super.key});

  @override
  State<MacularPage> createState() => _MacularPageState();
}

class _MacularPageState extends State<MacularPage>
    with SingleTickerProviderStateMixin {
  MacularPhase _currentPhase = MacularPhase.info;
  int _currentStep = 0; // 0: Right eye, 1: Left eye
  bool _rightEyeNormal = true;
  bool _leftEyeNormal = true;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
      _currentPhase = MacularPhase.instructions;
    });
  }

  void _startTest() async {
    // Check if user can start test
    final canStart = await TestLimitChecker.canStartTest(context);
    if (!canStart) {
      return; // User chose not to start or limit reached
    }
    
    setState(() {
      _currentPhase = MacularPhase.testing;
      _currentStep = 0;
      _rightEyeNormal = true;
      _leftEyeNormal = true;
    });
    _animationController.forward(from: 0);
  }

  void _onAllNormal() {
    if (_currentStep == 0) {
      setState(() {
        _rightEyeNormal = true;
        _currentStep = 1;
      });
    } else {
      setState(() {
        _leftEyeNormal = true;
      });
      _finishTest();
    }
  }

  void _onHasIssues() {
    if (_currentStep == 0) {
      setState(() {
        _rightEyeNormal = false;
        _currentStep = 1;
      });
    } else {
      setState(() {
        _leftEyeNormal = false;
      });
      _finishTest();
    }
  }

  void _finishTest() {
    int normalCount = 0;
    if (_rightEyeNormal) normalCount++;
    if (_leftEyeNormal) normalCount++;
    
    int percentage = (normalCount / 2 * 100).round();
    String diagnosis;
    
    if (normalCount == 2) {
      diagnosis = 'Her iki gözde de makula görünümü normal';
    } else if (normalCount == 1) {
      final affectedEye = _rightEyeNormal ? 'Sol' : 'Sağ';
      diagnosis = '$affectedEye gözde makula anormallikleri görülebilir. Göz doktoruna danışın.';
    } else {
      diagnosis = 'Her iki gözde de makula anormallikleri görülebilir. Acilen göz doktoruna danışın.';
    }
    
    context.pushReplacement(
      AppRoutes.result,
      extra: {
        'testType': 'macular',
        'score': normalCount, // Use correct count, not percentage
        'totalQuestions': 2,
        'details': {
          'rightEyeNormal': _rightEyeNormal,
          'leftEyeNormal': _leftEyeNormal,
          'diagnosis': diagnosis,
          'percentage': percentage,
        },
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (_currentPhase) {
      case MacularPhase.info:
        return _buildInfoScreen();
      case MacularPhase.instructions:
        return _buildInstructionsScreen();
      case MacularPhase.testing:
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
        title: Text(AppStrings.macularTitle),
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
                    LucideIcons.grid,
                    size: 48,
                    color: AppColors.medicalTeal,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Makula Testi Nedir?',
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
                      'Amsler Grid testi, makula dejenerasyonu (sarı nokta hastalığı) gibi makula sorunlarını tespit etmeye yardımcı olur. Bu test, merkezi görüş alanındaki bozuklukları, çarpılmaları veya eksik alanları belirler.',
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
                              'Sağlıklı bir birey, grid çizgilerini düz ve kesişim noktasındaki merkez noktayı net görebilmelidir. Çizgilerde çarpılma, bulanıklık veya eksik alanlar varsa göz doktoruna danışın.',
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
        title: Text(AppStrings.macularTitle),
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
                    LucideIcons.grid,
                    size: 48,
                    color: AppColors.medicalTeal,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                AppStrings.testInstructions,
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
                      icon: LucideIcons.eyeOff,
                      text: 'Bir gözünüzü kapatın',
                    ),
                    const SizedBox(height: 16),
                    _buildInstructionItem(
                      icon: LucideIcons.target,
                      text: 'Grid\'in ortasındaki noktaya odaklanın',
                    ),
                    const SizedBox(height: 16),
                    _buildInstructionItem(
                      icon: LucideIcons.scan,
                      text: 'Tüm çizgilerin düz ve eşit olup olmadığını kontrol edin',
                    ),
                    const SizedBox(height: 16),
                    _buildInstructionItem(
                      icon: LucideIcons.alertCircle,
                      text: 'Çarpılma, bulanıklık veya eksik alan var mı?',
                    ),
                  ],
                ),
              ),
              const Spacer(),
              AppButton(
                text: AppStrings.startTest,
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
    final isRightEye = _currentStep == 0;
    final eyeName = isRightEye ? AppStrings.rightEye : AppStrings.leftEye;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(LucideIcons.x),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Adım ${_currentStep + 1} / 2',
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (_currentStep + 1) / 2,
              backgroundColor: AppColors.backgroundGrey,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.medicalTeal),
              minHeight: 4,
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Eye indicator
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.medicalTealPale,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(LucideIcons.eye, size: 20, color: AppColors.medicalTeal),
                          const SizedBox(width: 8),
                          Text(
                            eyeName,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.medicalTeal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Instructions
                    Text(
                      isRightEye
                          ? 'Sol gözünüzü kapatın ve sağ gözle bakın'
                          : 'Sağ gözünüzü kapatın ve sol gözle bakın',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Amsler Grid
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildAmslerGrid(),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Options
                    AppButton(
                      text: 'Tüm Çizgiler Normal',
                      icon: LucideIcons.check,
                      onPressed: _onAllNormal,
                      width: double.infinity,
                      backgroundColor: AppColors.successGreen,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    AppButton(
                      text: 'Çarpılma/Bulanıklık/Eksik Alan Var',
                      icon: LucideIcons.alertTriangle,
                      onPressed: _onHasIssues,
                      width: double.infinity,
                      isOutlined: true,
                      backgroundColor: AppColors.warningYellow,
                      textColor: AppColors.warningYellow,
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

  Widget _buildAmslerGrid() {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.borderLight, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: CustomPaint(
        painter: AmslerGridPainter(),
        child: Center(
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

class AmslerGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Draw horizontal lines
    for (int i = 0; i <= 10; i++) {
      final y = (size.height / 10) * i;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // Draw vertical lines
    for (int i = 0; i <= 10; i++) {
      final x = (size.width / 10) * i;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

