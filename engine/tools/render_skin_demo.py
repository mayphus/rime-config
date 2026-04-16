#!/usr/bin/env python3

from __future__ import annotations

import argparse
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


WIDTH = 996
HEIGHT = 770
BACKGROUND = "#F6F2EA"
TEXT = "#1B1A17"
ACCENT = "#D9CCB7"
SUBTLE = "#EFE6D8"
FONT_CANDIDATES = [
    "/System/Library/Fonts/Hiragino Sans GB.ttc",
    "/System/Library/Fonts/STHeiti Medium.ttc",
    "/System/Library/Fonts/PingFang.ttc",
    "/Library/Fonts/Arial Unicode.ttf",
]


def pick_font(size: int) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    for candidate in FONT_CANDIDATES:
        path = Path(candidate)
        if path.exists():
            try:
                return ImageFont.truetype(str(path), size=size)
            except OSError:
                continue
    return ImageFont.load_default()


def main() -> None:
    parser = argparse.ArgumentParser(description="Render a generated Yuanshu skin demo image.")
    parser.add_argument("--title", required=True, help="Chinese skin title to center in the image.")
    parser.add_argument("--output", required=True, help="PNG output path.")
    args = parser.parse_args()

    image = Image.new("RGB", (WIDTH, HEIGHT), BACKGROUND)
    draw = ImageDraw.Draw(image)

    draw.rounded_rectangle((48, 48, WIDTH - 48, HEIGHT - 48), radius=36, fill=SUBTLE, outline=ACCENT, width=4)
    draw.rounded_rectangle((86, 86, WIDTH - 86, HEIGHT - 86), radius=28, outline=ACCENT, width=2)

    font = pick_font(116)
    text = args.title
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    x = (WIDTH - text_width) / 2
    y = (HEIGHT - text_height) / 2 - 18

    draw.text((x, y), text, font=font, fill=TEXT)

    output = Path(args.output)
    output.parent.mkdir(parents=True, exist_ok=True)
    image.save(output, format="PNG")


if __name__ == "__main__":
    main()
