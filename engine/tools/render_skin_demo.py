#!/usr/bin/env python3

from __future__ import annotations

import argparse
import re
import xml.etree.ElementTree as ET
from pathlib import Path

from PIL import Image, ImageColor, ImageDraw, ImageFont


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


def local_name(tag: str) -> str:
    return tag.rsplit("}", 1)[-1]


def parse_float(value: str | None, default: float = 0) -> float:
    if value is None:
        return default
    try:
        return float(value)
    except ValueError:
        return default


def parse_color(value: str | None, default: str = "#000000", opacity: float = 1) -> tuple[int, int, int, int]:
    if not value or value == "none":
        value = default
    try:
        color = ImageColor.getcolor(value, "RGBA")
    except ValueError:
        color = ImageColor.getcolor(default, "RGBA")
    alpha = round(color[3] * opacity)
    return (color[0], color[1], color[2], alpha)


def pick_font(size: float, weight: str | None = None) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    candidates = BOLD_FONT_CANDIDATES if (weight or "").lower() in {"700", "bold", "medium", "semibold"} else REGULAR_FONT_CANDIDATES
    for candidate in candidates:
        path = Path(candidate)
        if path.exists():
            try:
                return ImageFont.truetype(str(path), size=max(1, int(round(size))))
            except OSError:
                continue
    return ImageFont.load_default()


def text_box(draw: ImageDraw.ImageDraw, text: str, font: ImageFont.ImageFont) -> tuple[float, float]:
    bbox = draw.textbbox((0, 0), text, font=font)
    return bbox[2] - bbox[0], bbox[3] - bbox[1]


def parse_transform(transform: str | None) -> tuple[float, float, float]:
    tx = 0.0
    ty = 0.0
    scale = 1.0
    if not transform:
        return tx, ty, scale
    translate = re.search(r"translate\(([-0-9.]+)(?:[ ,]+([-0-9.]+))?\)", transform)
    if translate:
        tx = float(translate.group(1))
        ty = float(translate.group(2) or 0)
    scale_match = re.search(r"scale\(([-0-9.]+)\)", transform)
    if scale_match:
        scale = float(scale_match.group(1))
    return tx, ty, scale


def compose_transform(parent: tuple[float, float, float], child: tuple[float, float, float]) -> tuple[float, float, float]:
    ptx, pty, ps = parent
    ctx, cty, cs = child
    return ptx + ctx * ps, pty + cty * ps, ps * cs


def point(transform: tuple[float, float, float], x: float, y: float) -> tuple[float, float]:
    tx, ty, scale = transform
    return tx + x * scale, ty + y * scale


def render_rect(draw: ImageDraw.ImageDraw, element: ET.Element, transform: tuple[float, float, float]) -> None:
    tx, ty, scale = transform
    x = parse_float(element.get("x"))
    y = parse_float(element.get("y"))
    width = parse_float(element.get("width"))
    height = parse_float(element.get("height"))
    if element.get("width") == "100%":
        width = parse_float(element.get("_root_width"))
    if element.get("height") == "100%":
        height = parse_float(element.get("_root_height"))
    rx = parse_float(element.get("rx")) * scale
    left, top = point(transform, x, y)
    right, bottom = point(transform, x + width, y + height)
    fill = element.get("fill")
    if fill and fill != "none":
        draw.rounded_rectangle((left, top, right, bottom), radius=rx, fill=parse_color(fill, opacity=parse_float(element.get("fill-opacity"), 1)))
    stroke = element.get("stroke")
    if stroke and stroke != "none":
        stroke_width = max(1, round(parse_float(element.get("stroke-width"), 1) * scale))
        draw.rounded_rectangle((left, top, right, bottom), radius=rx, outline=parse_color(stroke), width=stroke_width)


def render_text(draw: ImageDraw.ImageDraw, element: ET.Element, transform: tuple[float, float, float]) -> None:
    tx, ty, scale = transform
    text = "".join(element.itertext())
    if not text:
        return
    x, y = point(transform, parse_float(element.get("x")), parse_float(element.get("y")))
    font_size = parse_float(element.get("font-size"), 14) * scale
    font = pick_font(font_size, element.get("font-weight"))
    width, height = text_box(draw, text, font)
    anchor = element.get("text-anchor")
    baseline = element.get("dominant-baseline")
    if anchor == "middle":
        x -= width / 2
    if baseline == "central":
        y -= height / 2
    draw.text((x, y), text, font=font, fill=parse_color(element.get("fill"), "#111111", parse_float(element.get("fill-opacity"), 1)))


def render_path(draw: ImageDraw.ImageDraw, element: ET.Element, transform: tuple[float, float, float]) -> None:
    tokens = re.findall(r"[MLHVZmlhvz]|[-0-9.]+", element.get("d", ""))
    segments: list[list[tuple[float, float]]] = []
    segment: list[tuple[float, float]] = []
    current = (0.0, 0.0)
    start = (0.0, 0.0)
    command = ""
    index = 0
    while index < len(tokens):
        token = tokens[index]
        if re.fullmatch(r"[MLHVZmlhvz]", token):
            command = token.upper()
            index += 1
            if command == "Z" and segment:
                segment.append(point(transform, *start))
            continue
        if command in {"M", "L"} and index + 1 < len(tokens):
            current = (float(tokens[index]), float(tokens[index + 1]))
            if command == "M":
                if segment:
                    segments.append(segment)
                segment = [point(transform, *current)]
                start = current
                command = "L"
            else:
                segment.append(point(transform, *current))
            index += 2
        elif command == "H":
            current = (float(tokens[index]), current[1])
            segment.append(point(transform, *current))
            index += 1
        elif command == "V":
            current = (current[0], float(tokens[index]))
            segment.append(point(transform, *current))
            index += 1
        else:
            index += 1
    if segment:
        segments.append(segment)
    stroke_width = max(1, round(parse_float(element.get("stroke-width"), 1) * transform[2]))
    for segment in segments:
        if len(segment) >= 2:
            draw.line(segment, fill=parse_color(element.get("stroke"), "#111111"), width=stroke_width, joint="curve")


def render_element(draw: ImageDraw.ImageDraw, element: ET.Element, transform: tuple[float, float, float], root_size: tuple[int, int]) -> None:
    child_transform = compose_transform(transform, parse_transform(element.get("transform")))
    tag = local_name(element.tag)
    if tag == "rect":
        element.set("_root_width", str(root_size[0]))
        element.set("_root_height", str(root_size[1]))
        render_rect(draw, element, child_transform)
    elif tag == "text":
        render_text(draw, element, child_transform)
    elif tag == "path":
        render_path(draw, element, child_transform)

    for child in element:
        render_element(draw, child, child_transform, root_size)


def render_svg(svg_path: Path, output: Path) -> None:
    root = ET.parse(svg_path).getroot()
    width = int(round(parse_float(root.get("width"), 996)))
    height = int(round(parse_float(root.get("height"), 660)))
    image = Image.new("RGBA", (width, height), (255, 255, 255, 0))
    draw = ImageDraw.Draw(image)
    render_element(draw, root, (0, 0, 1), (width, height))
    output.parent.mkdir(parents=True, exist_ok=True)
    image.convert("RGB").save(output, format="PNG")


def main() -> None:
    parser = argparse.ArgumentParser(description="Rasterize a generated Yuanshu skin demo SVG.")
    parser.add_argument("--svg", required=True, help="Generated demo SVG path.")
    parser.add_argument("--output", required=True, help="PNG output path.")
    args = parser.parse_args()
    render_svg(Path(args.svg), Path(args.output))


if __name__ == "__main__":
    main()
