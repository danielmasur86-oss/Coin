"""Draws the HausiHelfer app icon and writes all Android and iOS sizes.

Run from the hausihelfer/ folder:  python3 tools/make_icons.py
Needs Pillow (pip install pillow). Replace with a designer's icon later if you like.
"""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter

ROOT = Path(__file__).resolve().parent.parent
S = 1024
GREEN_TOP, GREEN_BOTTOM = (52, 160, 112), (30, 110, 78)
WHITE, PAGE_LINE, YELLOW = (255, 255, 255), (196, 222, 208), (255, 201, 60)


def draw_icon(size: int = S) -> Image.Image:
    img = Image.new("RGB", (S, S))
    d = ImageDraw.Draw(img)
    for y in range(S):  # vertical gradient background
        t = y / S
        d.line([(0, y), (S, y)], fill=tuple(int(a + (b - a) * t) for a, b in zip(GREEN_TOP, GREEN_BOTTOM)))

    # soft shadow under the book
    shadow = Image.new("L", (S, S), 0)
    ImageDraw.Draw(shadow).ellipse([210, 760, 814, 840], fill=90)
    img.paste((20, 80, 55), mask=shadow.filter(ImageFilter.GaussianBlur(24)))

    # open book: two pages meeting in the middle
    left = [(190, 360), (500, 410), (500, 790), (190, 740)]
    right = [(524, 410), (834, 360), (834, 740), (524, 790)]
    d.polygon(left, fill=WHITE)
    d.polygon(right, fill=WHITE)
    d.rectangle([500, 410, 524, 790], fill=PAGE_LINE)
    for i in range(5):  # text lines on the pages
        y = 470 + i * 52
        d.line([(240, y + 4 - i * 0), (455, y + 30)], fill=PAGE_LINE, width=14)
        d.line([(569, y + 30), (784, y + 4)], fill=PAGE_LINE, width=14)

    # light bulb above the book = "idea / explanation"
    cx, cy, r = 512, 230, 92
    d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=YELLOW)
    d.rounded_rectangle([cx - 44, cy + 70, cx + 44, cy + 128], radius=14, fill=(240, 240, 240))
    for angle_pts in [((cx - 150, cy), (cx - 118, cy)), ((cx + 118, cy), (cx + 150, cy)),
                      ((cx - 108, cy - 108), (cx - 86, cy - 86)), ((cx + 86, cy - 86), (cx + 108, cy - 108))]:
        d.line(angle_pts, fill=YELLOW, width=18)
    return img.resize((size, size), Image.LANCZOS)


def main() -> None:
    master = draw_icon()
    assets = ROOT / "store-assets"
    assets.mkdir(exist_ok=True)
    master.save(assets / "icon-1024.png")
    master.resize((512, 512), Image.LANCZOS).save(assets / "icon-512-google-play.png")

    # Android launcher icons
    res = ROOT / "app/android/app/src/main/res"
    for folder, px in {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192}.items():
        icon = master.resize((px, px), Image.LANCZOS)
        mask = Image.new("L", (px, px), 0)
        ImageDraw.Draw(mask).rounded_rectangle([0, 0, px - 1, px - 1], radius=px // 5, fill=255)
        rounded = Image.new("RGBA", (px, px))
        rounded.paste(icon, mask=mask)
        rounded.save(res / f"mipmap-{folder}/ic_launcher.png")

    # iOS: square, no transparency (Apple requirement); iOS rounds the corners itself
    ios = ROOT / "app/ios/Runner/Assets.xcassets/AppIcon.appiconset"
    for f in ios.glob("Icon-App-*.png"):
        dims = f.stem.split("-")[2]  # e.g. "83.5x83.5@2x"
        base, scale = dims.split("@")
        px = round(float(base.split("x")[0]) * int(scale.rstrip("x")))
        master.resize((px, px), Image.LANCZOS).save(f)
    print("icons written")


if __name__ == "__main__":
    main()
