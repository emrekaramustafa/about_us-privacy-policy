#!/usr/bin/env python3
"""
Ekran görüntüsünü 1024x1024 boyutuna getirir.
Oran korunur; boş kalan kısımlar beyaz dolgu olur (App Store IAP screenshot için uygun).
Kullanım: python resize_iap_screenshot.py <görsel_yolu> [çıktı_yolu]
"""
import sys
from pathlib import Path

def resize_to_1024(path_in: str, path_out: str | None = None) -> Path:
    try:
        from PIL import Image
    except ImportError:
        print("Pillow gerekli. Kurulum: pip install Pillow")
        sys.exit(1)

    path_in = Path(path_in)
    if not path_in.exists():
        print(f"Dosya bulunamadı: {path_in}")
        sys.exit(1)

    if path_out is None:
        path_out = path_in.parent / f"{path_in.stem}_1024x1024.png"
    else:
        path_out = Path(path_out)

    img = Image.open(path_in)
    # RGBA ise saydamlığı beyaz arka plana çevir
    if img.mode == "RGBA":
        bg = Image.new("RGBA", img.size, (255, 255, 255, 255))
        bg.paste(img, mask=img.split()[3])
        img = bg.convert("RGB")
    elif img.mode != "RGB":
        img = img.convert("RGB")

    w, h = img.size
    scale = min(1024 / w, 1024 / h)
    new_w = int(w * scale)
    new_h = int(h * scale)
    img_resized = img.resize((new_w, new_h), Image.Resampling.LANCZOS)

    out = Image.new("RGB", (1024, 1024), (255, 255, 255))
    paste_x = (1024 - new_w) // 2
    paste_y = (1024 - new_h) // 2
    out.paste(img_resized, (paste_x, paste_y))

    # Apple Image (promotional): 1024x1024, 72 dpi, RGB, flattened
    out.info["dpi"] = (72.0, 72.0)
    out.save(path_out, "PNG", optimize=True)
    print(f"Kaydedildi: {path_out} (1024 x 1024, 72 dpi, RGB)")
    return path_out


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Kullanım: python resize_iap_screenshot.py <görsel_yolu> [çıktı_yolu]")
        print("Örnek:   python resize_iap_screenshot.py ../assets/images/paywall_ss.png")
        sys.exit(1)
    resize_to_1024(sys.argv[1], sys.argv[2] if len(sys.argv) > 2 else None)
