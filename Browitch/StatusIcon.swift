import AppKit

enum StatusIcon {
    static func make() -> NSImage {
        let image = NSImage(size: NSSize(width: 18, height: 18), flipped: false) { rect in
            NSColor.black.setStroke()

            let browserFrame = NSBezierPath(roundedRect: NSRect(x: 3.0, y: 4.0, width: 12.0, height: 10.5), xRadius: 2.4, yRadius: 2.4)
            browserFrame.lineWidth = 1.7
            browserFrame.stroke()

            let topLine = NSBezierPath()
            topLine.move(to: NSPoint(x: 4.5, y: 11.2))
            topLine.line(to: NSPoint(x: 13.5, y: 11.2))
            topLine.lineWidth = 1.4
            topLine.stroke()

            let switchStroke = NSBezierPath()
            switchStroke.move(to: NSPoint(x: 6.0, y: 6.8))
            switchStroke.line(to: NSPoint(x: 9.7, y: 9.0))
            switchStroke.line(to: NSPoint(x: 12.0, y: 6.8))
            switchStroke.lineWidth = 1.7
            switchStroke.lineCapStyle = .round
            switchStroke.lineJoinStyle = .round
            switchStroke.stroke()

            return true
        }

        image.isTemplate = true
        image.accessibilityDescription = "Browitch"
        return image
    }
}

extension NSImage {
    func menuSizedCopy() -> NSImage {
        let targetSize = NSSize(width: 18, height: 18)
        let copy = NSImage(size: targetSize)
        copy.lockFocus()
        NSGraphicsContext.current?.imageInterpolation = .high
        draw(in: NSRect(origin: .zero, size: targetSize), from: .zero, operation: .sourceOver, fraction: 1.0)
        copy.unlockFocus()
        copy.isTemplate = false
        return copy
    }
}
