#!/usr/bin/env python3
"""
Yeni dil ekleme scripti
Kullanım: python3 scripts/add_new_language.py <dil_kodu> <dil_adi>
Örnek: python3 scripts/add_new_language.py it "Italian"
"""

import sys
import os
import json
import re

def create_new_language_arb(lang_code, lang_name):
    """Yeni bir dil için ARB dosyası oluşturur"""
    
    arb_dir = "lib/l10n"
    template_file = os.path.join(arb_dir, "app_en.arb")
    new_file = os.path.join(arb_dir, f"app_{lang_code}.arb")
    
    # Template dosyasının var olup olmadığını kontrol et
    if not os.path.exists(template_file):
        print(f"❌ Hata: Template dosyası bulunamadı: {template_file}")
        return False
    
    # Yeni dosya zaten varsa uyarı ver
    if os.path.exists(new_file):
        response = input(f"⚠️  {new_file} zaten mevcut! Üzerine yazmak istiyor musunuz? (y/n): ")
        if response.lower() != 'y':
            print("❌ İşlem iptal edildi.")
            return False
    
    # Template dosyasını oku
    try:
        with open(template_file, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception as e:
        print(f"❌ Template dosyası okunamadı: {e}")
        return False
    
    # Locale'i değiştir
    content = content.replace('"@@locale": "en"', f'"@@locale": "{lang_code}"')
    
    # Yeni dosyayı oluştur
    try:
        with open(new_file, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"✅ {lang_name} ({lang_code}) için ARB dosyası oluşturuldu: {new_file}")
    except Exception as e:
        print(f"❌ Dosya oluşturulamadı: {e}")
        return False
    
    # İstatistikleri göster
    try:
        with open(new_file, 'r', encoding='utf-8') as f:
            data = json.load(f)
        total_keys = len([k for k in data.keys() if not k.startswith('@@')])
        print(f"📊 Toplam {total_keys} çeviri anahtarı eklendi")
    except:
        pass
    
    print("\n📝 Şimdi yapmanız gerekenler:")
    print(f"1. {new_file} dosyasını açın")
    print(f"2. Tüm İngilizce metinleri {lang_name} diline çevirin")
    print("3. Çevirileri tamamladıktan sonra: flutter gen-l10n")
    print("\n💡 İpucu: Dosyayı bir metin editöründe açıp 'Find & Replace' kullanarak")
    print("   tüm çevirileri toplu olarak yapabilirsiniz.")
    print("\n🔧 Ayrıca main.dart dosyasında locale listesine yeni dili eklemeyi unutmayın!")
    
    return True

def main():
    if len(sys.argv) < 3:
        print("Kullanım: python3 scripts/add_new_language.py <dil_kodu> <dil_adi>")
        print('Örnek: python3 scripts/add_new_language.py it "Italian"')
        sys.exit(1)
    
    lang_code = sys.argv[1]
    lang_name = sys.argv[2]
    
    # Dil kodunu kontrol et (2-5 karakter arası olmalı)
    if not re.match(r'^[a-z]{2}(-[A-Z]{2})?$', lang_code):
        print(f"⚠️  Uyarı: '{lang_code}' standart bir dil kodu formatına uymuyor.")
        print("   Örnek formatlar: 'it', 'pt-BR', 'zh-CN'")
        response = input("   Devam etmek istiyor musunuz? (y/n): ")
        if response.lower() != 'y':
            sys.exit(1)
    
    success = create_new_language_arb(lang_code, lang_name)
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()
