#!/usr/bin/env swift

import AppKit
import Foundation

struct Layer: Decodable {
    let text: String
    let x: Double
    let y: Double
    let font_size: Double
    let font_weight: String?
    let color: String

    private enum CodingKeys: String, CodingKey {
        case text, x, y, color
        case font_size = "font-size"
        case font_weight = "font-weight"
    }
}

struct KeySpec: Decodable {
    let id: String
    let kind: String
    let label: String
    let icon: String
    let width: Double
    let align: String
    let background: String
    let highlightBackground: String?
    let layers: [Layer]

    private enum CodingKeys: String, CodingKey {
        case id, kind, label, icon, width, align, background, layers
        case highlightBackground = "highlight-background"
    }
}

struct PreviewSpec: Decodable {
    let background: String
    let rows: [[KeySpec]]
}

struct Payload: Decodable {
    let title: String
    let preview: PreviewSpec
}

func color(from hex: String, alpha: CGFloat = 1.0) -> NSColor {
    let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
    var value: UInt64 = 0
    Scanner(string: cleaned).scanHexInt64(&value)
    let r, g, b, a: UInt64
    switch cleaned.count {
    case 8:
        r = (value >> 24) & 0xff
        g = (value >> 16) & 0xff
        b = (value >> 8) & 0xff
        a = value & 0xff
    case 6:
        r = (value >> 16) & 0xff
        g = (value >> 8) & 0xff
        b = value & 0xff
        a = 255
    default:
        return NSColor(calibratedWhite: 0.85, alpha: alpha)
    }
    return NSColor(calibratedRed: CGFloat(r) / 255.0,
                   green: CGFloat(g) / 255.0,
                   blue: CGFloat(b) / 255.0,
                   alpha: (CGFloat(a) / 255.0) * alpha)
}

func font(weight: String?, size: CGFloat) -> NSFont {
    let lower = (weight ?? "").lowercased()
    if lower == "bold" {
        return NSFont.boldSystemFont(ofSize: size)
    }
    if lower == "medium", let f = NSFont.systemFont(ofSize: size, weight: .medium) as NSFont? {
        return f
    }
    return NSFont.systemFont(ofSize: size)
}

func specialLabel(for key: KeySpec) -> String {
    if !key.label.isEmpty { return key.label }
    switch key.kind {
    case "shift": return "⇧"
    case "backspace": return "⌫"
    case "enter": return "↵"
    case "space": return "space"
    case "numeric": return "123"
    default: return key.icon
    }
}

func drawRoundedRect(_ rect: NSRect, radius: CGFloat, fill: NSColor, stroke: NSColor? = nil, lineWidth: CGFloat = 1) {
    let path = NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)
    fill.setFill()
    path.fill()
    if let stroke {
        stroke.setStroke()
        path.lineWidth = lineWidth
        path.stroke()
    }
}

let args = CommandLine.arguments
guard let payloadIndex = args.firstIndex(of: "--payload"),
      payloadIndex + 1 < args.count,
      let outputIndex = args.firstIndex(of: "--output"),
      outputIndex + 1 < args.count else {
    fputs("Usage: render_skin_demo.swift --payload payload.json --output demo.png\n", stderr)
    exit(2)
}

let payloadURL = URL(fileURLWithPath: args[payloadIndex + 1])
let outputURL = URL(fileURLWithPath: args[outputIndex + 1])

let payloadData = try Data(contentsOf: payloadURL)
let payload = try JSONDecoder().decode(Payload.self, from: payloadData)

let width: CGFloat = 996
let height: CGFloat = 770
let outerRect = NSRect(x: 40, y: 40, width: width - 80, height: height - 80)
let keyboardRect = NSRect(x: 84, y: 104, width: width - 168, height: 386)
let titleRect = NSRect(x: 84, y: 540, width: width - 168, height: 120)

guard let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil,
                                    pixelsWide: Int(width),
                                    pixelsHigh: Int(height),
                                    bitsPerSample: 8,
                                    samplesPerPixel: 4,
                                    hasAlpha: true,
                                    isPlanar: false,
                                    colorSpaceName: .deviceRGB,
                                    bytesPerRow: 0,
                                    bitsPerPixel: 0) else {
    fputs("Failed to create bitmap context\n", stderr)
    exit(1)
}

bitmap.size = NSSize(width: width, height: height)
NSGraphicsContext.saveGraphicsState()
guard let context = NSGraphicsContext(bitmapImageRep: bitmap) else {
    fputs("Failed to create graphics context\n", stderr)
    exit(1)
}
NSGraphicsContext.current = context

color(from: "#F4E9D8").setFill()
NSBezierPath(rect: NSRect(x: 0, y: 0, width: width, height: height)).fill()

drawRoundedRect(outerRect, radius: 38, fill: color(from: "#FFF7EB"), stroke: color(from: "#D7B98F"), lineWidth: 3)
drawRoundedRect(keyboardRect, radius: 28, fill: color(from: payload.preview.background, alpha: 1.0), stroke: color(from: "#E2CEAE"), lineWidth: 1.5)

let titleStyle = NSMutableParagraphStyle()
titleStyle.alignment = .center
let titleAttributes: [NSAttributedString.Key: Any] = [
    .font: NSFont.systemFont(ofSize: 56, weight: .bold),
    .foregroundColor: color(from: "#201714"),
    .paragraphStyle: titleStyle
]
payload.title.draw(in: titleRect, withAttributes: titleAttributes)

let rowGap: CGFloat = 14
let keyGap: CGFloat = 8
let rowCount = max(payload.preview.rows.count, 1)
let keyHeight = (keyboardRect.height - CGFloat(rowCount + 1) * rowGap) / CGFloat(rowCount)

for (rowIndex, row) in payload.preview.rows.enumerated() {
    let y = keyboardRect.maxY - rowGap - CGFloat(rowIndex + 1) * keyHeight - CGFloat(rowIndex) * rowGap
    let totalUnits = max(row.reduce(0.0) { $0 + $1.width }, 1.0)
    let availableWidth = keyboardRect.width - CGFloat(max(row.count - 1, 0)) * keyGap - 24
    var x = keyboardRect.minX + 12

    for key in row {
        let keyWidth = max(CGFloat(key.width / totalUnits) * availableWidth, 48)
        let rect = NSRect(x: x, y: y, width: keyWidth, height: keyHeight)
        let fill = color(from: key.background)
        let stroke = key.kind == "space" ? color(from: "#D9C4A2") : color(from: "#D7C1A0")
        drawRoundedRect(rect, radius: 16, fill: fill, stroke: stroke, lineWidth: 1)

        if !key.layers.isEmpty {
            for (layerIndex, layer) in key.layers.enumerated() {
                if layer.text.isEmpty { continue }
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: font(weight: layer.font_weight, size: CGFloat(layer.font_size) * 1.12),
                    .foregroundColor: color(from: layer.color),
                ]
                let text = NSString(string: layer.text)
                let size = text.size(withAttributes: attributes)
                let textX = rect.minX + CGFloat(layer.x) * rect.width - size.width / 2
                let textY = rect.minY + (1 - CGFloat(layer.y)) * rect.height - size.height / 2
                text.draw(at: NSPoint(x: textX, y: textY), withAttributes: attributes)
                if layerIndex == 0 { continue }
            }
        } else {
            let fallback = specialLabel(for: key)
            let attributes: [NSAttributedString.Key: Any] = [
                .font: NSFont.systemFont(ofSize: key.kind == "space" ? 18 : 22, weight: .semibold),
                .foregroundColor: color(from: "#2A211C"),
            ]
            let text = NSString(string: fallback)
            let size = text.size(withAttributes: attributes)
            let textX = rect.midX - size.width / 2
            let textY = rect.midY - size.height / 2
            text.draw(at: NSPoint(x: textX, y: textY), withAttributes: attributes)
        }

        x += keyWidth + keyGap
    }
}

NSGraphicsContext.restoreGraphicsState()

guard let png = bitmap.representation(using: .png, properties: [:]) else {
    fputs("Failed to encode PNG\n", stderr)
    exit(1)
}

try FileManager.default.createDirectory(at: outputURL.deletingLastPathComponent(), withIntermediateDirectories: true)
try png.write(to: outputURL)
