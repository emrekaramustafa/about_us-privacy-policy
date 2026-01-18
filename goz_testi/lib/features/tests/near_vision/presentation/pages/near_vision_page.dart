import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:goz_testi/core/theme/app_colors.dart';
import 'package:goz_testi/core/constants/app_strings.dart';
import 'package:goz_testi/core/router/app_router.dart';
import 'package:goz_testi/core/widgets/app_button.dart';
import 'package:goz_testi/features/tests/common/utils/test_limit_checker.dart';

/// Near Vision Test Page
enum NearVisionPhase { info, instructions, testing }

class NearVisionPage extends StatefulWidget {
  const NearVisionPage({super.key});

  @override
  State<NearVisionPage> createState() => _NearVisionPageState();
}

class _NearVisionPageState extends State<NearVisionPage>
    with SingleTickerProviderStateMixin {
  NearVisionPhase _currentPhase = NearVisionPhase.info;
  int _currentQuestion = 0;
  int _correctAnswers = 0;
  bool _showDistanceDialog = false;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Font sizes for near vision test (decreasing)
  // Starting from question 2 (20) with same difficulty progression
  // Each level is approximately 15-20% smaller than previous
  final List<double> _fontSizes = [
    20, 17, 14, 12, 10, 8.5, 7, 6, 5, 4.5
  ];
  
  final List<String> _words = [
    'KİTAP', 'YAZI', 'OKU', 'METİN', 'SATIR',
    'KELİME', 'CÜMLE', 'PARAGRAF', 'HARF', 'SÖZCÜK'
  ];
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
    final random = _currentQuestion * 7;
    _currentWord = _words[random % _words.length];
    
    // Generate options (correct + 3 wrong)
    final allWords = List<String>.from(_words);
    allWords.remove(_currentWord);
    allWords.shuffle();
    
    _options = [_currentWord!, ...allWords.take(3)];
    _options.shuffle();
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

    // Check if correct
    if (_options[_selectedAnswer!] == _currentWord) {
      _correctAnswers++;
    }

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
    final percentage = (_correctAnswers / _fontSizes.length * 100).round();
    String diagnosis;
    
    if (percentage >= 80) {
      diagnosis = 'Yakın görüşünüz normal görünüyor';
    } else if (percentage >= 60) {
      diagnosis = 'Hafif yakın görüş sorunu olabilir';
    } else {
      diagnosis = 'Yakın görüş sorunu var. Göz doktoruna danışın.';
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
    return Scaffold(
      backgroundColor: AppColors.cleanWhite,
      appBar: AppBar(
        backgroundColor: AppColors.cleanWhite,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        title: Text(AppStrings.nearVisionTitle),
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
                'Yakın Görme Testi Nedir?',
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
                      'Yakın görme testi, kitap, telefon veya yakın mesafedeki nesneleri ne kadar iyi görebildiğinizi ölçer. Bu test, presbiyopi (yaşa bağlı yakın görme sorunu) gibi durumları değerlendirmeye yardımcı olur.',
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
                              'Sağlıklı bir birey, yakın mesafedeki küçük yazıları net bir şekilde okuyabilmelidir. Test sırasında yazılar giderek küçülecektir.',
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
        title: Text(AppStrings.nearVisionTitle),
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
                      icon: LucideIcons.ruler,
                      text: 'Telefonu yaklaşık 40 cm mesafede tutun',
                    ),
                    const SizedBox(height: 16),
                    _buildInstructionItem(
                      icon: LucideIcons.eye,
                      text: 'Ekrandaki kelimeyi okuyun',
                    ),
                    const SizedBox(height: 16),
                    _buildInstructionItem(
                      icon: LucideIcons.mousePointer,
                      text: 'Gördüğünüz kelimeyi seçeneklerden seçin',
                    ),
                    const SizedBox(height: 16),
                    _buildInstructionItem(
                      icon: LucideIcons.alertCircle,
                      text: 'Yazılar giderek küçülecektir',
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
          'Soru ${_currentQuestion + 1} / ${_fontSizes.length}',
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
                        _currentWord ?? 'KİTAP',
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
                    'Hangi kelimeyi görüyorsunuz?',
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
                        final isSelected = _selectedAnswer == index;
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GestureDetector(
                            onTap: () => _onAnswerSelected(index),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: isSelected 
                                    ? AppColors.medicalTeal 
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected 
                                      ? AppColors.medicalTeal 
                                      : AppColors.borderLight,
                                  width: isSelected ? 3 : 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  word,
                                  style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected 
                                        ? Colors.white 
                                        : AppColors.textPrimary,
                                  ),
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
              'Kitap Okuma Mesafesi',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Cihazı kitap okuma mesafesinde (25-30 cm) tutarak teste başlayabilirsiniz.',
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
                  'Tamam',
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
