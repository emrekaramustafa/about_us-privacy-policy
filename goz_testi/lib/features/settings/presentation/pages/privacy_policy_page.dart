import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:goz_testi/core/theme/app_colors.dart';
import 'package:goz_testi/core/widgets/scroll_indicator.dart';

/// Privacy Policy Page
/// 
/// Displays the privacy policy and data usage information
class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({super.key});

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage>
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
          'Gizlilik Politikası',
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
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _buildSection(
                    title: '1. Veri Toplama',
                    content: '''
Uygulamamız, hizmetlerimizi sağlamak ve iyileştirmek için aşağıdaki verileri toplayabilir:

• Test sonuçları ve geçmişi (cihazınızda saklanır)
• Kullanım istatistikleri (anonim)
• Cihaz bilgileri (işletim sistemi, model)
• Uygulama performans verileri

Kişisel kimlik bilgileriniz (isim, e-posta, telefon) toplanmaz.
''',
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    title: '2. Veri Kullanımı',
                    content: '''
Toplanan veriler aşağıdaki amaçlarla kullanılır:

• Test sonuçlarınızı görüntülemeniz ve karşılaştırmanız
• Uygulama performansını iyileştirme
• Hata ayıklama ve teknik sorunları çözme
• Kullanıcı deneyimini geliştirme

Verileriniz reklam amaçlı üçüncü taraflarla paylaşılmaz.
''',
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    title: '3. Veri Saklama',
                    content: '''
• Test sonuçları ve geçmişi cihazınızda yerel olarak saklanır
• Uygulamayı silerseniz, tüm verileriniz silinir
• Bulut senkronizasyonu yapılmaz
• Verileriniz güvenli şekilde şifrelenmiş olarak saklanır
''',
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    title: '4. Üçüncü Taraf Hizmetler',
                    content: '''
Uygulamamız aşağıdaki üçüncü taraf hizmetleri kullanabilir:

• Google AdMob: Reklam gösterimi için
• Google Play Services: Uygulama içi satın alımlar için
• Firebase Analytics: Kullanım istatistikleri için (anonim)

Bu hizmetler kendi gizlilik politikalarına tabidir.
''',
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    title: '5. Çocuk Gizliliği',
                    content: '''
Uygulamamız 13 yaş altı çocuklardan bilerek kişisel bilgi toplamaz. 
Eğer bir çocuğun kişisel bilgilerini topladığımızı fark edersek, 
bu bilgileri derhal sileriz.
''',
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    title: '6. Haklarınız',
                    content: '''
Verilerinizle ilgili aşağıdaki haklara sahipsiniz:

• Verilerinize erişim
• Verilerinizi düzeltme
• Verilerinizi silme
• Veri taşınabilirliği
• İtiraz etme hakkı

Bu hakları kullanmak için uygulama ayarlarından verilerinizi silebilirsiniz.
''',
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    title: '7. Değişiklikler',
                    content: '''
Gizlilik politikamızı zaman zaman güncelleyebiliriz. 
Önemli değişiklikler durumunda uygulama içinde bildirim gönderilir.
Son güncelleme tarihi: ${DateTime.now().year} yılı
''',
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    title: '8. İletişim',
                    content: '''
Gizlilik politikamız hakkında sorularınız varsa, 
lütfen uygulama içindeki "Hakkında" bölümünden bizimle iletişime geçin.
''',
                  ),
                  const SizedBox(height: 32),
                  _buildDisclaimer(),
                ],
              ),
            ),
          ),
          ScrollIndicator(scrollController: _scrollController),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.medicalBlue.withOpacity(0.1),
            AppColors.medicalTeal.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.medicalBlue.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.medicalBlue.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.shield,
              size: 32,
              color: AppColors.medicalBlue,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gizlilik Politikası',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Verilerinizin nasıl korunduğunu öğrenin',
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

  Widget _buildSection({required String title, required String content}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 1.6,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.warningYellow.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.warningYellow.withOpacity(0.5),
        ),
      ),
      child: Column(
        children: [
          Icon(
            LucideIcons.info,
            size: 32,
            color: AppColors.warningYellow,
          ),
          const SizedBox(height: 12),
          Text(
            'Önemli Not',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bu gizlilik politikası, uygulamanın veri toplama ve kullanım uygulamalarını açıklar. '
            'Uygulamayı kullanarak bu politikayı kabul etmiş olursunuz.',
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
}
