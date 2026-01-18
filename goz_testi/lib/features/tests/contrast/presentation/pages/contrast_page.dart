import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:goz_testi/core/theme/app_colors.dart';
import 'package:goz_testi/core/constants/app_strings.dart';
import 'package:goz_testi/core/router/app_router.dart';
import 'package:goz_testi/core/widgets/app_button.dart';

/// Contrast Sensitivity Test Page
enum ContrastPhase { info, instructions, testing }

class ContrastPage extends StatefulWidget {
  const ContrastPage({super.key});

  @override
  State<ContrastPage> createState() => _ContrastPageState();
}

class _ContrastPageState extends State<ContrastPage>
    with SingleTickerProviderStateMixin {
  ContrastPhase _currentPhase = ContrastPhase.info;
  int _currentQuestion = 0;
  int _correctAnswers = 0;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Contrast levels (0.0 to 1.0, lower = harder to see)
  // Much more aggressive difficulty - starting from very low contrast
  // Each level is approximately 35-40% harder than previous
  // Last levels should be extremely difficult to see
  final List<double> _contrastLevels = [
    0.08, 0.05, 0.032, 0.02, 0.013, 0.008, 0.005, 0.003, 0.002, 0.001
  ];
  
  // Snellen letters for better readability
  final List<String> _letters = ['F', 'P', 'T', 'O', 'Z'];
  String? _currentLetter;
  List<String> _options = [];
  int? _selectedAnswer;
  int? _correctAnswerIndex;

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

  void _onInfoContinue() {
    setState(() {
      _currentPhase = ContrastPhase.instructions;
    });
  }

  void _startTest() {
    setState(() {
      _currentPhase = ContrastPhase.testing;
      _currentQuestion = 0;
      _correctAnswers = 0;
      _generateQuestion();
    });
    _animationController.forward(from: 0);
  }

  void _generateQuestion() {
    final random = _currentQuestion * 7; // Deterministic randomness
    _currentLetter = _letters[random % _letters.length];
    
    // Generate options (correct + 3 wrong)
    final allLetters = List<String>.from(_letters);
    allLetters.remove(_currentLetter);
    allLetters.shuffle();
    
    _options = [_currentLetter!, ...allLetters.take(3)];
    _options.shuffle();
    
    // Find correct answer index after shuffling
    _correctAnswerIndex = _options.indexOf(_currentLetter!);
    _selectedAnswer = null;
  }

  void _onAnswerSelected(int index) {
    setState(() {
      _selectedAnswer = index;
    });
    
    // Automatically move to next question after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _onNextQuestion();
      }
    });
  }

  void _onNextQuestion() {
    if (_selectedAnswer == null) {
      return; // Don't show error if called automatically
    }

    // Check if correct answer matches
    if (_selectedAnswer == _correctAnswerIndex) {
      _correctAnswers++;
    }

    if (_currentQuestion < _contrastLevels.length - 1) {
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
    final percentage = (_correctAnswers / _contrastLevels.length * 100).round();
    String diagnosis;
    
    if (percentage >= 80) {
      diagnosis = 'Kontrast hassasiyetiniz normal görünüyor';
    } else if (percentage >= 60) {
      diagnosis = 'Hafif kontrast hassasiyeti eksikliği olabilir';
    } else {
      diagnosis = 'Kontrast hassasiyeti düşük. Göz doktoruna danışın.';
    }
    
    context.pushReplacement(
      AppRoutes.result,
      extra: {
        'testType': 'contrast',
        'score': _correctAnswers, // Use correct answers count, not percentage
        'totalQuestions': _contrastLevels.length,
        'details': {
          'percentage': percentage,
          'diagnosis': diagnosis,
          'correctAnswers': _correctAnswers,
          'totalQuestions': _contrastLevels.length,
        },
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (_currentPhase) {
      case ContrastPhase.info:
        return _buildInfoScreen();
      case ContrastPhase.instructions:
        return _buildInstructionsScreen();
      case ContrastPhase.testing:
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
        title: Text(AppStrings.contrastTitle),
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
                    LucideIcons.contrast,
                    size: 48,
                    color: AppColors.medicalBlue,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Kontrast Hassasiyeti Testi Nedir?',
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
                      'Kontrast hassasiyeti, farklı parlaklıktaki nesneleri ayırt edebilme yeteneğidir. Bu test, düşük kontrastlı harfleri ne kadar iyi görebildiğinizi ölçer.',
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
                              'Sağlıklı bir birey, düşük kontrastlı harfleri de görebilmelidir. Test sırasında harfler giderek daha az kontrastlı hale gelecektir.',
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
        title: Text(AppStrings.contrastTitle),
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
                  color: AppColors.medicalBluePale,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    LucideIcons.contrast,
                    size: 48,
                    color: AppColors.medicalBlue,
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
                      icon: LucideIcons.eye,
                      text: 'Ekranın ortasındaki harfe odaklanın',
                    ),
                    const SizedBox(height: 16),
                    _buildInstructionItem(
                      icon: LucideIcons.sun,
                      text: 'Ekran parlaklığını maksimuma ayarlayın',
                    ),
                    const SizedBox(height: 16),
                    _buildInstructionItem(
                      icon: LucideIcons.mousePointer,
                      text: 'Gördüğünüz harfi seçeneklerden seçin',
                    ),
                    const SizedBox(height: 16),
                    _buildInstructionItem(
                      icon: LucideIcons.alertCircle,
                      text: 'Harfler giderek daha az kontrastlı olacak',
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
                backgroundColor: AppColors.medicalBlue,
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

  Widget _buildTestScreen() {
    final contrast = _contrastLevels[_currentQuestion];
    final shapeColor = Color.lerp(
      Colors.grey[300]!,
      Colors.black,
      contrast,
    )!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(LucideIcons.x),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Soru ${_currentQuestion + 1} / ${_contrastLevels.length}',
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (_currentQuestion + 1) / _contrastLevels.length,
              backgroundColor: AppColors.backgroundGrey,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.medicalBlue),
              minHeight: 4,
            ),
            
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Shape Display
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          _currentLetter ?? 'F',
                          style: GoogleFonts.inter(
                            fontSize: 100,
                            color: shapeColor,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  Text(
                    'Hangi harfi görüyorsunuz?',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Options Grid
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.0,
                      physics: const NeverScrollableScrollPhysics(),
                      children: _options.asMap().entries.map((entry) {
                        final index = entry.key;
                        final shape = entry.value;
                        final isSelected = _selectedAnswer == index;
                        
                        return GestureDetector(
                          onTap: () => _onAnswerSelected(index),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? AppColors.medicalBlue 
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected 
                                    ? AppColors.medicalBlue 
                                    : AppColors.borderLight,
                                width: isSelected ? 3 : 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                shape,
                                style: GoogleFonts.inter(
                                  fontSize: 36,
                                  color: isSelected 
                                      ? Colors.white 
                                      : AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                        );
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
}

