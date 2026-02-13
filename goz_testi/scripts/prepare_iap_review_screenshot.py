#!/usr/bin/env python3
"""
App Review Screenshot'ı Apple gereksinimlerine uygun hale getirir:
- RGB, flattened (şeffaflık yok), 72 dpi
- İsteğe bağlı: tam cihaz boyutuna getirir (iPhone 14 Pro Max veya iPad 11")

Kullanım:
  python prepare_iap_review_screenshot.py ss.png                    # Sadece RGB/72dpi düzeltir
  python prepare_iap_review_screenshot.py ss.png iphone              # 1290x2796 (iPhone 14 Pro Max)
  python prepare_iap_review_screenshot.py ss.png ipad                # 1668x2388 (iPad Pro 11")
"""
import sys
from pathlib import Path

# Apple App Store kabul edilen cihaz boyutları (portrait)
SIZES = {
    "iphone": (1290, 2796),   # iPhone 14/15 Pro Max, 6.7"
    "ipad": (1668, 2388),     # iPad Pro 11" / iPad Air 11"
}

def prepare(path_in: str, device: str | None = None, path_out: str | None = None) -> Path:
    try:
        from PIL import Image
    except ImportError:
        print("Pillow gerekli: pip install Pillow")
        sys.exit(1)

    path_in = Path(path_in)
    if not path_in.exists():
        print(f"Dosya bulunamadı: {path_in}")
        sys.exit(1)

    out_name = f"{path_in.stem}_review_ready.png"
    if path_out is None:
        path_out = path_in.parent / out_name
    else:
        path_out = Path(path_out)

    img = Image.open(path_in)

    # RGB, flattened (şeffaflık kaldır)
    if img.mode == "RGBA":
        bg = Image.new("RGB", img.size, (255, 255, 255))
        bg.paste(img, mask=img.split()[3])
        img = bg
    elif img.mode != "RGB":
        img = img.convert("RGB")

    # İstenen cihaz boyutuna getir (oran korunur, taşan kesilir / letterbox yok)
    if device and device.lower() in SIZES:
        target_w, target_h = SIZES[device.lower()]
        w, h = img.size
        scale = max(target_w / w, target_h / h)  # Tam kaplasın
        new_w = int(round(w * scale))
        new_h = int(round(h * scale))
        img = img.resize((new_w, new_h), Image.Resampling.LANCZOS)
        # Ortadan crop
        left = (new_w - target_w) // 2
        top = (new_h - target_h) // 2
        img = img.crop((left, top, left + target_w, top + target_h))
        print(f"Hedef boyut: {target_w} x {target_h} ({device})")
    else:
        print("Boyut değiştirilmedi (device: iphone/ipad belirtilmedi)")

    # 72 dpi (Apple gereksinimi)
    img.info["dpi"] = (72.0, 72.0)
    img.save(path_out, "PNG", optimize=True)
    print(f"Kaydedildi: {path_out}")
    print(f"  → {img.size[0]} x {img.size[1]}, RGB, 72 dpi, flattened")
    return path_out


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)
    device = sys.argv[2].lower() if len(sys.argv) > 2 else None
    out = sys.argv[3] if len(sys.argv) > 3 else None
    prepare(sys.argv[1], device, out)
