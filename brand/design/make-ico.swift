// Makes a Windows .ico from a big PNG, the classic way Explorer reads everywhere:
// 16-128 px as 32-bit bitmaps (with an AND mask), 256 px as PNG.
// swift make-ico.swift <icon-1024.png> <out.ico>
import AppKit
let src = NSImage(contentsOfFile: CommandLine.arguments[1])!
func rep(_ s: Int) -> NSBitmapImageRep {
    let r = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: s, pixelsHigh: s, bitsPerSample: 8, samplesPerPixel: 4,
                             hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: s * 4, bitsPerPixel: 32)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: r)
    NSGraphicsContext.current?.imageInterpolation = .high
    src.draw(in: NSRect(x: 0, y: 0, width: s, height: s))
    NSGraphicsContext.restoreGraphicsState()
    return r
}
func le32(_ v: Int) -> [UInt8] { [UInt8(v & 255), UInt8((v >> 8) & 255), UInt8((v >> 16) & 255), UInt8((v >> 24) & 255)] }
func le16(_ v: Int) -> [UInt8] { [UInt8(v & 255), UInt8((v >> 8) & 255)] }
var images: [(Int, [UInt8])] = []
for s in [16, 24, 32, 48, 64, 128] {
    let r = rep(s)
    var d: [UInt8] = []
    d += le32(40) + le32(s) + le32(s * 2) + le16(1) + le16(32) + le32(0) + le32(s * s * 4) + le32(0) + le32(0) + le32(0) + le32(0)
    let p = r.bitmapData!
    for y in (0..<s).reversed() { for x in 0..<s {          // bottom-up rows, BGRA, unpremultiplied
        let i = (y * s + x) * 4
        let a = Int(p[i + 3])
        func un(_ c: UInt8) -> UInt8 { a == 0 ? 0 : UInt8(min(255, Int(c) * 255 / a)) }
        d += [un(p[i + 2]), un(p[i + 1]), un(p[i]), UInt8(a)]
    }}
    let maskRow = ((s + 31) / 32) * 4
    d += [UInt8](repeating: 0, count: maskRow * s)
    images.append((s, d))
}
images.append((256, [UInt8](rep(256).representation(using: .png, properties: [:])!)))
var out: [UInt8] = le16(0) + le16(1) + le16(images.count)
var offset = 6 + 16 * images.count
for (s, d) in images {
    out += [UInt8(s % 256), UInt8(s % 256), 0, 0] + le16(1) + le16(32) + le32(d.count) + le32(offset)
    offset += d.count
}
for (_, d) in images { out += d }
try! Data(out).write(to: URL(fileURLWithPath: CommandLine.arguments[2]))
