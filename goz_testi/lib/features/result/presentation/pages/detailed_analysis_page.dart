import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:goz_testi/core/theme/app_colors.dart';
import 'package:goz_testi/core/widgets/scroll_indicator.dart';

/// Detailed Analysis Page
/// 
/// Shows comprehensive analysis for each test type including:
/// - Problem descriptions
/// - Possible consequences
/// - Treatment options
/// - Recommendations
class DetailedAnalysisPage extends ConsumerStatefulWidget {
  final String testType;
  final int score;
  final int totalQuestions;
  final Map<String, dynamic>? details;

  const DetailedAnalysisPage({
    super.key,
    required this.testType,
    required this.score,
    required this.totalQuestions,
    this.details,
  });

  @override
  ConsumerState<DetailedAnalysisPage> createState() => _DetailedAnalysisPageState();
}

class _DetailedAnalysisPageState extends ConsumerState<DetailedAnalysisPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final percentage = widget.details != null && widget.details!['percentage'] != null
        ? widget.details!['percentage'] as int
        : ((widget.score / widget.totalQuestions) * 100).round();

    return Scaffold(
      backgroundColor: AppColors.cleanWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            LucideIcons.arrowLeft,
            color: AppColors.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Detaylı Analiz',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(24),
            child: FadeTransition(
              opacity: _animationController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTestHeader(percentage),
                  const SizedBox(height: 32),
                  _buildAnalysisContent(percentage),
                ],
              ),
            ),
          ),
          ScrollIndicator(scrollController: _scrollController),
        ],
      ),
    );
  }

  Widget _buildTestHeader(int percentage) {
    String testName = _getTestName();
    IconData testIcon = _getTestIcon();
    Color testColor = _getTestColor();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            testColor.withOpacity(0.1),
            testColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: testColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: testColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              testIcon,
              size: 32,
              color: testColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  testName,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Sonuç: %$percentage',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisContent(int percentage) {
    switch (widget.testType) {
      case 'visual_acuity':
        return _buildVisualAcuityAnalysis(percentage);
      case 'color_vision':
        return _buildColorVisionAnalysis(percentage);
      case 'astigmatism':
        return _buildAstigmatismAnalysis(percentage);
      case 'stereopsis':
      case 'binocular_vision':
        return _buildStereopsisAnalysis(percentage);
      case 'near_vision':
        return _buildNearVisionAnalysis(percentage);
      case 'macular':
        return _buildMacularAnalysis(percentage);
      case 'peripheral_vision':
        return _buildPeripheralVisionAnalysis(percentage);
      case 'eye_movement':
        return _buildEyeMovementAnalysis(percentage);
      default:
        return _buildGenericAnalysis(percentage);
    }
  }

  // Visual Acuity Analysis
  Widget _buildVisualAcuityAnalysis(int percentage) {
    final isProblem = percentage < 70;
    final severity = percentage >= 90
        ? 'Normal'
        : percentage >= 70
            ? 'Hafif Düşük'
            : percentage >= 50
                ? 'Orta Düşük'
                : 'Ciddi Düşük';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSection(
          title: 'Görme Keskinliği Değerlendirmesi',
          icon: LucideIcons.eye,
          color: AppColors.medicalBlue,
          children: [
            _buildInfoCard(
              'Mevcut Durum',
              'Görme keskinliğiniz %$percentage seviyesinde. Bu değer $severity kategorisinde değerlendirilmektedir.',
              LucideIcons.info,
              AppColors.medicalBlue,
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (isProblem) ...[
          _buildSection(
            title: 'Olası Problemler',
            icon: LucideIcons.alertCircle,
            color: AppColors.errorRed,
            children: [
              _buildProblemCard(
                'Miyopi (Uzağı Görememe)',
                'Uzak mesafedeki nesneleri net görememe durumu. Genellikle göz küresinin normalden uzun olması veya korneanın çok kavisli olmasından kaynaklanır.',
                [
                  'Uzak nesneleri bulanık görme',
                  'Gözleri kısarak bakma',
                  'Baş ağrısı',
                  'Göz yorgunluğu',
                ],
              ),
              const SizedBox(height: 12),
              _buildProblemCard(
                'Hipermetropi (Yakını Görememe)',
                'Yakın mesafedeki nesneleri net görememe durumu. Göz küresinin normalden kısa olması veya korneanın düz olmasından kaynaklanır.',
                [
                  'Yakın nesneleri bulanık görme',
                  'Okuma zorluğu',
                  'Göz yorgunluğu',
                  'Baş ağrısı',
                ],
              ),
              const SizedBox(height: 12),
              _buildProblemCard(
                'Presbiyopi (Yaşa Bağlı Yakın Görme Problemi)',
                '40 yaş sonrası yakın görme yeteneğinin azalması. Göz merceğinin esnekliğini kaybetmesinden kaynaklanır.',
                [
                  'Yakın okuma zorluğu',
                  'Kolları uzatarak okuma',
                  'Işığa ihtiyaç duyma',
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: 'Olası Sonuçlar ve Etkiler',
            icon: LucideIcons.trendingDown,
            color: AppColors.warningYellow,
            children: [
              _buildConsequenceCard(
                'Günlük Yaşam',
                [
                  'Araç kullanırken zorluk',
                  'Okuma ve yazma problemleri',
                  'Ekran kullanımında yorgunluk',
                  'Sosyal aktivitelerde zorluk',
                ],
              ),
              const SizedBox(height: 12),
              _buildConsequenceCard(
                'İş Hayatı',
                [
                  'Bilgisayar kullanımında zorluk',
                  'Detaylı işlerde hata riski',
                  'Üretkenlik kaybı',
                  'Göz yorgunluğu',
                ],
              ),
              const SizedBox(height: 12),
              _buildConsequenceCard(
                'Sağlık',
                [
                  'Kronik baş ağrıları',
                  'Göz yorgunluğu',
                  'Göz kuruluğu',
                  'Şaşılık riski (çocuklarda)',
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
        _buildSection(
          title: 'Tedavi ve Çözüm Önerileri',
          icon: LucideIcons.heart,
          color: AppColors.successGreen,
          children: [
            _buildSolutionCard(
              'Gözlük Kullanımı',
              'En yaygın ve etkili çözüm. Göz doktorunuzun reçete ettiği gözlükleri düzenli kullanın.',
              LucideIcons.eye,
            ),
            const SizedBox(height: 12),
            _buildSolutionCard(
              'Kontakt Lens',
              'Gözlük kullanmak istemeyenler için alternatif. Göz doktorunuzun önerisiyle kullanılabilir.',
              LucideIcons.circle,
            ),
            const SizedBox(height: 12),
            _buildSolutionCard(
              'Lazer Cerrahisi',
              'Uygun adaylar için kalıcı çözüm. Detaylı muayene sonrası doktorunuz karar verecektir.',
              LucideIcons.zap,
            ),
            const SizedBox(height: 12),
            _buildSolutionCard(
              'Göz Egzersizleri',
              'Bazı durumlarda göz kaslarını güçlendirerek görme kalitesini artırabilir.',
              LucideIcons.activity,
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildWarningCard(),
      ],
    );
  }

  // Color Vision Analysis
  Widget _buildColorVisionAnalysis(int percentage) {
    final hasProblem = percentage < 100;
    final severity = percentage >= 90
        ? 'Hafif'
        : percentage >= 70
            ? 'Orta'
            : 'Ciddi';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSection(
          title: 'Renk Görüşü Değerlendirmesi',
          icon: LucideIcons.palette,
          color: AppColors.medicalTeal,
          children: [
            _buildInfoCard(
              'Mevcut Durum',
              hasProblem
                  ? 'Renk görüşünüzde eksiklik tespit edildi. Bu durum $severity seviyede renk körlüğü olarak değerlendirilmektedir.'
                  : 'Renk görüşünüz normal seviyede. Tüm renkleri doğru şekilde ayırt edebiliyorsunuz.',
              LucideIcons.info,
              AppColors.medicalTeal,
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (hasProblem) ...[
          _buildSection(
            title: 'Renk Körlüğü Çeşitleri',
            icon: LucideIcons.layers,
            color: AppColors.premiumGold,
            children: [
              _buildColorBlindnessTypeCard(
                'Deuteranopia (Yeşil Renk Körlüğü)',
                'Yeşil renkleri ayırt edememe durumu. En yaygın renk körlüğü türüdür.',
                'Yeşil ve kırmızı tonlarını ayırt edememe',
                AppColors.successGreen,
              ),
              const SizedBox(height: 12),
              _buildColorBlindnessTypeCard(
                'Protanopia (Kırmızı Renk Körlüğü)',
                'Kırmızı renkleri ayırt edememe durumu. İkinci en yaygın türdür.',
                'Kırmızı ve yeşil tonlarını ayırt edememe',
                AppColors.errorRed,
              ),
              const SizedBox(height: 12),
              _buildColorBlindnessTypeCard(
                'Tritanopia (Mavi-Sarı Renk Körlüğü)',
                'Mavi ve sarı renkleri ayırt edememe durumu. Daha nadir görülür.',
                'Mavi ve sarı tonlarını ayırt edememe',
                AppColors.medicalBlue,
              ),
              const SizedBox(height: 12),
              _buildColorBlindnessTypeCard(
                'Achromatopsia (Tam Renk Körlüğü)',
                'Tüm renkleri görememe durumu. Çok nadir görülür, sadece siyah-beyaz görüş vardır.',
                'Sadece siyah, beyaz ve gri tonları görme',
                AppColors.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: 'Olası Sonuçlar ve Etkiler',
            icon: LucideIcons.alertTriangle,
            color: AppColors.warningYellow,
            children: [
              _buildConsequenceCard(
                'Günlük Yaşam',
                [
                  'Trafik ışıklarını ayırt etme zorluğu',
                  'Renkli kıyafet seçiminde zorluk',
                  'Yemek pişirme ve olgunluk kontrolü',
                  'Doğa yürüyüşlerinde zorluk',
                ],
              ),
              const SizedBox(height: 12),
              _buildConsequenceCard(
                'İş Hayatı',
                [
                  'Grafik tasarım ve sanat alanlarında zorluk',
                  'Elektrik ve elektronik işlerinde risk',
                  'Tıp ve laboratuvar işlerinde sınırlamalar',
                  'Havacılık ve denizcilik mesleklerinde kısıtlamalar',
                ],
              ),
              const SizedBox(height: 12),
              _buildConsequenceCard(
                'Eğitim',
                [
                  'Renkli materyalleri anlama zorluğu',
                  'Görsel öğrenmede eksiklik',
                  'Bazı derslerde zorluk',
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
        _buildSection(
          title: 'Yönetim ve Destek',
          icon: LucideIcons.lifeBuoy,
          color: AppColors.successGreen,
          children: [
            _buildSolutionCard(
              'Renk Tanımlama Uygulamaları',
              'Akıllı telefon uygulamaları ile renkleri tanımlayabilirsiniz.',
              LucideIcons.smartphone,
            ),
            const SizedBox(height: 12),
            _buildSolutionCard(
              'Özel Gözlükler',
              'Bazı özel gözlükler renk algısını iyileştirebilir. Göz doktorunuza danışın.',
              LucideIcons.eye,
            ),
            const SizedBox(height: 12),
            _buildSolutionCard(
              'Mesleki Danışmanlık',
              'Kariyer seçiminde renk körlüğünü göz önünde bulundurun.',
              LucideIcons.briefcase,
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildInfoCard(
          'Önemli Not',
          'Renk körlüğü genellikle kalıtsaldır ve tam tedavisi yoktur. Ancak özel gözlükler ve uygulamalarla yaşam kalitesi artırılabilir.',
          LucideIcons.info,
          AppColors.medicalTeal,
        ),
        const SizedBox(height: 24),
        _buildWarningCard(),
      ],
    );
  }

  // Astigmatism Analysis
  Widget _buildAstigmatismAnalysis(int percentage) {
    final hasProblem = percentage < 80;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSection(
          title: 'Astigmat Değerlendirmesi',
          icon: LucideIcons.focus,
          color: AppColors.premiumGold,
          children: [
            _buildInfoCard(
              'Mevcut Durum',
              hasProblem
                  ? 'Astigmat tespit edildi. Kornea veya lensin düzensiz şekli nedeniyle görüntü net değil.'
                  : 'Astigmat bulgusu minimal seviyede. Normal görüş seviyesindesiniz.',
              LucideIcons.info,
              AppColors.premiumGold,
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (hasProblem) ...[
          _buildSection(
            title: 'Astigmat Türleri',
            icon: LucideIcons.layers,
            color: AppColors.medicalBlue,
            children: [
              _buildProblemCard(
                'Korneal Astigmat',
                'Korneanın düzensiz şeklinden kaynaklanır. En yaygın türdür.',
                [
                  'Tüm mesafelerde bulanık görüş',
                  'Çizgilerin eğri görünmesi',
                  'Göz yorgunluğu',
                ],
              ),
              const SizedBox(height: 12),
              _buildProblemCard(
                'Lentiküler Astigmat',
                'Göz merceğinin düzensiz şeklinden kaynaklanır.',
                [
                  'Yakın ve uzak görüş problemleri',
                  'Baş ağrısı',
                  'Göz yorgunluğu',
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: 'Olası Sonuçlar',
            icon: LucideIcons.alertCircle,
            color: AppColors.warningYellow,
            children: [
              _buildConsequenceCard(
                'Görüş Kalitesi',
                [
                  'Tüm mesafelerde bulanık görüş',
                  'Çizgilerin eğri görünmesi',
                  'Işık halkaları görme',
                  'Gece görüşünde zorluk',
                ],
              ),
              const SizedBox(height: 12),
              _buildConsequenceCard(
                'Günlük Yaşam',
                [
                  'Okuma zorluğu',
                  'Bilgisayar kullanımında yorgunluk',
                  'Araç kullanımında zorluk',
                  'Baş ağrıları',
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: 'Tedavi Seçenekleri',
            icon: LucideIcons.heart,
            color: AppColors.successGreen,
            children: [
              _buildSolutionCard(
                'Silindirik Gözlük',
                'Astigmat için özel olarak tasarlanmış gözlükler.',
                LucideIcons.eye,
              ),
              const SizedBox(height: 12),
              _buildSolutionCard(
                'Torik Kontakt Lens',
                'Astigmat için özel kontakt lensler.',
                LucideIcons.circle,
              ),
              const SizedBox(height: 12),
              _buildSolutionCard(
                'Lazer Cerrahisi',
                'Uygun adaylar için kalıcı çözüm.',
                LucideIcons.zap,
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
        _buildWarningCard(),
      ],
    );
  }

  // Other test analyses (simplified versions)
  Widget _buildStereopsisAnalysis(int percentage) {
    return _buildGenericTestAnalysis(
      'Vergence Testi',
      percentage,
      'Yakınsama (convergence) ve uzaklaşma (divergence) yeteneğiniz değerlendirilmektedir. Bu test, çift görme (diplopia) ve göz kas koordinasyonu problemlerini tespit eder.',
      'Vergence problemleri göz yorgunluğu, baş ağrısı, okuma zorluğu ve çift görme gibi sorunlara neden olabilir.',
    );
  }

  Widget _buildNearVisionAnalysis(int percentage) {
    return _buildGenericTestAnalysis(
      'Yakın Görme',
      percentage,
      'Yakın mesafedeki görüş yeteneğiniz değerlendirilmektedir.',
      'Yakın görme problemleri okuma, yazma ve detaylı işlerde zorluk yaratabilir.',
    );
  }

  Widget _buildMacularAnalysis(int percentage) {
    return _buildGenericTestAnalysis(
      'Makula Testi',
      percentage,
      'Makula (sarı nokta) sağlığınız değerlendirilmektedir.',
      'Makula problemleri merkezi görüş kaybına neden olabilir.',
    );
  }

  Widget _buildPeripheralVisionAnalysis(int percentage) {
    return _buildGenericTestAnalysis(
      'Periferik Görüş',
      percentage,
      'Yan görüş yeteneğiniz değerlendirilmektedir.',
      'Periferik görüş problemleri çevresel farkındalıkta azalmaya neden olabilir.',
    );
  }

  Widget _buildEyeMovementAnalysis(int percentage) {
    return _buildGenericTestAnalysis(
      'Göz Hareketi',
      percentage,
      'Göz hareket koordinasyonunuz değerlendirilmektedir.',
      'Göz hareket problemleri takip ve odaklanma zorluklarına neden olabilir.',
    );
  }

  Widget _buildGenericTestAnalysis(
    String testName,
    int percentage,
    String description,
    String consequence,
  ) {
    final hasProblem = percentage < 80;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSection(
          title: '$testName Değerlendirmesi',
          icon: LucideIcons.activity,
          color: AppColors.medicalTeal,
          children: [
            _buildInfoCard(
              'Mevcut Durum',
              '$description Sonuç: %$percentage',
              LucideIcons.info,
              AppColors.medicalTeal,
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (hasProblem) ...[
          _buildSection(
            title: 'Olası Sonuçlar',
            icon: LucideIcons.alertCircle,
            color: AppColors.warningYellow,
            children: [
              _buildInfoCard(
                'Etkiler',
                consequence,
                LucideIcons.info,
                AppColors.warningYellow,
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
        _buildSection(
          title: 'Öneriler',
          icon: LucideIcons.heart,
          color: AppColors.successGreen,
          children: [
            _buildSolutionCard(
              'Göz Doktoru Muayenesi',
              'Detaylı muayene için mutlaka bir göz doktoruna başvurun.',
              LucideIcons.stethoscope,
            ),
            const SizedBox(height: 12),
            _buildSolutionCard(
              'Düzenli Kontroller',
              'Göz sağlığınız için düzenli kontroller yaptırın.',
              LucideIcons.calendar,
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildWarningCard(),
      ],
    );
  }

  Widget _buildGenericAnalysis(int percentage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildInfoCard(
          'Test Sonucu',
          'Test sonucunuz: %$percentage',
          LucideIcons.info,
          AppColors.medicalBlue,
        ),
        const SizedBox(height: 24),
        _buildWarningCard(),
      ],
    );
  }

  // Helper widgets
  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildInfoCard(String title, String content, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProblemCard(String title, String description, List<String> symptoms) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.errorRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.errorRed.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.errorRed,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          ...symptoms.map((symptom) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      LucideIcons.circle,
                      size: 6,
                      color: AppColors.errorRed,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        symptom,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildConsequenceCard(String category, List<String> consequences) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warningYellow.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warningYellow.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            category,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.warningYellow,
            ),
          ),
          const SizedBox(height: 12),
          ...consequences.map((consequence) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      LucideIcons.alertTriangle,
                      size: 14,
                      color: AppColors.warningYellow,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        consequence,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildSolutionCard(String title, String description, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.successGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.successGreen.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.successGreen, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorBlindnessTypeCard(
    String title,
    String description,
    String symptom,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(LucideIcons.circle, size: 6, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  symptom,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWarningCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.warningYellow.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.warningYellow.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Icon(
            LucideIcons.alertCircle,
            size: 32,
            color: AppColors.warningYellow,
          ),
          const SizedBox(height: 12),
          Text(
            'Önemli Uyarı',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bu sonuçlar bilgilendirme amaçlıdır ve kesin tanı yerine geçmez. Herhangi bir görme problemi yaşıyorsanız mutlaka bir göz doktoruna başvurun.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getTestName() {
    switch (widget.testType) {
      case 'visual_acuity':
        return 'Görme Keskinliği';
      case 'color_vision':
        return 'Renk Körlüğü';
      case 'astigmatism':
        return 'Astigmat Testi';
      case 'stereopsis':
      case 'binocular_vision':
        return 'Vergence Testi';
      case 'near_vision':
        return 'Yakın Görme';
      case 'macular':
        return 'Makula Testi';
      case 'peripheral_vision':
        return 'Periferik Görüş';
      case 'eye_movement':
        return 'Göz Hareketi';
      default:
        return 'Test Sonucu';
    }
  }

  IconData _getTestIcon() {
    switch (widget.testType) {
      case 'visual_acuity':
        return LucideIcons.eye;
      case 'color_vision':
        return LucideIcons.palette;
      case 'astigmatism':
        return LucideIcons.focus;
      case 'stereopsis':
      case 'binocular_vision':
        return LucideIcons.eye;
      case 'near_vision':
        return LucideIcons.bookOpen;
      case 'macular':
        return LucideIcons.grid;
      case 'peripheral_vision':
        return LucideIcons.scan;
      case 'eye_movement':
        return LucideIcons.move;
      default:
        return LucideIcons.activity;
    }
  }

  Color _getTestColor() {
    switch (widget.testType) {
      case 'visual_acuity':
        return AppColors.medicalBlue;
      case 'color_vision':
        return AppColors.medicalTeal;
      case 'astigmatism':
        return AppColors.premiumGold;
      case 'stereopsis':
      case 'binocular_vision':
        return AppColors.medicalTeal;
      case 'near_vision':
        return AppColors.medicalBlue;
      case 'macular':
        return AppColors.medicalTeal;
      case 'peripheral_vision':
        return AppColors.medicalBlue;
      case 'eye_movement':
        return AppColors.premiumGold;
      default:
        return AppColors.medicalBlue;
    }
  }
}
