# iOS TestFlight Build Rehberi

## Ön Gereksinimler

1. **Apple Developer Account** (ücretli, yıllık $99)
2. **Xcode** (Mac App Store'dan indirin)
3. **CocoaPods** yüklü olmalı:
   ```bash
   sudo gem install cocoapods
   ```

## Versiyonlama

Versiyon `pubspec.yaml` dosyasında tanımlı:
```yaml
version: 1.0.0+1
```
- `1.0.0` = Kullanıcıya gösterilen versiyon (Version Name)
- `1` = Build number (her yüklemede artırılmalı)

## Build Adımları

### 1. Flutter Temizleme ve Bağımlılıkları Güncelleme
```bash
cd goz_testi
flutter clean
flutter pub get
cd ios
pod install
cd ..
```

### 2. iOS Build (Release)
```bash
flutter build ios --release
```

### 3. Xcode'da Açma ve Yapılandırma
```bash
open ios/Runner.xcworkspace
```

Xcode'da:
1. **Signing & Capabilities** sekmesine gidin
2. **Team** seçin (Apple Developer hesabınız)
3. **Bundle Identifier** kontrol edin: `com.eyetest.gozTesti`
4. **Automatically manage signing** işaretli olsun

### 4. Archive Oluşturma
1. Xcode'da üst menüden: **Product > Destination > Any iOS Device**
2. **Product > Archive** seçin
3. Archive tamamlandığında **Organizer** penceresi açılır

### 5. TestFlight'a Yükleme
1. **Organizer** penceresinde **Distribute App** butonuna tıklayın
2. **App Store Connect** seçin
3. **Upload** seçin
4. **Automatically manage signing** seçin
5. **Upload** butonuna tıklayın

### 6. App Store Connect'te Kontrol
1. [App Store Connect](https://appstoreconnect.apple.com) sitesine gidin
2. **My Apps** > Uygulamanızı seçin
3. **TestFlight** sekmesine gidin
4. Build'in işlenmesini bekleyin (5-30 dakika)
5. Build hazır olduğunda **Testers** ekleyin

## Versiyon Güncelleme

Her yeni build için `pubspec.yaml`'daki build number'ı artırın:

```yaml
version: 1.0.0+2  # +1'den +2'ye
```

Veya komut satırından:
```bash
flutter build ios --release --build-number=2
```

## Hızlı Build Komutu (Tek Satır)

```bash
cd goz_testi && flutter clean && flutter pub get && cd ios && pod install && cd .. && flutter build ios --release
```

## Notlar

- İlk kez yükleme için App Store Connect'te uygulama oluşturmanız gerekir
- Bundle ID benzersiz olmalı (com.eyetest.gozTesti)
- Her build için build number artırılmalı
- TestFlight build'leri 90 gün geçerlidir
