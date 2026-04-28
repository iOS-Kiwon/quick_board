import os
import zipfile
import cairosvg
from text_to_paths import replace_text_with_paths

BASE = os.path.dirname(os.path.abspath(__file__))
SVG_DIR = os.path.join(BASE, "svg")
OUT_DIR = os.path.join(BASE, "export")
FONT_BOLD = os.path.join(
    BASE, "../quick-board-flutter/apps/skulking/assets/fonts/NotoSansKR-Bold.otf"
)

# iOS App Icon sizes (pt × scale)
IOS_SIZES = [20, 29, 40, 58, 60, 76, 80, 87, 120, 152, 167, 180, 1024]

# Android sizes
ANDROID_SIZES = {
    "mdpi":    48,
    "hdpi":    72,
    "xhdpi":   96,
    "xxhdpi":  144,
    "xxxhdpi": 192,
}

PLAY_STORE_SIZE = 512
ICONS = ["skulking_ko", "skulking_en", "yacht_ko", "yacht_en"]


def load_svg(icon: str) -> str:
    path = os.path.join(SVG_DIR, f"{icon}.svg")
    with open(path, encoding="utf-8") as f:
        content = f.read()
    # 한글 아이콘은 text → path 변환
    if icon.endswith("_ko"):
        content = replace_text_with_paths(content, FONT_BOLD)
    return content


def export(svg_content: str, out_path: str, size: int):
    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    cairosvg.svg2png(
        bytestring=svg_content.encode("utf-8"),
        write_to=out_path,
        output_width=size,
        output_height=size,
    )


for icon in ICONS:
    svg_content = load_svg(icon)
    print(f"\n▶ {icon}")

    # iOS
    ios_dir = os.path.join(OUT_DIR, icon, "ios")
    for size in IOS_SIZES:
        out = os.path.join(ios_dir, f"icon_{size}x{size}.png")
        export(svg_content, out, size)
        print(f"  iOS {size}x{size}")

    # Android
    android_dir = os.path.join(OUT_DIR, icon, "android")
    for density, size in ANDROID_SIZES.items():
        out = os.path.join(android_dir, density, "ic_launcher.png")
        export(svg_content, out, size)
        print(f"  Android {density} ({size}x{size})")

    # Play Store
    out = os.path.join(OUT_DIR, icon, "playstore_512x512.png")
    export(svg_content, out, PLAY_STORE_SIZE)
    print(f"  Play Store 512x512")

    # Master 1024
    out = os.path.join(OUT_DIR, icon, "master_1024x1024.png")
    export(svg_content, out, 1024)
    print(f"  Master 1024x1024")

# Zip
zip_path = os.path.join(BASE, "app_icons.zip")
with zipfile.ZipFile(zip_path, "w", zipfile.ZIP_DEFLATED) as zf:
    for root, _, files in os.walk(OUT_DIR):
        for file in files:
            full = os.path.join(root, file)
            arcname = os.path.relpath(full, OUT_DIR)
            zf.write(full, arcname)
    for icon in ICONS:
        svg_src = os.path.join(SVG_DIR, f"{icon}.svg")
        zf.write(svg_src, os.path.join("svg_source", f"{icon}.svg"))

print(f"\n✅ Done! → {zip_path} ({os.path.getsize(zip_path)//1024} KB)")
