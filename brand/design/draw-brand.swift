// Draws the Rick Burn Remote Support icon and a see-through logo for the connector.
// swift Design/draw-brand.swift <logo.png> <out-folder>
import AppKit
let args = CommandLine.arguments
let outDir = URL(fileURLWithPath: args[2])
func save(_ rep: NSBitmapImageRep, _ name: String) {
    try! rep.representation(using: .png, properties: [:])!.write(to: outDir.appendingPathComponent(name))
}
func canvas(_ w: Int, _ h: Int) -> NSBitmapImageRep {
    NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: w, pixelsHigh: h, bitsPerSample: 8, samplesPerPixel: 4,
                     hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
}
let night = NSColor(srgbRed: 0x04/255, green: 0x07/255, blue: 0x0D/255, alpha: 1)
let electric = NSColor(srgbRed: 0x2F/255, green: 0x9B/255, blue: 0xFF/255, alpha: 1)
let light = NSColor(srgbRed: 0x7C/255, green: 0xC6/255, blue: 0xFF/255, alpha: 1)

// Icon: night tile, glowing blue crescent and a white swoosh (as in the logo), "RB" below.
let S = 1024
let icon = canvas(S, S)
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: icon)
let tile = NSBezierPath(roundedRect: NSRect(x: 40, y: 40, width: 944, height: 944), xRadius: 200, yRadius: 200)
night.setFill(); tile.fill()
NSGradient(colors: [NSColor(srgbRed: 0.10, green: 0.20, blue: 0.40, alpha: 0.9), night])!
    .draw(in: tile, relativeCenterPosition: NSPoint(x: 0, y: 0.5))
// crescent = big ellipse minus a shifted ellipse
let outer = NSBezierPath(ovalIn: NSRect(x: 130, y: 440, width: 760, height: 430))
let cut = NSBezierPath(rect: NSRect(x: 0, y: 0, width: S, height: S))
cut.append(NSBezierPath(ovalIn: NSRect(x: 210, y: 330, width: 820, height: 470)))
cut.windingRule = .evenOdd
NSGraphicsContext.saveGraphicsState(); cut.addClip()
let sh = NSShadow(); sh.shadowColor = electric; sh.shadowBlurRadius = 60; sh.shadowOffset = .zero; sh.set()
electric.setFill(); outer.fill()
NSGradient(colors: [light, electric, NSColor(srgbRed: 0.05, green: 0.35, blue: 0.85, alpha: 1)])!.draw(in: outer, angle: -20)
NSGraphicsContext.restoreGraphicsState()
// white swoosh
let sw = NSBezierPath(); sw.move(to: NSPoint(x: 170, y: 520)); sw.curve(to: NSPoint(x: 880, y: 760), controlPoint1: NSPoint(x: 300, y: 300), controlPoint2: NSPoint(x: 700, y: 420))
sw.lineWidth = 16; sw.lineCapStyle = .round; NSColor.white.setStroke(); sw.stroke()
NSShadow().set()
let para = NSMutableParagraphStyle(); para.alignment = .center
let rb = NSAttributedString(string: "RB", attributes: [.font: NSFont.systemFont(ofSize: 300, weight: .heavy), .foregroundColor: NSColor.white, .paragraphStyle: para])
rb.draw(in: NSRect(x: 0, y: 90, width: S, height: 360))
NSGraphicsContext.restoreGraphicsState()
save(icon, "icon-1024.png")

// Logo: the email-signature logo with its dark background made see-through.
let src = NSBitmapImageRep(data: try! Data(contentsOf: URL(fileURLWithPath: args[1])))!
let w = src.pixelsWide, h = src.pixelsHigh
let out = canvas(w, h)
for y in 0..<h { for x in 0..<w {
    let c = src.colorAt(x: x, y: y)!.usingColorSpace(.deviceRGB)!
    let r = c.redComponent - 0x04/255.0, g = c.greenComponent - 0x07/255.0, b = c.blueComponent - 0x0D/255.0
    let a = min(1, max(0, max(r, g, b) * 1.15))          // how far from the night background
    if a < 0.02 { out.setColor(NSColor(deviceRed: 0, green: 0, blue: 0, alpha: 0), atX: x, y: y); continue }
    out.setColor(NSColor(deviceRed: min(1, max(0, r / a + 0x04/255.0)), green: min(1, max(0, g / a + 0x07/255.0)),
                         blue: min(1, max(0, b / a + 0x0D/255.0)), alpha: a), atX: x, y: y)
}}
save(out, "logo.png")
