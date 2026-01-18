import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:goz_testi/core/theme/app_colors.dart';
import 'package:goz_testi/core/constants/app_strings.dart';
import 'package:goz_testi/core/router/app_router.dart';
import 'package:goz_testi/core/widgets/app_button.dart';
import 'package:goz_testi/features/tests/common/utils/test_limit_checker.dart';
import '../widgets/astigmatism_dial.dart';

/// Astigmatism Test Page
/// 
/// Tests for astigmatism using a radial line dial.
/// Users report if any lines appear darker or blurrier than others.
enum AstigmatismPhase { info, instructions, testing }

class AstigmatismPage extends StatefulWidget {
  const AstigmatismPage({super.key});

  @override
  State<AstigmatismPage> createState() => _AstigmatismPageState();
}

class _AstigmatismPageState extends State<AstigmatismPage> {
  AstigmatismPhase _currentPhase = AstigmatismPhase.info;
  int _currentStep = 0; // 0: Right eye, 1: Left eye, 2: Third question
  
  // Results for each eye
  String? _rightEyeResult;
  String? _leftEyeResult;
  String? _thirdQuestionResult;
  List<int>? _rightEyeDarkerLines;
  List<int>? _leftEyeDarkerLines;
  List<int>? _thirdQuestionDarkerLines;
  
  // Selected darker lines (if any)
  final Set<int> _selectedLines = {};

  void _onInfoContinue() async {
    // Check if user can start test
    final canStart = await TestLimitChecker.canStartTest(context);
    if (!canStart) {
      return; // User chose not to start or limit reached
    }
    
    setState(() {
      _currentPhase = AstigmatismPhase.instructions;
    });
    
    // Show dialog after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showDistanceInstructionDialog();
    });
  }
  
  void _showDistanceInstructionDialog({bool? isRightEyeClosed}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _DistanceInstructionDialog(
        isRightEyeClosed: isRightEyeClosed ?? true,
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
      _currentPhase = AstigmatismPhase.testing;
      _currentStep = 0;
    });
  }

  void _onAllLinesEqual() {
    if (_currentStep == 0) {
      setState(() {
        _rightEyeResult = 'normal';
        _rightEyeDarkerLines = null;
        _selectedLines.clear();
        _currentStep = 1;
      });
      // Show dialog for left eye after build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showDistanceInstructionDialog(isRightEyeClosed: false);
      });
    } else if (_currentStep == 1) {
      setState(() {
        _leftEyeResult = 'normal';
        _leftEyeDarkerLines = null;
        _selectedLines.clear();
        _currentStep = 2;
      });
      // Show dialog for third question after build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showDistanceInstructionDialog();
      });
    } else {
      setState(() {
        _thirdQuestionResult = 'normal';
        _thirdQuestionDarkerLines = null;
      });
      _finishTest();
    }
  }

  void _onSomeLinesdarker() {
    if (_selectedLines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Lütfen daha koyu görünen çizgilere dokunun'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
    
    if (_currentStep == 0) {
      setState(() {
        _rightEyeResult = 'potential_astigmatism';
        _rightEyeDarkerLines = _selectedLines.toList();
        _selectedLines.clear();
        _currentStep = 1;
      });
      // Show dialog for left eye after build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showDistanceInstructionDialog(isRightEyeClosed: false);
      });
    } else if (_currentStep == 1) {
      setState(() {
        _leftEyeResult = 'potential_astigmatism';
        _leftEyeDarkerLines = _selectedLines.toList();
        _selectedLines.clear();
        _currentStep = 2;
      });
      // Show dialog for third question after build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showDistanceInstructionDialog();
      });
    } else {
      setState(() {
        _thirdQuestionResult = 'potential_astigmatism';
        _thirdQuestionDarkerLines = _selectedLines.toList();
      });
      _finishTest();
    }
  }

  void _onLineSelected(int lineIndex) {
    setState(() {
      if (_selectedLines.contains(lineIndex)) {
        _selectedLines.remove(lineIndex);
      } else {
        _selectedLines.add(lineIndex);
      }
    });
  }

  void _finishTest() {
    int normalCount = 0;
    if (_rightEyeResult == 'normal') normalCount++;
    if (_leftEyeResult == 'normal') normalCount++;
    if (_thirdQuestionResult == 'normal') normalCount++;
    
    int percentage = (normalCount / 3 * 100).round();
    String diagnosis;
    
    if (normalCount == 3) {
      diagnosis = 'Astigmat belirtisi görünmüyor';
    } else if (normalCount == 2) {
      diagnosis = 'Hafif astigmat olabilir. Göz doktoruna danışın.';
    } else if (normalCount == 1) {
      diagnosis = 'Astigmat olabilir. Göz doktoruna danışın.';
    } else {
      diagnosis = 'Belirgin astigmat belirtileri var. Göz doktoruna danışın.';
    }
    
    context.pushReplacement(
      AppRoutes.result,
      extra: {
        'testType': 'astigmatism',
        'score': normalCount, // Use correct count, not percentage
        'totalQuestions': 3,
        'details': {
          'rightEyeResult': _rightEyeResult,
          'leftEyeResult': _leftEyeResult,
          'thirdQuestionResult': _thirdQuestionResult,
          'rightEyeDarkerLines': _rightEyeDarkerLines,
          'leftEyeDarkerLines': _leftEyeDarkerLines,
          'thirdQuestionDarkerLines': _thirdQuestionDarkerLines,
          'diagnosis': diagnosis,
          'percentage': percentage,
        },
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (_currentPhase) {
      case AstigmatismPhase.info:
        return _buildInfoScreen();
      case AstigmatismPhase.instructions:
        return _buildInstructionsScreen();
      case AstigmatismPhase.testing:
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
        title: Text(AppStrings.astigmatismTitle),
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
                    LucideIcons.focus,
                    size: 48,
                    color: AppColors.premiumGold,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Astigmat Testi Nedir?',
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
                      'Astigmat, gözün kornea veya lensinin düzensiz şeklinden kaynaklanan bir görme bozukluğudur. Bu durumda ışık göze düzgün odaklanamaz ve görüntüler bulanık veya çarpık görünebilir.',
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
                              'Sağlıklı bir birey, radyal çizgilerin hepsini eşit netlikte görebilmelidir. Eğer bazı çizgiler daha koyu, bulanık veya farklı görünüyorsa, bu astigmat belirtisi olabilir.',
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
        title: Text(AppStrings.astigmatismTitle),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icon
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
                    LucideIcons.focus,
                    size: 48,
                    color: AppColors.premiumGold,
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
                      text: 'Diyagramın ortasındaki noktaya odaklanın',
                    ),
                    const SizedBox(height: 16),
                    _buildInstructionItem(
                      icon: LucideIcons.scan,
                      text: 'Tüm çizgilerin eşit olup olmadığını değerlendirin',
                    ),
                    const SizedBox(height: 16),
                    _buildInstructionItem(
                      icon: LucideIcons.mousePointer,
                      text: 'Koyu görünen çizgilere dokunun',
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.infoBluePale,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      LucideIcons.info,
                      color: AppColors.infoBlue,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Astigmat varsa bazı çizgiler daha koyu veya bulanık görünebilir',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionItem({
    required IconData icon,
    required String text,
  }) {
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
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTestScreen() {
    String eyeName;
    String instruction;
    if (_currentStep == 0) {
      eyeName = AppStrings.rightEye;
      instruction = 'Sol gözünüzü kapatın ve sağ gözle bakın';
    } else if (_currentStep == 1) {
      eyeName = AppStrings.leftEye;
      instruction = 'Sağ gözünüzü kapatın ve sol gözle bakın';
    } else {
      eyeName = 'Her İki Göz';
      instruction = 'Her iki gözünüzü açık tutun ve bakın';
    }
    final eyeIcon = LucideIcons.eye;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(LucideIcons.x),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Adım ${_currentStep + 1} / 3',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress
            LinearProgressIndicator(
              value: (_currentStep + 1) / 3,
              backgroundColor: AppColors.backgroundGrey,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.premiumGold),
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
                        color: AppColors.medicalBluePale,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(eyeIcon, size: 20, color: AppColors.medicalBlue),
                          const SizedBox(width: 8),
                          Text(
                            eyeName,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.medicalBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Instructions
                    Text(
                      instruction,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Astigmatism Dial
                    AstigmatismDial(
                      size: MediaQuery.of(context).size.width - 80,
                      selectedLines: _selectedLines,
                      onLineSelected: _onLineSelected,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Selected lines indicator
                    if (_selectedLines.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.warningYellowPale,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              LucideIcons.alertCircle,
                              size: 18,
                              color: AppColors.warningYellow,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${_selectedLines.length} çizgi seçildi',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    const SizedBox(height: 32),
                    
                    // Buttons
                    AppButton(
                      text: AppStrings.allLinesEqual,
                      icon: LucideIcons.check,
                      onPressed: _onAllLinesEqual,
                      width: double.infinity,
                      backgroundColor: AppColors.successGreen,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    AppButton(
                      text: AppStrings.someLinesdarker,
                      icon: LucideIcons.alertTriangle,
                      onPressed: _onSomeLinesdarker,
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
    final eyeText = isRightEyeClosed 
        ? 'Sağ gözünüzü kapatıp cihazı kol mesafesine getirdiğinizde teste başlayabilirsiniz.'
        : 'Sol gözünüzü kapatıp cihazı kol mesafesine getirdiğinizde teste başlayabilirsiniz.';

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
              'Kol Mesafesi',
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
