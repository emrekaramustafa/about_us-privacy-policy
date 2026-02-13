# AdMob iOS Reklam Birimi Kurulum ve Onay

Bu dokümanda, iOS uygulamasında **production** reklamların yüklenmesi için AdMob tarafında yapılması gereken adımlar özetlenir. Doğru kurulduğunda tek versiyonda reklamlar çalışır; defalarca versiyon göndermeye gerek kalmaz.

---

## 1. AdMob’da iOS Uygulaması

1. **admob.google.com** → giriş yap.
2. **Apps** → **Add app** (veya mevcut uygulamayı seç).
3. **Platform:** iOS.
4. **App name:** Eye Test – Vision & Exercises (veya mağaza adı).
5. **App store URL:** Uygulama App Store’da yayındaysa linkini yapıştır.
6. **Bundle ID:** `com.eyetest.gozTesti` (Xcode’daki **Bundle Identifier** ile **birebir** aynı olmalı).

Bundle ID yanlışsa reklam dolmaz. Xcode’da kontrol: **Runner** target → **General** → **Bundle Identifier**.

---

## 2. Ad Unit (Rewarded) Oluşturma

1. AdMob’da uygulamayı seç → **Ad units** → **Add ad unit**.
2. **Rewarded** seç.
3. **Ad unit name:** örn. "Rewarded – Extra Test / Detailed Analysis".
4. **Create** → çıkan **Ad unit ID**’yi not al.

Kodda kullanılan iOS production ID: `ca-app-pub-6401639781794250/4036226500`.  
AdMob’da oluşturduğun rewarded ad unit’in ID’si bu olmalı; farklıysa `lib/core/services/ad_service.dart` içindeki production iOS ID’yi bu yeni ID ile değiştir.

---

## 3. App ID (Info.plist)

- **GADApplicationIdentifier** zaten `Info.plist`’te olmalı: `ca-app-pub-6401639781794250~4095936258`.
- Bu değer AdMob’daki **App** ID (uygulama ID’si, `~` ile biten). Ad unit ID değil.
- AdMob’da: **Apps** → iOS uygulaması → **App ID** burada yazar. Aynı değer `Info.plist`’te olmalı.

---

## 4. Uygulama Durumu (Policy / Verification)

1. AdMob’da **Apps** → iOS uygulaması.
2. **App status** “Active” veya “Getting ready” olmalı; “Needs attention” varsa uyarıyı çöz.
3. **Policy** sekmesinde ihlal uyarısı olmamalı.
4. Yeni uygulamalarda bazen **verification** veya onay 24–48 saat sürebilir; bu süre sonunda reklam dolmaya başlayabilir.

---

## 5. Özet Kontrol Listesi

| Kontrol | Nerede | Ne olmalı |
|--------|--------|-----------|
| iOS app var mı? | AdMob → Apps | Evet, platform iOS |
| Bundle ID eşleşiyor mu? | AdMob app ↔ Xcode Bundle Identifier | `com.eyetest.gozTesti` (aynı) |
| Rewarded ad unit var mı? | AdMob → App → Ad units | Evet, tip: Rewarded |
| Ad unit ID doğru mu? | AdMob ad unit ID ↔ ad_service.dart | Aynı ID (4036226500 veya senin ID’n) |
| App ID Info.plist’te mi? | ios/Runner/Info.plist | `GADApplicationIdentifier` = AdMob App ID |
| Uygulama durumu | AdMob → App | Active / Getting ready, policy temiz |

---

## 6. Hâlâ Reklam Gelmiyorsa

- **Test cihazı:** Geliştirme sırasında test cihazı ID’si eklenmiş olabilir; production build’de normal kullanıcı cihazında dene.
- **Bölge / fill:** Bazı bölgelerde veya yeni uygulamalarda fill düşük olabilir; 24–48 saat bekleyip tekrar dene.
- **Log:** Xcode ile release build’i cihaza atıp “Watch Ad” dediğinde konsolda AdMob hata mesajı var mı bak (örn. no fill, invalid app ID).

Bu adımlar tamamlandığında production reklam birimi düzgün kurulmuş ve onay sürecine uygun olur; tek versiyonla reklamların çalışması hedeflenir.
