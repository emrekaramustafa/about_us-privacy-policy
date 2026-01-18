import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:goz_testi/core/theme/app_colors.dart';
import 'package:goz_testi/core/widgets/scroll_indicator.dart';

/// Terms of Service Page
/// 
/// Displays the terms of service and usage conditions
class TermsOfServicePage extends StatefulWidget {
  const TermsOfServicePage({super.key});

  @override
  State<TermsOfServicePage> createState() => _TermsOfServicePageState();
}

class _TermsOfServicePageState extends State<TermsOfServicePage>
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
          'Kullanım Koşulları',
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
                    title: '1. Hizmetin Kullanımı',
                    content: '''
Bu uygulama bilgilendirme ve eğitim amaçlıdır. Uygulamayı kullanarak:

• Uygulamanın yalnızca bilgilendirme amaçlı olduğunu kabul edersiniz
• Test sonuçlarının profesyonel göz muayenesi yerine geçmediğini anlarsınız
• Uygulamayı yasalara uygun şekilde kullanacağınızı taahhüt edersiniz
• Uygulamayı kötüye kullanmayacağınızı kabul edersiniz
''',
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    title: '2. Tıbbi Tavsiye Değildir',
                    content: '''
ÖNEMLİ: Bu uygulama tıbbi tavsiye, teşhis veya tedavi sağlamaz.

• Test sonuçları yalnızca bilgilendirme amaçlıdır
• Herhangi bir görme sorunu yaşıyorsanız mutlaka bir göz doktoruna başvurun
• Test sonuçları ekran boyutu, parlaklık ve çevre koşullarından etkilenebilir
• Uygulama sonuçlarına göre tıbbi karar vermeyin
''',
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    title: '3. Kullanıcı Sorumlulukları',
                    content: '''
Kullanıcı olarak siz:

• Testleri doğru koşullarda yapmakla sorumlusunuz
• Test sonuçlarını yanlış yorumlamaktan sorumlusunuz
• Uygulamayı yasalara uygun kullanmakla sorumlusunuz
• Üçüncü kişilere zarar vermek için kullanmayacağınızı taahhüt edersiniz
''',
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    title: '4. Fikri Mülkiyet',
                    content: '''
• Uygulamanın tüm içeriği telif hakkı ile korunmaktadır
• İçeriği kopyalama, dağıtma veya değiştirme hakkınız yoktur
• Ticari amaçlarla kullanılamaz
• Marka isimleri ve logolar sahiplerine aittir
''',
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    title: '5. Hizmet Değişiklikleri',
                    content: '''
• Uygulama içeriğini ve özelliklerini herhangi bir zamanda değiştirme hakkını saklı tutarız
• Önemli değişiklikler durumunda bildirim gönderilir
• Hizmeti geçici veya kalıcı olarak durdurma hakkımız saklıdır
• Değişikliklerden haberdar olmak için uygulamayı güncel tutun
''',
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    title: '6. Sorumluluk Reddi',
                    content: '''
Uygulama "olduğu gibi" sağlanmaktadır. Aşağıdakilerden sorumlu değiliz:

• Test sonuçlarının doğruluğu veya güvenilirliği
• Uygulama kullanımından kaynaklanan herhangi bir zarar
• Veri kaybı veya cihaz hasarı
• Üçüncü taraf hizmetlerin kesintisi
• Uygulama hataları veya teknik sorunlar
''',
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    title: '7. Ücretli Hizmetler',
                    content: '''
• Uygulama içi satın alımlar (Premium) geri alınamaz
• Satın alımlar Google Play Store veya App Store politikalarına tabidir
• İade talepleri ilgili mağaza politikalarına göre değerlendirilir
• Premium özellikler değiştirilebilir veya kaldırılabilir
''',
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    title: '8. Fesih',
                    content: '''
Aşağıdaki durumlarda hizmetinizi sonlandırabiliriz:

• Koşulları ihlal ettiğinizde
• Yasadışı faaliyetlerde bulunduğunuzda
• Diğer kullanıcılara zarar verdiğinizde
• Uygulamayı kötüye kullandığınızda

Fesih durumunda verileriniz silinebilir.
''',
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    title: '9. Değişiklikler',
                    content: '''
Kullanım koşullarını zaman zaman güncelleyebiliriz. 
Önemli değişiklikler durumunda uygulama içinde bildirim gönderilir.
Koşulları düzenli olarak kontrol etmeniz önerilir.
Son güncelleme tarihi: ${DateTime.now().year} yılı
''',
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    title: '10. İletişim ve Şikayetler',
                    content: '''
Kullanım koşulları hakkında sorularınız veya şikayetleriniz varsa, 
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
            AppColors.medicalTeal.withOpacity(0.1),
            AppColors.medicalBlue.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.medicalTeal.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.medicalTeal.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.fileText,
              size: 32,
              color: AppColors.medicalTeal,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kullanım Koşulları',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Hizmet şartları ve koşullar',
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
            'Bu uygulamayı kullanarak yukarıdaki kullanım koşullarını kabul etmiş olursunuz. '
            'Koşulları kabul etmiyorsanız, lütfen uygulamayı kullanmayın.',
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
