# Proje Taşıma Talimatları

Bu proje `Desktop/projects` klasörü altına taşınmıştır.

## ✅ Kontrol Edildi

- ✅ Kodda hardcoded path'ler yok (tüm path'ler göreceli)
- ✅ Xcode proje dosyalarında mutlak path'ler yok
- ✅ Android build dosyalarında path sorunları yok
- ✅ Git repository path'leri göreceli

## 📋 Taşıma Sonrası Yapılacaklar

### 1. IDE'yi Yeniden Açın
```bash
# Cursor/VS Code'u kapatın ve yeni konumdan açın:
cd ~/Desktop/projects/eyetest/goz_testi
cursor .  # veya code .
```

### 2. Flutter Clean (Opsiyonel ama Önerilir)
```bash
cd ~/Desktop/projects/eyetest/goz_testi
flutter clean
flutter pub get
```

### 3. Build Cache'leri Temizle (Gerekirse)
```bash
# iOS için
cd ios
pod deintegrate
pod install
cd ..

# Android için (genellikle gerekmez)
cd android
./gradlew clean
cd ..
```

### 4. Test Edin
```bash
# Web'de test
flutter run -d chrome

# iOS'ta test
flutter run -d [device-id]

# Android'de test
flutter run -d [device-id]
```

## ⚠️ Notlar

- **Xcode**: Eğer Xcode açıksa, kapatıp yeni konumdan `ios/Runner.xcworkspace` dosyasını açın
- **Android Studio**: Workspace'i yeni konumdan açın
- **Git**: Git repository'si otomatik olarak yeni konuma taşınır, ek işlem gerekmez

## 🔍 Sorun Giderme

Eğer build hataları alırsanız:
1. `flutter clean` yapın
2. `flutter pub get` yapın
3. iOS için: `cd ios && pod install && cd ..`
4. IDE'yi tamamen kapatıp yeniden açın

---

**Yeni Proje Konumu:** `~/Desktop/projects/eyetest/goz_testi`
