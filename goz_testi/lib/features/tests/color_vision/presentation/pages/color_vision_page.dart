import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:goz_testi/core/theme/app_colors.dart';
import 'package:goz_testi/core/constants/app_strings.dart';
import 'package:goz_testi/core/router/app_router.dart';
import 'package:goz_testi/core/widgets/app_button.dart';
import 'package:goz_testi/features/tests/common/utils/test_limit_checker.dart';

/// Color Vision Test Page - Enhanced with multiple test types
enum ColorVisionPhase { info, instructions, testing }
enum PlateType { number, ring } // Number plate or ring test

class ColorVisionPage extends StatefulWidget {
  const ColorVisionPage({super.key});

  @override
  State<ColorVisionPage> createState() => _ColorVisionPageState();
}

class _ColorVisionPageState extends State<ColorVisionPage>
    with SingleTickerProviderStateMixin {
  
  ColorVisionPhase _currentPhase = ColorVisionPhase.info;
  int _currentPlateIndex = 0;
  int _correctAnswers = 0;
  
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  // Enhanced Ishihara Data - Sayılar önce, sonra halkalar
  final List<IshiharaPlateData> _plates = [
    // 1. Soru: 48
    IshiharaPlateData(
      type: PlateType.number,
      number: 48,
      options: ['28', '84', '48', '8'],
      correctAnswer: '48',
      description: 'Protanopia (Kırmızı)',
      imagePath: 'assets/images/ishihara/ring_48.png',
    ),
    // 2. Soru: 4
    IshiharaPlateData(
      type: PlateType.number,
      number: 4,
      options: ['4', '44', '14', '41'],
      correctAnswer: '4',
      description: 'Tritanopia (Mavi)',
      imagePath: 'assets/images/ishihara/ring_4.png',
    ),
    // 3. Soru: 36
    IshiharaPlateData(
      type: PlateType.number,
      number: 36,
      options: ['36', '63', '33', '66'],
      correctAnswer: '36',
      description: 'Genel Test',
      imagePath: 'assets/images/ishihara/plate_36.png',
    ),
    // 4. Soru: 23
    IshiharaPlateData(
      type: PlateType.number,
      number: 23,
      options: ['3', '23', '33', '63'],
      correctAnswer: '23',
      description: 'Deuteranopia (Yeşil)',
      imagePath: 'assets/images/ishihara/plate_23.png',
    ),
    // 5. Soru: Halka 1
    IshiharaPlateData(
      type: PlateType.ring,
      number: 0,
      options: ['Evet', 'Hayır', 'Emin Değilim'],
      correctAnswer: 'Evet',
      description: 'Halka Renk Testi 1',
      imagePath: 'assets/images/ishihara/halka_1.png',
    ),
    // 6. Soru: Halka 2
    IshiharaPlateData(
      type: PlateType.ring,
      number: 0,
      options: ['Evet', 'Hayır', 'Emin Değilim'],
      correctAnswer: 'Evet',
      description: 'Halka Renk Testi 2',
      imagePath: 'assets/images/ishihara/halka_2.png',
    ),
  ];

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
      _currentPhase = ColorVisionPhase.instructions;
    });
  }

  void _startTest() async {
    // Check if user can start test
    final canStart = await TestLimitChecker.canStartTest(context);
    if (!canStart) {
      return; // User chose not to start or limit reached
    }
    
    setState(() {
      _currentPhase = ColorVisionPhase.testing;
      _currentPlateIndex = 0;
      _correctAnswers = 0;
    });
    _animationController.forward(from: 0);
  }

  void _onOptionSelected(String selectedOption) {
    final currentPlate = _plates[_currentPlateIndex];
    final isCorrect = selectedOption == currentPlate.correctAnswer;
    
    if (isCorrect) {
      _correctAnswers++;
    }
    
    _nextPlate();
  }

  void _nextPlate() {
    if (_currentPlateIndex < _plates.length - 1) {
      setState(() {
        _currentPlateIndex++;
      });
      _animationController.forward(from: 0);
    } else {
      _finishTest();
    }
  }

  void _finishTest() {
    final totalQuestions = _plates.length;
    final percentage = (_correctAnswers / totalQuestions * 100).round();
    String diagnosis;
    
    if (percentage == 100) {
      diagnosis = 'Mükemmel Renk Görüşü';
    } else if (percentage >= 80) {
      diagnosis = 'Normal Renk Görüşü';
    } else if (percentage >= 60) {
      diagnosis = 'Hafif Renk Görüşü Eksikliği Olabilir';
    } else {
      diagnosis = 'Renk Görüşü Testi İçin Doktora Başvurun';
    }
    
    context.pushReplacement(
      AppRoutes.result,
      extra: {
        'testType': 'color_vision',
        'score': _correctAnswers, // Use correct answers count, not percentage
        'totalQuestions': totalQuestions,
        'details': {
          'percentage': percentage,
          'diagnosis': diagnosis,
          'correctAnswers': _correctAnswers,
          'totalPlates': totalQuestions,
          'isPercentageBased': true,
          'leftEyeScore': percentage,
          'rightEyeScore': percentage,
          'leftEyeAcuity': '$percentage%',
          'rightEyeAcuity': '$percentage%',
        },
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (_currentPhase) {
      case ColorVisionPhase.info:
        return _buildInfoScreen();
      case ColorVisionPhase.instructions:
        return _buildInstructionsScreen();
      case ColorVisionPhase.testing:
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
        title: Text(AppStrings.colorVisionTitle),
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
                    LucideIcons.palette,
                    size: 48,
                    color: AppColors.medicalTeal,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Renk Körlüğü Testi Nedir?',
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
                      'Bu test üç farklı renk körlüğü türünü değerlendirir:\n\n• Deuteranopia (Yeşil Renk Körlüğü)\n• Protanopia (Kırmızı Renk Körlüğü)\n• Tritanopia (Mavi Renk Körlüğü)',
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
                              'Sağlıklı bir birey, renkli daireler içindeki sayıları net bir şekilde görebilmelidir. Halka testlerinde ise farklı renkleri ayırt edebilmelidir. Eğer emin değilseniz, "Emin Değilim" seçeneğini işaretleyiniz.',
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
        title: Text(AppStrings.colorVisionTitle),
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
                    LucideIcons.palette,
                    size: 48,
                    color: AppColors.medicalTeal,
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
                      icon: LucideIcons.sun,
                      text: 'Ekran parlaklığını maksimuma ayarlayın.',
                    ),
                    const SizedBox(height: 16),
                    _buildInstructionItem(
                      icon: LucideIcons.search,
                      text: 'Sayı plakalarında: Daire içindeki sayıyı bulun.',
                    ),
                    const SizedBox(height: 16),
                    _buildInstructionItem(
                      icon: LucideIcons.circle,
                      text: 'Halka testlerinde: Farklı renkleri görüp görmediğinizi değerlendirin.',
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
    final currentPlateData = _plates[_currentPlateIndex];
    final isRingTest = currentPlateData.type == PlateType.ring;
    
    // For number tests: 4 options in 2x2 grid + "Emin Değilim" below
    // For ring tests: 2 options (Evet, Hayır) in 2x1 grid + "Emin Değilim" below
    List<String> mainOptions;
    if (isRingTest) {
      mainOptions = ['Evet', 'Hayır'];
    } else {
      mainOptions = List<String>.from(currentPlateData.options);
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
          'Plaka ${_currentPlateIndex + 1} / ${_plates.length}',
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (_currentPlateIndex + 1) / _plates.length,
              backgroundColor: AppColors.backgroundGrey,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.medicalTeal),
              minHeight: 4,
            ),
            
            // Plate Display
            Expanded(
              flex: 4,
              child: Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: _buildPlateDisplay(currentPlateData, isRingTest),
                  ),
                ),
              ),
            ),
            
            // Options Area
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.backgroundGrey.withOpacity(0.5),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Column(
                  children: [
                    Text(
                      isRingTest 
                          ? 'Dairenin içinde farklı renk bir halka görüyor musunuz?'
                          : 'Hangi sayıyı görüyorsunuz?',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // 2x2 Grid for options
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // First row: 2 options
                            Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 8, bottom: 10),
                                    child: _buildOptionButton(mainOptions[0]),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8, bottom: 10),
                                    child: _buildOptionButton(mainOptions[1]),
                                  ),
                                ),
                              ],
                            ),
                            // Second row: 2 options (if exists)
                            if (mainOptions.length > 2)
                              Row(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 8, bottom: 10),
                                      child: _buildOptionButton(mainOptions[2]),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8, bottom: 10),
                                      child: _buildOptionButton(mainOptions[3]),
                                    ),
                                  ),
                                ],
                              ),
                            // "Emin Değilim" button below
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: _buildOptionButton('Emin Değilim', isSecondary: true),
                            ),
                          ],
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

  Widget _buildPlateDisplay(IshiharaPlateData plate, bool isRingTest) {
    final size = MediaQuery.of(context).size.width - 40;
    
    // Try to load image, fallback to generated if not found
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipOval(
        child: plate.imagePath != null
            ? Image.asset(
                plate.imagePath!,
                width: size,
                height: size,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('Image load error: ${plate.imagePath}');
                  debugPrint('Error: $error');
                  // Fallback to generated if image not found
                  return isRingTest
                      ? _buildRingTestFallback(size)
                      : IshiharaPlateWidget(
                          number: plate.number,
                          size: size,
                        );
                },
              )
            : isRingTest
                ? _buildRingTestFallback(size)
                : IshiharaPlateWidget(
                    number: plate.number,
                    size: size,
                  ),
      ),
    );
  }

  Widget _buildRingTestFallback(double size) {
    // Fallback colorful ring if image not found
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: SweepGradient(
          colors: [
            Colors.red,
            Colors.orange,
            Colors.yellow,
            Colors.green,
            Colors.blue,
            Colors.indigo,
            Colors.purple,
            Colors.red,
          ],
          stops: const [0.0, 0.14, 0.28, 0.42, 0.57, 0.71, 0.85, 1.0],
        ),
      ),
      child: Container(
        margin: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildOptionButton(String text, {bool isSecondary = false}) {
    return Material(
      color: isSecondary ? AppColors.backgroundGrey : Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      child: InkWell(
        onTap: () => _onOptionSelected(text),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.borderLight,
              width: 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isSecondary ? AppColors.textSecondary : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

/// Enhanced Data Model
class IshiharaPlateData {
  final PlateType type;
  final int number;
  final List<String> options;
  final String correctAnswer;
  final String description;
  final String? imagePath; // Path to image asset

  const IshiharaPlateData({
    required this.type,
    required this.number,
    required this.options,
    required this.correctAnswer,
    required this.description,
    this.imagePath,
  });
}

/// Improved Ishihara Plate Widget
class IshiharaPlateWidget extends StatelessWidget {
  final int number;
  final double size;

  const IshiharaPlateWidget({
    super.key,
    required this.number,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipOval(
        child: CustomPaint(
          painter: IshiharaPainter(number: number),
        ),
      ),
    );
  }
}

/// Professional Ishihara Painter
class IshiharaPainter extends CustomPainter {
  final int number;
  final Random _random;

  IshiharaPainter({required this.number}) : _random = Random(number);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final dotCount = 1800;

    final bgColors = [
      const Color(0xFF81C784),
      const Color(0xFFAED581),
      const Color(0xFF4DB6AC),
      const Color(0xFFDCE775),
      const Color(0xFFBCAAA4),
    ];

    final numColors = [
      const Color(0xFFE57373),
      const Color(0xFFFF8A65),
      const Color(0xFFFFB74D),
      const Color(0xFFF06292),
    ];

    for (int i = 0; i < dotCount; i++) {
      final r = radius * sqrt(_random.nextDouble());
      final theta = _random.nextDouble() * 2 * pi;
      final x = center.dx + r * cos(theta);
      final y = center.dy + r * sin(theta);
      
      bool isNumber = _isPointInNumber(x, y, size, number);
      
      Color color = isNumber 
          ? numColors[_random.nextInt(numColors.length)]
          : bgColors[_random.nextInt(bgColors.length)];
      
      double dotRadius = 2.0 + _random.nextDouble() * 4.5;
      
      canvas.drawCircle(Offset(x, y), dotRadius, Paint()..color = color);
    }
  }

  bool _isPointInNumber(double x, double y, Size size, int number) {
    double nx = (x - size.width/2) / (size.width/2 * 0.6);
    double ny = (y - size.height/2) / (size.height/2 * 0.6);
    
    final numStr = number.toString();
    if (numStr.length == 1) {
      return _isInSingleDigit(nx, ny, numStr[0]);
    } else {
      // Two digits
      final digit1 = numStr[0];
      final digit2 = numStr[1];
      return _isInSingleDigit(nx + 0.5, ny, digit1) || 
             _isInSingleDigit(nx - 0.5, ny, digit2);
    }
  }

  bool _isInSingleDigit(double x, double y, String digit) {
    switch (digit) {
      case '2': return _isInDigit2(x, y);
      case '3': return _isInDigit3(x, y);
      case '4': return _isInDigit4(x, y);
      case '6': return _isInDigit6(x, y);
      case '8': return _isInDigit8(x, y);
      case '9': return _isInDigit9(x, y);
      default: return false;
    }
  }

  bool _isInDigit2(double x, double y) {
    bool top = y < -0.3 && x*x + (y+0.3)*(y+0.3) < 0.2;
    bool diag = y > -0.3 && y < 0.5 && (x + y).abs() < 0.2;
    bool bot = y > 0.5 && y < 0.7 && x.abs() < 0.4;
    return top || diag || bot;
  }

  bool _isInDigit3(double x, double y) {
    bool top = y < -0.2 && x*x + (y+0.3)*(y+0.3) < 0.15 && x > -0.1;
    bool mid = y.abs() < 0.2 && x > -0.1 && x < 0.2;
    bool bot = y > 0.2 && x*x + (y-0.3)*(y-0.3) < 0.15 && x > -0.1;
    return top || mid || bot;
  }

  bool _isInDigit4(double x, double y) {
    bool v = x > 0.1 && x < 0.3 && y.abs() < 0.7;
    bool h = y > 0.1 && y < 0.3 && x.abs() < 0.4;
    bool d = x < 0.2 && y < 0.2 && (x - y + 0.4).abs() < 0.15;
    return v || h || d;
  }

  bool _isInDigit6(double x, double y) {
    bool c = y > 0.2 && x*x + (y-0.4)*(y-0.4) < 0.2;
    bool l = x < -0.2 && y < 0.4 && y > -0.4;
    bool t = y < -0.3 && x.abs() < 0.3;
    return c || l || t;
  }

  bool _isInDigit8(double x, double y) {
    return (x*x + (y-0.4)*(y-0.4) < 0.15) || (x*x + (y+0.4)*(y+0.4) < 0.20);
  }

  bool _isInDigit9(double x, double y) {
    bool t = y < -0.1 && x*x + (y+0.3)*(y+0.3) < 0.2;
    bool r = x > 0.2 && y > -0.3 && y < 0.5;
    bool b = y > 0.4 && x.abs() < 0.3;
    return t || r || b;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
