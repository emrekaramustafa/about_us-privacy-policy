#!/bin/bash

# Yeni dil ekleme scripti
# Kullanım: ./scripts/add_new_language.sh <dil_kodu> <dil_adi>
# Örnek: ./scripts/add_new_language.sh it "Italian"

if [ $# -lt 2 ]; then
    echo "Kullanım: $0 <dil_kodu> <dil_adi>"
    echo "Örnek: $0 it \"Italian\""
    exit 1
fi

LANG_CODE=$1
LANG_NAME=$2
ARB_DIR="lib/l10n"
TEMPLATE_FILE="$ARB_DIR/app_en.arb"
NEW_FILE="$ARB_DIR/app_${LANG_CODE}.arb"

# Template dosyasının var olup olmadığını kontrol et
if [ ! -f "$TEMPLATE_FILE" ]; then
    echo "Hata: Template dosyası bulunamadı: $TEMPLATE_FILE"
    exit 1
fi

# Yeni dosya zaten varsa uyarı ver
if [ -f "$NEW_FILE" ]; then
    echo "Uyarı: $NEW_FILE zaten mevcut!"
    read -p "Üzerine yazmak istiyor musunuz? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "İşlem iptal edildi."
        exit 1
    fi
fi

# Template dosyasını kopyala ve locale'i değiştir
echo "Yeni ARB dosyası oluşturuluyor: $NEW_FILE"
sed "s/\"@@locale\": \"en\"/\"@@locale\": \"${LANG_CODE}\"/" "$TEMPLATE_FILE" > "$NEW_FILE"

echo "✅ $LANG_NAME (${LANG_CODE}) için ARB dosyası oluşturuldu: $NEW_FILE"
echo ""
echo "📝 Şimdi yapmanız gerekenler:"
echo "1. $NEW_FILE dosyasını açın"
echo "2. Tüm İngilizce metinleri $LANG_NAME diline çevirin"
echo "3. Çevirileri tamamladıktan sonra: flutter gen-l10n"
echo ""
echo "💡 İpucu: Dosyayı bir metin editöründe açıp 'Find & Replace' kullanarak"
echo "   tüm çevirileri toplu olarak yapabilirsiniz."
