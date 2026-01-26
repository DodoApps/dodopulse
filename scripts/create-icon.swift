#!/usr/bin/env swift

import Cocoa

// Create a simple app icon with a monitor/pulse design
func createIcon(size: Int) -> NSImage {
    let image = NSImage(size: NSSize(width: size, height: size))
    image.lockFocus()

    let rect = NSRect(x: 0, y: 0, width: size, height: size)
    let scale = CGFloat(size) / 512.0

    // Background gradient (dark blue to purple)
    let gradient = NSGradient(colors: [
        NSColor(red: 0.15, green: 0.15, blue: 0.25, alpha: 1.0),
        NSColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 1.0)
    ])!

    // Rounded rectangle background
    let bgPath = NSBezierPath(roundedRect: rect.insetBy(dx: 20 * scale, dy: 20 * scale),
                               xRadius: 80 * scale, yRadius: 80 * scale)
    gradient.draw(in: bgPath, angle: 45)

    // Subtle border
    NSColor(white: 0.3, alpha: 0.5).setStroke()
    bgPath.lineWidth = 4 * scale
    bgPath.stroke()

    // Monitor screen
    let screenRect = NSRect(x: 100 * scale, y: 160 * scale, width: 312 * scale, height: 200 * scale)
    let screenPath = NSBezierPath(roundedRect: screenRect, xRadius: 16 * scale, yRadius: 16 * scale)
    NSColor(red: 0.08, green: 0.08, blue: 0.12, alpha: 1.0).setFill()
    screenPath.fill()
    NSColor(red: 0.3, green: 0.5, blue: 0.9, alpha: 0.5).setStroke()
    screenPath.lineWidth = 3 * scale
    screenPath.stroke()

    // Monitor stand
    let standPath = NSBezierPath()
    standPath.move(to: NSPoint(x: 220 * scale, y: 160 * scale))
    standPath.line(to: NSPoint(x: 220 * scale, y: 120 * scale))
    standPath.line(to: NSPoint(x: 180 * scale, y: 100 * scale))
    standPath.line(to: NSPoint(x: 332 * scale, y: 100 * scale))
    standPath.line(to: NSPoint(x: 292 * scale, y: 120 * scale))
    standPath.line(to: NSPoint(x: 292 * scale, y: 160 * scale))
    NSColor(red: 0.25, green: 0.25, blue: 0.35, alpha: 1.0).setFill()
    standPath.fill()

    // Pulse line (heartbeat style)
    let pulsePath = NSBezierPath()
    pulsePath.move(to: NSPoint(x: 120 * scale, y: 260 * scale))
    pulsePath.line(to: NSPoint(x: 180 * scale, y: 260 * scale))
    pulsePath.line(to: NSPoint(x: 200 * scale, y: 290 * scale))
    pulsePath.line(to: NSPoint(x: 230 * scale, y: 200 * scale))
    pulsePath.line(to: NSPoint(x: 260 * scale, y: 320 * scale))
    pulsePath.line(to: NSPoint(x: 290 * scale, y: 240 * scale))
    pulsePath.line(to: NSPoint(x: 320 * scale, y: 280 * scale))
    pulsePath.line(to: NSPoint(x: 350 * scale, y: 260 * scale))
    pulsePath.line(to: NSPoint(x: 390 * scale, y: 260 * scale))

    // Glow effect
    NSColor(red: 0.3, green: 0.8, blue: 0.5, alpha: 0.3).setStroke()
    pulsePath.lineWidth = 12 * scale
    pulsePath.lineCapStyle = .round
    pulsePath.lineJoinStyle = .round
    pulsePath.stroke()

    // Main pulse line
    NSColor(red: 0.3, green: 0.9, blue: 0.5, alpha: 1.0).setStroke()
    pulsePath.lineWidth = 6 * scale
    pulsePath.stroke()

    // CPU usage bars at bottom
    let barColors = [
        NSColor(red: 0.35, green: 0.55, blue: 1.0, alpha: 1.0),  // CPU blue
        NSColor(red: 1.0, green: 0.45, blue: 0.35, alpha: 1.0),  // Memory red
        NSColor(red: 0.3, green: 0.9, blue: 0.5, alpha: 1.0),    // Network green
        NSColor(red: 0.95, green: 0.65, blue: 0.15, alpha: 1.0)  // Disk orange
    ]
    let barHeights: [CGFloat] = [0.7, 0.5, 0.3, 0.6]

    for i in 0..<4 {
        let barX = (140 + CGFloat(i) * 60) * scale
        let barMaxH: CGFloat = 60 * scale
        let barH = barMaxH * barHeights[i]
        let barRect = NSRect(x: barX, y: 400 * scale, width: 40 * scale, height: barH)
        let barPath = NSBezierPath(roundedRect: barRect, xRadius: 4 * scale, yRadius: 4 * scale)
        barColors[i].setFill()
        barPath.fill()
    }

    image.unlockFocus()
    return image
}

// Create iconset
let iconsetPath = "resources/AppIcon.iconset"
let fm = FileManager.default
try? fm.removeItem(atPath: iconsetPath)
try! fm.createDirectory(atPath: iconsetPath, withIntermediateDirectories: true)

let sizes = [16, 32, 64, 128, 256, 512]
for size in sizes {
    let icon = createIcon(size: size)

    // 1x
    if let tiff = icon.tiffRepresentation,
       let bitmap = NSBitmapImageRep(data: tiff),
       let png = bitmap.representation(using: .png, properties: [:]) {
        try! png.write(to: URL(fileURLWithPath: "\(iconsetPath)/icon_\(size)x\(size).png"))
    }

    // 2x (for Retina)
    let icon2x = createIcon(size: size * 2)
    if let tiff = icon2x.tiffRepresentation,
       let bitmap = NSBitmapImageRep(data: tiff),
       let png = bitmap.representation(using: .png, properties: [:]) {
        try! png.write(to: URL(fileURLWithPath: "\(iconsetPath)/icon_\(size)x\(size)@2x.png"))
    }
}

print("Iconset created at \(iconsetPath)")
print("Converting to icns...")

// Convert to icns using iconutil
let process = Process()
process.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
process.arguments = ["-c", "icns", iconsetPath, "-o", "resources/AppIcon.icns"]
try! process.run()
process.waitUntilExit()

if process.terminationStatus == 0 {
    print("AppIcon.icns created successfully!")
    try? fm.removeItem(atPath: iconsetPath)
} else {
    print("Failed to create icns file")
}
