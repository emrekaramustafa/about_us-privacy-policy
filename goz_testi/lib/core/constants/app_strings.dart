import 'package:flutter/material.dart';

/// Application String Constants
class AppStrings {
  AppStrings._();

  // App General
  static const String appName = 'Göz Testi';
  static const String appTagline = 'Gözlerinizi Test Edin';
  
  // Splash Screen
  static const String splashSubtitle = 'Göz testleri ve günlük egzersizler';
  
  // Disclaimer
  static const String disclaimerTitle = 'Önemli Uyarı';
  static const String disclaimerContent = '''
Bu uygulama yalnızca bilgilendirme ve eğlence amaçlıdır.

⚠️ Bu uygulama TIBBİ TEŞHİS KOYMAZ.

• Sonuçlar profesyonel göz muayenesi yerine geçmez.
• Herhangi bir görme sorunu yaşıyorsanız mutlaka bir göz doktoruna başvurun.
• Test sonuçları ekran boyutu, parlaklık ve çevre koşullarından etkilenebilir.

Bu uygulamayı kullanarak yukarıdaki koşulları kabul etmiş olursunuz.
''';
  static const String acceptAndContinue = 'Kabul Et ve Devam Et';
  
  // Home Screen
  static const String homeTitle = 'Göz Sağlığı';
  static const String homeSubtitle = 'Testler, egzersizler, ek bilgiler, detaylı sonuçlar';
  static const String freeLabel = 'Ücretsiz';
  static const String premiumLabel = 'Premium';
  
  // Test Categories
  static const String visualAcuityTitle = 'Görme Keskinliği';
  static const String visualAcuityDesc = 'Snellen E Testi';
  static const String colorVisionTitle = 'Renk Körlüğü';
  static const String colorVisionDesc = 'Ishihara Testi';
  static const String astigmatismTitle = 'Astigmat Testi';
  static const String astigmatismDesc = 'Çizgi Diyagramı';
  static const String stereopsisTitle = 'Vergence Testi';
  static const String stereopsisDesc = 'Yakınsama/Uzaklaşma Testi';
  static const String nearVisionTitle = 'Yakın Görme';
  static const String nearVisionDesc = 'Yakın Okuma Testi';
  static const String macularTitle = 'Makula Testi';
  static const String macularDesc = 'Amsler Grid Testi';
  static const String peripheralVisionTitle = 'Periferik Görüş';
  static const String peripheralVisionDesc = 'Kenar Görüş Testi';
  static const String diplopiaTitle = 'Çift Görme';
  static const String diplopiaDesc = 'Binoküler Görüş Testi';
  static const String eyeMovementTitle = 'Hareket Takip';
  static const String eyeMovementDesc = 'Takip Testi';
  static const String contrastTitle = 'Kontrast Hassasiyeti';
  static const String contrastDesc = 'Kontrast Algılama Testi';
  static const String eyeExercisesTitle = 'Göz Egzersizleri';
  static const String eyeExercisesDesc = 'Günlük göz egzersizleri';
  
  // Test Instructions
  static const String testInstructions = 'Test Talimatları';
  static const String startTest = 'Testi Başlat';
  static const String nextQuestion = 'Sonraki';
  static const String finishTest = 'Testi Bitir';
  static const String skipQuestion = 'Atla';
  
  // Visual Acuity Test
  static const String visualAcuityInstructions = '''
• Telefonu göz hizasında tutun.
• Önerilen mesafe: 40 cm.
• E harfinin yönünü seçin.
• Göremiyorsanız "Göremiyorum" butonuna basın.
''';
  static const String cannotSee = 'Göremiyorum';
  static const String directionUp = 'Yukarı';
  static const String directionDown = 'Aşağı';
  static const String directionLeft = 'Sol';
  static const String directionRight = 'Sağ';
  
  // Color Vision Test
  static const String colorVisionInstructions = '''
• Daire içindeki sayıyı girin.
• Hiçbir şey göremiyorsanız boş bırakın.
• Ekran parlaklığını maksimuma ayarlayın.
''';
  static const String enterNumber = 'Gördüğünüz sayıyı girin';
  static const String noNumberVisible = 'Sayı Göremiyorum';
  
  // Astigmatism Test
  static const String astigmatismInstructions = '''
• Diyagrama tek gözle bakın.
• Diğer gözünüzü kapatın.
• Tüm çizgiler eşit mi görünüyor?
''';
  static const String allLinesEqual = 'Tüm Çizgiler Eşit';
  static const String someLinesdarker = 'Bazı Çizgiler Daha Koyu';
  static const String whichEye = 'Hangi gözle bakıyorsunuz?';
  static const String leftEye = 'Sol Göz';
  static const String rightEye = 'Sağ Göz';
  
  // Results
  static const String resultsTitle = 'Test Sonuçları';
  static const String yourScore = 'Puanınız';
  static const String shareResults = 'Sonuçları Paylaş';
  static const String downloadPdf = 'PDF İndir';
  static const String retakeTest = 'Testi Tekrarla';
  static const String nextTest = 'Sonraki Test'; // NEW
  static const String backToHome = 'Ana Sayfaya Dön';
  static const String seeDoctor = 'Göz Doktoruna Danışın';
  
  // Paywall
  static const String paywallTitle = 'Premium\'a Geç';
  static const String paywallSubtitle = 'Tüm testlere erişin ve detaylı raporlar alın';
  static const String unlockAllTests = 'Tüm Testleri Aç';
  static const String getDetailedReports = 'Detaylı Raporlar Al';
  static const String trackProgress = 'İlerlemenizi Takip Edin';
  static const String oneTimePurchase = 'Tek Seferlik Ödeme';
  static const String restore = 'Satın Alımı Geri Yükle';
  static const String continueFreee = 'Ücretsiz Devam Et';
  
  // Errors
  static const String errorGeneric = 'Bir hata oluştu';
  static const String tryAgain = 'Tekrar Dene';
}
