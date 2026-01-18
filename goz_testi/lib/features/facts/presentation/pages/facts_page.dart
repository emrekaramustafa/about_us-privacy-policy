import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:goz_testi/core/theme/app_colors.dart';
import 'package:goz_testi/core/router/app_router.dart';
import 'package:goz_testi/core/widgets/app_button.dart';

/// Facts Page - "Biliyor muydunuz?" section
class FactsPage extends StatefulWidget {
  const FactsPage({super.key});

  @override
  State<FactsPage> createState() => _FactsPageState();
}

class _FactsPageState extends State<FactsPage> {
  int _currentFactIndex = 0;
  
  final List<Map<String, dynamic>> _facts = [
    {
      'title': 'Göz Kırpma',
      'fact': 'Ekrana bakarken göz kırpma sayımız %60\'a kadar azalır.',
      'icon': LucideIcons.monitor,
      'color': AppColors.medicalBlue,
    },
    {
      'title': 'Bebek Görüşü',
      'fact': 'Bebekler doğduğunda dünyayı bulanık ve renksiz görür.',
      'icon': LucideIcons.heart,
      'color': AppColors.medicalTeal,
    },
    {
      'title': 'Göz Büyümesi',
      'fact': 'Gözlerimiz ömür boyu büyümez, ama kulaklar ve burun büyümeye devam eder.',
      'icon': LucideIcons.eye,
      'color': AppColors.premiumGold,
    },
    {
      'title': 'Karanlıkta Görüş',
      'fact': 'Karanlıkta daha iyi görmek için nesnelere direkt bakmak yerine biraz yanından bakmak daha etkilidir.',
      'icon': LucideIcons.moon,
      'color': AppColors.medicalBlue,
    },
    {
      'title': 'Renk Körlüğü',
      'fact': 'Erkeklerin yaklaşık %8\'i, kadınların ise sadece %0,5\'i renk körüdür.',
      'icon': LucideIcons.palette,
      'color': AppColors.medicalTeal,
    },
    {
      'title': 'Renk Algısı',
      'fact': 'Aynı renge bakan iki kişi onu birebir aynı görmez.',
      'icon': LucideIcons.eye,
      'color': AppColors.premiumGold,
    },
    {
      'title': 'Mor Renk',
      'fact': 'Mor, spektrumda gerçek bir renk değildir; beyin kırmızı ve maviyi karıştırarak üretir.',
      'icon': LucideIcons.sparkles,
      'color': AppColors.medicalBlue,
    },
    {
      'title': 'Renk Ayırt Etme',
      'fact': 'İnsan gözü teorik olarak 10 milyon farklı rengi ayırt edebilir.',
      'icon': LucideIcons.rainbow,
      'color': AppColors.medicalTeal,
    },
    {
      'title': 'Göz Hareketi',
      'fact': 'Gözlerimiz sürekli hareket eder; sabit durursa görüntü birkaç saniyede kaybolur.',
      'icon': LucideIcons.move,
      'color': AppColors.premiumGold,
    },
    {
      'title': 'Beyin ve Görme',
      'fact': 'Beynin arka kısmının %30\'dan fazlası doğrudan görmeyle ilgilidir.',
      'icon': LucideIcons.cpu,
      'color': AppColors.medicalBlue,
    },
    {
      'title': 'Karanlık Mod',
      'fact': 'Karanlık mod göz yorgunluğunu değil, enerji tüketimini azaltır.',
      'icon': LucideIcons.moonStar,
      'color': AppColors.medicalTeal,
    },
    {
      'title': 'Kedi Görüşü',
      'fact': 'Kediler, insanlara göre 6 kat daha az ışıkla görebilir.',
      'icon': LucideIcons.sparkles,
      'color': AppColors.premiumGold,
    },
    {
      'title': 'Mantis Karidesi',
      'fact': 'Mantis karideslerinin gözlerinde 12–16 farklı renk algılayıcı vardır (insanda sadece 3). Ultraviyole ışığı da görebilirler.',
      'icon': LucideIcons.waves,
      'color': AppColors.medicalBlue,
    },
    {
      'title': 'Kartal Görüşü',
      'fact': 'Bir kartal, 3–4 kilometre uzaktaki küçük bir avı net şekilde seçebilir.',
      'icon': LucideIcons.eye,
      'color': AppColors.medicalTeal,
    },
    {
      'title': 'Baykuş Görüşü',
      'fact': 'Baykuşların gözleri tüp şeklindedir ve göz küresi hareket edemez. Bu yüzden kafalarını 270 derece döndürebilirler.',
      'icon': LucideIcons.moon,
      'color': AppColors.premiumGold,
    },
    {
      'title': 'Balina Görüşü',
      'fact': 'Balinalar su altında çok iyi görürler ve renk körü değillerdir. Ancak su yüzeyinde görüşleri sınırlıdır.',
      'icon': LucideIcons.waves,
      'color': AppColors.medicalBlue,
    },
    {
      'title': 'Köpek Görüşü',
      'fact': 'Köpekler kırmızı ve yeşili ayırt edemezler. Dünyayı sarı, mavi ve gri tonlarında görürler.',
      'icon': LucideIcons.heart,
      'color': AppColors.medicalTeal,
    },
    {
      'title': 'Yılan Görüşü',
      'fact': 'Yılanlar kızılötesi ışığı algılayabilir ve sıcaklık farklarını "görebilirler". Bu sayede karanlıkta avlarını bulabilirler.',
      'icon': LucideIcons.eye,
      'color': AppColors.premiumGold,
    },
    {
      'title': 'Kör Mağara Balığı',
      'fact': 'Kör mağara balıkları tamamen kör doğar ama diğer duyuları o kadar gelişmiştir ki su akıntılarını "hissederek" yön bulabilirler.',
      'icon': LucideIcons.waves,
      'color': AppColors.medicalBlue,
    },
    {
      'title': 'Bukalemun Gözleri',
      'fact': 'Bukalemunların gözleri birbirinden bağımsız hareket edebilir. Bir göz avı izlerken diğeri çevreyi tarayabilir.',
      'icon': LucideIcons.eye,
      'color': AppColors.medicalTeal,
    },
    {
      'title': 'Kelebek Görüşü',
      'fact': 'Kelebekler ultraviyole ışığı görebilir ve çiçeklerin üzerindeki görünmez desenleri algılayabilirler.',
      'icon': LucideIcons.sparkles,
      'color': AppColors.premiumGold,
    },
    {
      'title': 'Köpekbalığı Görüşü',
      'fact': 'Köpekbalıkları karanlıkta insanlardan 10 kat daha iyi görür. Ayrıca su altında renkleri ayırt edebilirler.',
      'icon': LucideIcons.waves,
      'color': AppColors.medicalBlue,
    },
    {
      'title': 'At Görüşü',
      'fact': 'Atların gözleri kafalarının yanlarında olduğu için neredeyse 360 derece görüş alanına sahiptirler.',
      'icon': LucideIcons.eye,
      'color': AppColors.medicalTeal,
    },
    {
      'title': 'Yunus Görüşü',
      'fact': 'Yunuslar her gözü bağımsız kullanabilir. Bir göz su yüzeyini, diğeri su altını izleyebilir.',
      'icon': LucideIcons.waves,
      'color': AppColors.premiumGold,
    },
    {
      'title': 'Örümcek Gözleri',
      'fact': 'Bazı örümceklerin 8 gözü vardır. Her göz farklı bir işlev görür: bazıları hareketi, bazıları detayları algılar.',
      'icon': LucideIcons.eye,
      'color': AppColors.medicalBlue,
    },
    {
      'title': 'Kör Fare',
      'fact': 'Kör fareler tamamen kör doğar ama koku alma ve dokunma duyuları o kadar gelişmiştir ki tünellerinde hiç kaybolmazlar.',
      'icon': LucideIcons.heart,
      'color': AppColors.medicalTeal,
    },
    {
      'title': 'Papağan Görüşü',
      'fact': 'Papağanlar ultraviyole ışığı görebilir ve bu sayede olgun meyveleri daha kolay bulabilirler.',
      'icon': LucideIcons.eye,
      'color': AppColors.premiumGold,
    },
    {
      'title': 'Köpek Balığı Retina',
      'fact': 'Köpekbalıklarının retinasında özel hücreler vardır ve bu sayede çok düşük ışık seviyelerinde bile avlarını görebilirler.',
      'icon': LucideIcons.waves,
      'color': AppColors.medicalBlue,
    },
    {
      'title': 'Gece Hayvanları',
      'fact': 'Gece hayvanlarının gözlerinde tapetum lucidum adı verilen özel bir tabaka vardır. Bu tabaka ışığı yansıtarak görüşü artırır.',
      'icon': LucideIcons.moon,
      'color': AppColors.medicalTeal,
    },
    {
      'title': 'Yarasa Görüşü',
      'fact': 'Yarasalar kör değildir! Görüşleri zayıf olsa da karanlıkta yön bulmak için ekolokasyon kullanırlar.',
      'icon': LucideIcons.moon,
      'color': AppColors.premiumGold,
    },
  ];

  void _nextFact() {
    if (_currentFactIndex < _facts.length - 1) {
      setState(() {
        _currentFactIndex++;
      });
    } else {
      // Go back to home or show completion
      context.pop();
    }
  }

  void _previousFact() {
    if (_currentFactIndex > 0) {
      setState(() {
        _currentFactIndex--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentFact = _facts[_currentFactIndex];
    
    return Scaffold(
      backgroundColor: AppColors.cleanWhite,
      appBar: AppBar(
        backgroundColor: AppColors.cleanWhite,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Biliyor muydunuz?',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                '${_currentFactIndex + 1} / ${_facts.length}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            LinearProgressIndicator(
              value: (_currentFactIndex + 1) / _facts.length,
              backgroundColor: AppColors.backgroundGrey,
              valueColor: AlwaysStoppedAnimation<Color>(currentFact['color']),
              minHeight: 4,
            ),
            
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: (currentFact['color'] as Color).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          currentFact['icon'],
                          size: 64,
                          color: currentFact['color'],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Title
                    Text(
                      currentFact['title'],
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Fact text
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.borderLight,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        currentFact['fact'],
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          height: 1.6,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Navigation buttons
                    Row(
                      children: [
                        if (_currentFactIndex > 0)
                          Expanded(
                            child: AppButton(
                              text: 'Önceki',
                              icon: LucideIcons.arrowLeft,
                              onPressed: _previousFact,
                              isOutlined: true,
                              backgroundColor: currentFact['color'],
                              textColor: currentFact['color'],
                            ),
                          ),
                        if (_currentFactIndex > 0) const SizedBox(width: 16),
                        Expanded(
                          child: AppButton(
                            text: _currentFactIndex < _facts.length - 1
                                ? 'Sonraki'
                                : 'Tamamla',
                            icon: _currentFactIndex < _facts.length - 1
                                ? LucideIcons.arrowRight
                                : LucideIcons.check,
                            onPressed: _nextFact,
                            backgroundColor: currentFact['color'],
                          ),
                        ),
                      ],
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

