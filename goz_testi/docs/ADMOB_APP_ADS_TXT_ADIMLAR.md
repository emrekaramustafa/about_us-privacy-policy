# AdMob app-ads.txt Doğrulama – Yapılanlar ve Senin Adımların

Geliştirici sitesi projede zaten var: **https://emrekaramustafa.github.io/goz-testi/** (docs/README.md). Aşağıda yapılanlar ve sadece senin yapman gerekenler yazıyor.

---

## Yapılanlar (projede)

1. **app-ads.txt oluşturuldu**  
   - Konum: **docs/app-ads.txt** (repo kökündeki `docs/` klasörü).  
   - GitHub Pages kaynağı “main → /docs” olduğu için bu dosya yayında **site kökünde** olur:  
     **https://emrekaramustafa.github.io/goz-testi/app-ads.txt**

2. **İçerik (AdMob Publisher ID ile uyumlu):**
   ```
   google.com, pub-6401639781794250, DIRECT, f08c47fec0942fa0
   ```
   - Info.plist’teki `GADApplicationIdentifier`: `ca-app-pub-6401639781794250~4095936258` → Publisher ID: **6401639781794250**.

3. **docs/README.md** güncellendi; app-ads.txt sayfa listesine eklendi.

---

## Senin yapacakların (sırayla)

### 1. Değişiklikleri GitHub’a push et

- `docs/app-ads.txt` ve `docs/README.md` değişikliklerini commit edip **main** (veya Pages’in deploy ettiği branch) üzerine push et.  
- Birkaç dakika sonra GitHub Pages güncellenir.

### 2. app-ads.txt’in yayında olduğunu kontrol et

- Tarayıcıda aç: **https://emrekaramustafa.github.io/goz-testi/app-ads.txt**  
- Sayfada şu satır görünmeli (yorum satırları da olabilir):  
  `google.com, pub-6401639781794250, DIRECT, f08c47fec0942fa0`  
- Görünmüyorsa: GitHub repo’da **Settings → Pages** bölümünde “Source” **main** ve **/docs** olarak ayarlı mı kontrol et.

### 3. AdMob’da app-ads.txt doğrulamasını tetikle

1. **admob.google.com** → **Apps** → **Eye Test – Vision & Exercises (iOS)**.  
2. **Verification issues** / **app-ads.txt** uyarısının olduğu sayfaya gir.  
3. Gerekirse “App-ads.txt URL” alanına şunu yaz:  
   **https://emrekaramustafa.github.io/goz-testi/**  
   (AdMob bazen domain’i kendisi türetir; bazen URL girmen istenir.)  
4. **“Check for updates”** (Güncellemeleri kontrol et) mavi butonuna tıkla.

### 4. Doğrulamayı bekle

- Doğrulama birkaç saat ile 24 saat sürebilir.  
- Aynı uygulama sayfasında **App status** “Requires review” yerine “Active” (veya onaylı) olana kadar bekle.  
- **Ads activity** bölümünde **Impressions** ve **Match rate** 0’dan yukarı çıkmaya başlayınca reklamlar doluyor demektir.

### 5. Uygulamada test et

1. Telefonda App Store (veya TestFlight) sürümünü aç.  
2. **Günlük test bilgisi** / **Reklam izle** ekranına gir.  
3. **“Watch Ad for Extra Test”** (veya benzeri) butonuna bas.  
4. Reklam açılıyorsa doğrulama tamamlanmış ve reklamlar çalışıyor demektir.

---

## Özet

| Ne | Durum |
|----|--------|
| Geliştirici sitesi | https://emrekaramustafa.github.io/goz-testi/ (projede mevcut) |
| app-ads.txt dosyası | docs/app-ads.txt olarak eklendi |
| Yayında adres | https://emrekaramustafa.github.io/goz-testi/app-ads.txt (push sonrası) |
| Senin yapacakların | Push → URL’yi kontrol et → AdMob’da “Check for updates” → Bekle → Uygulamada test et |

---

## Sorun olursa

- **“Details don’t match”:** AdMob’da **Account / Publisher ID** ile app-ads.txt’teki `pub-6401639781794250` birebir aynı olmalı.  
- **“File not found”:** Sadece **https://emrekaramustafa.github.io/goz-testi/app-ads.txt** kullanılmalı; `/docs/app-ads.txt` AdMob için geçerli değil.  
- **Hâlâ 0 impression:** Doğrulama 24 saate kadar sürebilir; bir kez “Check for updates” yaptıktan sonra bekleyip tekrar kontrol et.
