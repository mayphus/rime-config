#!/usr/bin/env python3

from __future__ import annotations

import argparse
import json
from pathlib import Path

from PIL import Image, ImageColor, ImageDraw, ImageFont


WIDTH = 996
HEIGHT = 660
BACKGROUND = "#F6F7FA"
PHONE_FILL = "#ECEEF4"
KEYBOARD_STROKE = "#D7D9E1"
TEXT = "#202124"
FALLBACK_TEXT = "#2A211C"
ROW_GAP = 18
KEY_GAP = 10

PHONE_RECT = (42, 36, WIDTH - 42, HEIGHT - 36)
KEYBOARD_RECT = (68, 120, WIDTH - 68, HEIGHT - 58)
TITLE_RECT = (68, 52, WIDTH - 68, 104)

REGULAR_FONT_CANDIDATES = [
    "/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc",
    "/usr/share/fonts/opentype/noto/NotoSerifCJK-Regular.ttc",
    "/System/Library/Fonts/Hiragino Sans GB.ttc",
    "/System/Library/Fonts/PingFang.ttc",
    "/Library/Fonts/Arial Unicode.ttf",
]

BOLD_FONT_CANDIDATES = [
    "/usr/share/fonts/opentype/noto/NotoSansCJK-Bold.ttc",
    "/usr/share/fonts/opentype/noto/NotoSerifCJK-Bold.ttc",
    "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
    "/System/Library/Fonts/Hiragino Sans GB.ttc",
    "/System/Library/Fonts/PingFang.ttc",
    "/Library/Fonts/Arial Unicode.ttf",
]

SYMBOL_FONT_CANDIDATES = [
    "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
    "/Library/Fonts/Arial Unicode.ttf",
    "/System/Library/Fonts/Apple Symbols.ttf",
]


def pick_font(size: int | float, weight: str | None = None) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    candidates = BOLD_FONT_CANDIDATES if (weight or "").lower() in {"bold", "medium", "semibold"} else REGULAR_FONT_CANDIDATES
    for candidate in candidates:
        path = Path(candidate)
        if path.exists():
            try:
                return ImageFont.truetype(str(path), size=int(round(size)))
            except OSError:
                continue
    return ImageFont.load_default()


def pick_symbol_font(size: int | float) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    for candidate in SYMBOL_FONT_CANDIDATES:
        path = Path(candidate)
        if path.exists():
            try:
                return ImageFont.truetype(str(path), size=int(round(size)))
            except OSError:
                continue
    return pick_font(size, "semibold")


def hex_color(value: str, default: str, base: tuple[int, int, int] | None = None) -> tuple[int, int, int]:
    try:
        color = ImageColor.getcolor(value, "RGBA")
    except ValueError:
        color = ImageColor.getcolor(default, "RGBA")
    rgb = color[:3]
    alpha = color[3] / 255
    if alpha >= 1 or base is None:
        return rgb
    return tuple(round(channel * alpha + base_channel * (1 - alpha)) for channel, base_channel in zip(rgb, base))


def text_box(draw: ImageDraw.ImageDraw, text: str, font: ImageFont.ImageFont) -> tuple[float, float]:
    bbox = draw.textbbox((0, 0), text, font=font)
    return bbox[2] - bbox[0], bbox[3] - bbox[1]


def draw_centered_text(draw: ImageDraw.ImageDraw,
                       rect: tuple[float, float, float, float],
                       text: str,
                       font: ImageFont.ImageFont,
                       fill: tuple[int, int, int]) -> None:
    width, height = text_box(draw, text, font)
    left, top, right, bottom = rect
    x = left + (right - left - width) / 2
    y = top + (bottom - top - height) / 2
    draw.text((x, y), text, font=font, fill=fill)


def draw_title(draw: ImageDraw.ImageDraw, title: str) -> None:
    font = pick_font(38, "bold")
    draw_centered_text(draw, TITLE_RECT, title, font, hex_color(TEXT, TEXT))


def special_label(key: dict) -> str:
    label = key.get("label") or ""
    if label:
        return label
    kind = key.get("kind", "")
    if kind == "shift":
        return "⇧"
    if kind == "backspace":
        return "⌫"
    if kind == "enter":
        return "↵"
    if kind == "space":
        return "␣"
    if kind == "numeric":
        return "123"
    return key.get("icon", "")


def draw_key(draw: ImageDraw.ImageDraw,
             rect: tuple[float, float, float, float],
             key: dict,
             keyboard_background: tuple[int, int, int]) -> None:
    background = hex_color(key.get("background", "#FFFFFF"), "#FFFFFF", keyboard_background)
    shadow_rect = (rect[0], rect[1] + 2, rect[2], rect[3] + 2)
    draw.rounded_rectangle(shadow_rect, radius=18, fill=(210, 213, 222))
    draw.rounded_rectangle(rect, radius=18, fill=background, outline=(206, 209, 218), width=1)

    layers = key.get("layers") or []
    if layers:
        left, top, right, bottom = rect
        width = right - left
        height = bottom - top
        for layer in layers:
            text = layer.get("text") or ""
            if not text:
                continue
            font = pick_font(float(layer.get("font-size", 14)) * 2.05, layer.get("font-weight"))
            text_width, text_height = text_box(draw, text, font)
            x = left + float(layer.get("x", 0.5)) * width - text_width / 2
            y = top + float(layer.get("y", 0.5)) * height - text_height / 2
            draw.text((x, y), text, font=font, fill=hex_color(layer.get("color", "#000000"), "#000000", background))
        return

    fallback = special_label(key)
    if not fallback:
        return
    if key.get("kind") == "space":
        left, top, right, bottom = rect
        width = right - left
        height = bottom - top
        icon_width = min(width * 0.18, 58)
        icon_height = min(height * 0.28, 24)
        x1 = left + (width - icon_width) / 2
        x2 = x1 + icon_width
        y1 = top + (height - icon_height) / 2
        y2 = y1 + icon_height
        fill = hex_color("#000000", "#000000", background)
        draw.line([(x1, y1), (x1, y2), (x2, y2), (x2, y1)], fill=fill, width=4)
        return
    font_size = 30 if key.get("kind") == "space" else 34
    font = pick_symbol_font(font_size) if key.get("kind") in {"backspace", "enter", "shift"} else pick_font(font_size, "semibold")
    fill = hex_color("#000000", "#000000", background)
    draw_centered_text(draw, rect, fallback, font, fill)


def draw_keyboard(draw: ImageDraw.ImageDraw, preview: dict) -> None:
    keyboard_background = hex_color(preview.get("background", "#F2F3F7"), "#F2F3F7", hex_color(PHONE_FILL, PHONE_FILL))
    draw.rounded_rectangle(KEYBOARD_RECT, radius=34, fill=keyboard_background, outline=hex_color(KEYBOARD_STROKE, KEYBOARD_STROKE), width=1)

    rows = preview.get("rows") or []
    row_count = max(len(rows), 1)
    key_height = ((KEYBOARD_RECT[3] - KEYBOARD_RECT[1]) - (row_count + 1) * ROW_GAP) / row_count

    for row_index, row in enumerate(rows):
        y = KEYBOARD_RECT[1] + ROW_GAP + row_index * (key_height + ROW_GAP)
        total_units = max(sum(float(key.get("width", 1)) for key in row), 1.0)
        available_width = (KEYBOARD_RECT[2] - KEYBOARD_RECT[0]) - max(len(row) - 1, 0) * KEY_GAP - 28
        x = KEYBOARD_RECT[0] + 14

        for key in row:
            key_width = max(float(key.get("width", 1)) / total_units * available_width, 48)
            rect = (x, y, x + key_width, y + key_height)
            draw_key(draw, rect, key, keyboard_background)
            x += key_width + KEY_GAP


def render_from_payload(payload: dict, output: Path) -> None:
    image = Image.new("RGB", (WIDTH, HEIGHT), hex_color(BACKGROUND, BACKGROUND))
    draw = ImageDraw.Draw(image)

    preview = payload.get("preview", {})
    if isinstance(preview, dict) and "dark" in preview:
        preview = {key: value for key, value in preview.items() if key != "dark"}

    draw.rounded_rectangle(PHONE_RECT, radius=42, fill=hex_color(PHONE_FILL, PHONE_FILL), outline=hex_color(KEYBOARD_STROKE, KEYBOARD_STROKE), width=1)
    draw_title(draw, payload.get("title", ""))
    draw_keyboard(draw, preview)

    output.parent.mkdir(parents=True, exist_ok=True)
    image.save(output, format="PNG")


def render_from_title(title: str, output: Path) -> None:
    image = Image.new("RGB", (WIDTH, HEIGHT), hex_color("#F6F2EA", "#F6F2EA"))
    draw = ImageDraw.Draw(image)

    draw.rounded_rectangle((48, 48, WIDTH - 48, HEIGHT - 48), radius=36, fill=hex_color("#EFE6D8", "#EFE6D8"), outline=hex_color("#D9CCB7", "#D9CCB7"), width=4)
    draw.rounded_rectangle((86, 86, WIDTH - 86, HEIGHT - 86), radius=28, outline=hex_color("#D9CCB7", "#D9CCB7"), width=2)
    draw_title(draw, title)

    output.parent.mkdir(parents=True, exist_ok=True)
    image.save(output, format="PNG")


def main() -> None:
    parser = argparse.ArgumentParser(description="Render a generated Yuanshu skin demo image.")
    parser.add_argument("--payload", help="JSON payload path containing title and preview layout.")
    parser.add_argument("--title", help="Fallback title-only mode.")
    parser.add_argument("--output", required=True, help="PNG output path.")
    args = parser.parse_args()

    output = Path(args.output)
    if args.payload:
        render_from_payload(json.loads(Path(args.payload).read_text()), output)
    elif args.title:
        render_from_title(args.title, output)
    else:
        parser.error("one of --payload or --title is required")


if __name__ == "__main__":
    main()
