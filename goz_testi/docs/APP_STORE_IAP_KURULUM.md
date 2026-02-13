# App Store – In-App Purchase (Premium) Kurulum Rehberi

Apple, uygulama incelemesini tamamlayamıyor çünkü **Premium** ile ilgili In-App Purchase ürünleri App Store Connect’e eklenmemiş / incelemeye gönderilmemiş. Bu rehber, gerekli IAP’ı oluşturup incelemeye göndermeniz için adımları özetler.

---

## Uygulama tarafında kullanılan değerler

Kodda tanımlı **Product ID** (App Store Connect’te birebir aynı olmalı):

| Alan | Değer |
|------|--------|
| **Product ID** | `com.mekmobiletech.eyetest.premium` |
| **Tip** | **Non-Consumable** (ömür boyu satın alma, abonelik değil) |

Bu ID veya tip değişirse uygulama bu ürünü bulamaz; App Store Connect’te bu şekilde oluşturmanız gerekir.

---

## 1. App Store Connect’te In-App Purchase oluşturma

1. [App Store Connect](https://appstoreconnect.apple.com) → **My Apps** → ilgili uygulamanız.
2. Sol menüden **Monetization** altındaki **In-App Purchases** (veya **Uygulama İçi Satın Almalar**) bölümüne girin.
3. **+** (Manage) ile yeni In-App Purchase ekleyin.
4. **Type** olarak **Non-Consumable** seçin → **Create**.
5. Aşağıdaki alanları doldurun:

| Alan | Örnek / Açıklama |
|------|-------------------|
| **Reference Name** | Örn. `Premium Lifetime` (sadece sizin gördüğünüz isim) |
| **Product ID** | `com.mekmobiletech.eyetest.premium` (**tam bu şekilde** yazın) |
| **Price** | İstediğiniz fiyat tier’ı (ör. Tier 3, Tier 5 vb.) |

Product ID’yi kesinlikle `com.mekmobiletech.eyetest.premium` olarak girin; kodda bu ID kullanılıyor.

---

## 2. In-App Purchase metadata (zorunlu alanlar)

**App Store Localization** kısmında en az **Primary Language** (genelde İngilizce) için şunları doldurun:

| Alan | Örnek |
|------|--------|
| **Display Name** | Örn. `Premium – Lifetime Access` |
| **Description** | Örn. `Unlock all tests, detailed reports, exercise history, and ad-free experience. One-time purchase.` |

Diğer dilleri de ekleyebilirsiniz; en az ana dil zorunludur.

---

## 3. App Review Screenshot (Apple’ın istediği ekran görüntüsü)

Apple, In-App Purchase’ları inceleyebilmek için **uygulama içinde satın almanın nerede göründüğünü** gösteren bir ekran görüntüsü istiyor.

**Ne yapmalısınız:**

1. Simulator veya gerçek cihazda uygulamayı çalıştırın.
2. **Premium’a Geç / Go Premium** sayfasına gidin (paywall ekranı).
   - Örn. Ana sayfada “Premium’a Geç” / “Go Premium” butonuna basın veya günlük test bilgi sayfasındaki Premium bölümüne gidin.
3. Bu ekranın **tam ekran** bir ekran görüntüsünü alın (özellikle fiyat ve “Premium” / “Go Premium” metni görünsün).
4. App Store Connect’te ilgili In-App Purchase sayfasında **App Review Information** bölümüne gidin.
5. **Screenshot** alanına bu ekran görüntüsünü yükleyin.

**Önemli:** App Review Screenshot alanı **cihaz ekran boyutlarında** (ör. iPhone 1242×2688, 1290×2796) olmalıdır. **1024×1024 bu alana uygun değildir** – Apple “screenshot specifications your app supports” derken cihaz çözünürlüklerini kasteder. Orijinal, resize edilmemiş paywall ekran görüntüsünü (simulator veya telefonda alınan) bu alana yükleyin. 1024×1024 görsel yalnızca **Image (Optional)** / promotional alanı içindir (72 dpi, RGB, flattened).

Önerilen çözünürlük: iPhone 1290×2796 (14 Pro Max), iPad 11" 1668×2388 (portrait). PNG veya JPG, RGB, flattened, 72 dpi.

**iPhone 14 Pro Max orijinal boyutu ile yükleyip kabul etmediyse:** Apple bu uygulamayı **iPad Air 11-inch (M3)** üzerinde inceledi. IAP screenshot’ı için **iPad simulator**’da paywall ekranının ekran görüntüsünü alıp (1668×2388) yüklemeyi dene. Teknik uyum (RGB, 72 dpi) için: `python3 scripts/prepare_iap_review_screenshot.py paywall_ss.png ipad` → çıkan `*_review_ready.png` dosyasını App Review Screenshot alanına yükle.

Bu adım atlanırsa IAP incelemeye alınmayabilir; mutlaka ekleyin.

---

## 4. IAP’ı incelemeye gönderme

1. In-App Purchase kaydını **Complete** olacak şekilde tamamlayın (tüm zorunlu alanlar + screenshot dolu olsun).
2. Bu IAP’ı, incelemeye göndereceğiniz **app version** ile ilişkilendirin:
   - Uygulamanızın **App Store** sekmesinde ilgili version’ı (ör. 1.0) açın.
   - **In-App Purchases** bölümünde bu Premium ürününün listelendiğinden emin olun; gerekirse buradan ekleyin/seçin.
3. **Save** ile kaydedin.
4. Yeni bir **binary (build)** yükleyin (Archive → Upload to App Store).
5. Bu version ile uygulamayı tekrar **Submit for Review** yapın.

IAP’lar, seçili app version ile birlikte incelemeye gider. Sadece binary yükleyip IAP’ı eklemeden gönderirseniz aynı red tekrarlanır.

---

## 5. Kontrol listesi (göndermeden önce)

- [ ] In-App Purchase oluşturuldu, tip **Non-Consumable**.
- [ ] Product ID tam olarak: `com.mekmobiletech.eyetest.premium`.
- [ ] Reference Name, fiyat ve en az bir dil için Display Name + Description dolduruldu.
- [ ] **App Review Information** altında **App Review Screenshot** yüklendi (Premium / Go Premium ekranı).
- [ ] IAP, incelemeye göndereceğiniz app version’a bağlandı.
- [ ] Yeni binary yüklendi.
- [ ] Uygulama **Submit for Review** ile tekrar gönderildi.

---

## 6. Promosyon görseli (Guideline 2.3.2)

Apple, IAP **promosyon görselinin** uygulama ekran görüntüsü olmamasını ve metnin okunaklı olmasını istiyor.

**Seçenek A – Promosyon kullanmayacaksanız:**  
App Store Connect → In-App Purchases → ilgili ürün → **Promotional Image (Optional)** alanındaki görseli **silin**. Bu alan boş bırakılabilir.

**Seçenek B – Promosyon kullanacaksanız:**  
- Görsel **uygulama ekran görüntüsü olmamalı**; IAP'ı temsil eden özel bir tasarım olmalı.  
- Metin **büyük ve okunaklı** olmalı (küçük yazı red sebebi).

---

## 7. Paid Apps Agreement (IAP'ın çalışması için zorunlu)

In-App Purchase'ların **sandbox ve incelemede** çalışması için **Account Holder**'ın **Paid Apps Agreement**'ı kabul etmiş olması gerekir.

1. App Store Connect → **Agreements, Tax, and Banking**.  
2. **Paid Apps** satırında durum **Active** olmalı.  
3. **Pending** veya eksikse: **Request Contracts** ile sözleşmeyi açıp **Account Holder** olarak kabul edin.

Sözleşme aktif değilse StoreKit ürün listesini döndürmeyebilir; uygulama "spinner dönüyor / satın alınamıyor" gibi görünebilir.

---

## 8. TestFlight'ta satın alma (IAP) testi

TestFlight sürümünde Premium satın almayı test edebilmek için aşağıdakilerin hepsi tamam olmalı.

### App Store Connect ayarları

| Kontrol | Açıklama |
|--------|----------|
| **Paid Apps Agreement** | Agreements, Tax, and Banking → **Paid Apps** satırı **Active** olmalı. Banka hesabı + vergi formları tamamlanınca Active olur. |
| **IAP ürünü** | In-App Purchases → `com.mekmobiletech.eyetest.premium` kayıtlı, **Ready to Submit** veya onaylanmış olmalı. |
| **IAP version'a bağlı** | App Store → ilgili version (1.0) → **In-App Purchases** bölümünde bu ürün listelenmeli. |
| **Build** | TestFlight'ta test ettiğin build, bu IAP'ı içeren (Archive ile yüklenen) build olmalı. |

### Sandbox tester (test hesabı)

1. App Store Connect → **Users and Access** (veya **Kullanıcılar ve Erişim**).
2. Sol menüde **Sandbox** → **Testers** (veya **Sandbox Testers**) bölümüne gir.
3. **+** ile yeni **Sandbox Tester** ekle:
   - **E-posta:** Gerçek bir mail olmak zorunda değil; test için kullanacağın bir adres (örn. `test.eyetest@gmail.com` veya kendi domain’in). Bu hesap **sadece sandbox** için; gerçek App Store’da kullanılmaz.
   - **Şifre:** Kendi belirlediğin şifre (en az 8 karakter).
   - **Ülke / bölge:** Test edeceğin bölge (örn. Türkiye veya United States).
4. **Save** ile kaydet.

### Cihazda (iPhone / iPad) ayarlar

1. **Sandbox hesabı ile giriş:**
   - **Ayarlar** → **App Store** → en alta in → **Sandbox Hesabı** (veya **Sandbox Account**) bölümü.
   - **Sandbox Hesabıyla Oturum Aç** (veya **Sign In**) de; yukarıda oluşturduğun **Sandbox Tester** e-posta ve şifresini gir.
2. TestFlight uygulamasını aç, Eye Test’i yükle.
3. Uygulama içinde **Premium’a Geç** / **Continue with Premium** ekranına git ve satın almayı dene.
4. Çıkan ödeme ekranı **sandbox** ortamında açılır; gerçek para çekilmez. Onaylayınca satın alma tamamlanır.

### Sık karşılaşılan sorunlar

- **Fiyat gelmiyor / spinner bitmiyor:** Paid Apps Agreement **Active** mi kontrol et; banka + vergi tamamlanmamışsa ürün listesi gelmeyebilir.
- **“Ürün bulunamadı” / hata:** Product ID `com.mekmobiletech.eyetest.premium` App Store Connect’te aynen bu mu, IAP ilgili version’a bağlı mı kontrol et.
- **Ödeme ekranı çıkmıyor:** Cihazda **Sandbox Hesabı** ile giriş yapılı olmalı; normal Apple ID ile TestFlight kullanıyorsan IAP testi için Ayarlar → App Store → Sandbox Hesabı’ndan sandbox hesabıyla oturum aç.

---

## 9. Faydalı linkler

- [In-App Purchase’ları incelemeye gönderme](https://developer.apple.com/help/app-store-connect/submit-your-app-for-review/submit-in-app-purchases-and-subscriptions-to-app-review)
- [In-App Purchase metadata gereksinimleri](https://developer.apple.com/help/app-store-connect/create-in-app-purchase-products/required-in-app-purchase-metadata)

---

**Özet:** App Store Connect’te `com.mekmobiletech.eyetest.premium` ID’li, **Non-Consumable** bir Premium ürünü oluşturun, zorunlu metinleri ve **App Review screenshot**’ını ekleyin, **Paid Apps Agreement**'ın aktif olduğundan emin olun, **Promotional Image**'ı silin veya kurallara uygun hale getirin, ilgili app version ile ilişkilendirip yeni binary ile birlikte tekrar incelemeye gönderin.
