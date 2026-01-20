# 🌍 Yeni Dil Ekleme Rehberi

Yeni bir dil eklemek için aşağıdaki adımları takip edin:

## 🚀 Hızlı Başlangıç

### 1. Script ile ARB Dosyası Oluşturma

```bash
# Python scripti ile (önerilen)
python3 scripts/add_new_language.py it "Italian"

# veya Bash scripti ile
./scripts/add_new_language.sh it "Italian"
```

Bu komut, `lib/l10n/app_it.arb` dosyasını İngilizce template'den oluşturur.

### 2. Çevirileri Yapma

`lib/l10n/app_it.arb` dosyasını açın ve tüm İngilizce metinleri yeni dile çevirin.

**💡 İpucu:** Bir metin editöründe (VS Code, Sublime Text, vb.) "Find & Replace" kullanarak toplu çeviri yapabilirsiniz.

### 3. Locale Provider'ı Güncelleme

`lib/core/providers/locale_provider.dart` dosyasını açın ve yeni dili ekleyin:

```dart
class SupportedLocales {
  // ... mevcut diller ...
  static const Locale italian = Locale('it');  // YENİ

  static const List<Locale> all = [
    turkish,
    english,
    spanish,
    french,
    german,
    portuguese,
    italian,  // YENİ
  ];

  static String getLanguageName(Locale locale) {
    switch (locale.languageCode) {
      // ... mevcut case'ler ...
      case 'it':
        return 'Italiano';  // YENİ
      default:
        return locale.languageCode;
    }
  }

  static String getFlag(Locale locale) {
    switch (locale.languageCode) {
      // ... mevcut case'ler ...
      case 'it':
        return '🇮🇹';  // YENİ
      default:
        return '🌐';
    }
  }
}
```

### 4. Localization Dosyalarını Oluşturma

```bash
flutter gen-l10n
```

Bu komut, yeni dil için gerekli Dart dosyalarını otomatik oluşturur:
- `lib/l10n/app_localizations_it.dart`
- `app_localizations.dart` içindeki `supportedLocales` listesi otomatik güncellenir

### 5. Test Etme

```bash
flutter run
```

Uygulamayı çalıştırın ve Ayarlar > Dil seçiminden yeni dili test edin.

## 📋 Özet Checklist

- [ ] ARB dosyası oluşturuldu (`app_XX.arb`)
- [ ] Tüm metinler çevrildi
- [ ] `locale_provider.dart` güncellendi
- [ ] `flutter gen-l10n` çalıştırıldı
- [ ] Uygulama test edildi

## ⚠️ Önemli Notlar

1. **Otomatik Oluşturulan Dosyalar:** `app_localizations.dart` ve `app_localizations_XX.dart` dosyaları `flutter gen-l10n` tarafından otomatik oluşturulur. Bu dosyaları manuel düzenlemeyin!

2. **Dil Kodu Formatı:** 
   - Basit kod: `it`, `ru`, `ja`
   - Bölgesel kod: `pt-BR`, `zh-CN`, `en-US`

3. **Çeviri Kalitesi:** 
   - Sağlık uygulaması olduğu için çevirilerin doğru ve profesyonel olması önemlidir
   - Tıbbi terimler için dikkatli olun
   - Kültürel uygunluk önemlidir

## 🔧 Sorun Giderme

### "Unsupported locale" hatası
- `flutter gen-l10n` komutunu çalıştırdığınızdan emin olun
- ARB dosyasının doğru formatta olduğunu kontrol edin (JSON syntax)

### Dil listede görünmüyor
- `locale_provider.dart` dosyasında `SupportedLocales.all` listesine eklendiğinden emin olun
- Uygulamayı yeniden başlatın

### Çeviriler görünmüyor
- ARB dosyasındaki key'lerin İngilizce template ile aynı olduğundan emin olun
- `flutter clean && flutter pub get && flutter gen-l10n` komutlarını sırayla çalıştırın

## 📊 İstatistikler

Mevcut durumda:
- **Toplam dil sayısı:** 6 (tr, en, es, fr, de, pt)
- **Toplam çeviri anahtarı:** ~670+ key
- **Egzersiz metinleri:** 32 egzersiz × 3 (title, desc, benefit) = 96 key

Yeni dil eklerken tüm bu key'leri çevirmeniz gerekecek, ancak script sayesinde dosya yapısı otomatik oluşturulur.
