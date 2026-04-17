from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageOps


ROOT = Path(__file__).resolve().parents[1]
SOURCE_SIZE = 1024


def create_source_icon() -> Image.Image:
    source_path = ROOT / "images" / "iconoaplicacionlacarta.png"
    source = Image.open(source_path).convert("RGBA")
    return ImageOps.fit(
        source,
        (SOURCE_SIZE, SOURCE_SIZE),
        Image.Resampling.LANCZOS,
    )


def export_sizes(source: Image.Image, targets: list[tuple[Path, int]]) -> None:
    for path, size in targets:
        path.parent.mkdir(parents=True, exist_ok=True)
        source.resize((size, size), Image.Resampling.LANCZOS).save(path)


def main() -> None:
    source = create_source_icon()

    source_path = ROOT / "assets" / "branding" / "la_carta_launcher.png"
    source_path.parent.mkdir(parents=True, exist_ok=True)
    source.save(source_path)

    android_targets = [
        (ROOT / "android/app/src/main/res/mipmap-mdpi/ic_launcher.png", 48),
        (ROOT / "android/app/src/main/res/mipmap-hdpi/ic_launcher.png", 72),
        (ROOT / "android/app/src/main/res/mipmap-xhdpi/ic_launcher.png", 96),
        (ROOT / "android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png", 144),
        (ROOT / "android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png", 192),
    ]

    web_targets = [
        (ROOT / "web/favicon.png", 32),
        (ROOT / "web/icons/Icon-192.png", 192),
        (ROOT / "web/icons/Icon-512.png", 512),
        (ROOT / "web/icons/Icon-maskable-192.png", 192),
        (ROOT / "web/icons/Icon-maskable-512.png", 512),
    ]

    ios_targets = [
        (ROOT / "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@1x.png", 20),
        (ROOT / "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@2x.png", 40),
        (ROOT / "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@3x.png", 60),
        (ROOT / "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@1x.png", 29),
        (ROOT / "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@2x.png", 58),
        (ROOT / "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@3x.png", 87),
        (ROOT / "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@1x.png", 40),
        (ROOT / "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@2x.png", 80),
        (ROOT / "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@3x.png", 120),
        (ROOT / "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@2x.png", 120),
        (ROOT / "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@3x.png", 180),
        (ROOT / "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@1x.png", 76),
        (ROOT / "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@2x.png", 152),
        (ROOT / "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-83.5x83.5@2x.png", 167),
        (ROOT / "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png", 1024),
    ]

    export_sizes(source, android_targets + web_targets + ios_targets)


if __name__ == "__main__":
    main()