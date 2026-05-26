import AppKit

@MainActor
final class ToastWindowController {
    private var window: NSPanel?
    private var hideWorkItem: DispatchWorkItem?

    func show() {
        hideWorkItem?.cancel()

        let panel = window ?? makeWindow()
        window = panel

        position(panel)
        panel.alphaValue = 0
        panel.orderFrontRegardless()

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.18
            panel.animator().alphaValue = 1
        }

        let workItem = DispatchWorkItem { [weak self] in
            Task { @MainActor in
                self?.hide()
            }
        }
        hideWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: workItem)
    }

    private func hide() {
        guard let panel = window else {
            return
        }

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.18
            panel.animator().alphaValue = 0
        } completionHandler: {
            panel.orderOut(nil)
        }
    }

    private func makeWindow() -> NSPanel {
        let contentView = NSVisualEffectView(frame: NSRect(x: 0, y: 0, width: 360, height: 82))
        contentView.material = .hudWindow
        contentView.blendingMode = .behindWindow
        contentView.state = .active
        contentView.wantsLayer = true
        contentView.layer?.cornerRadius = 16
        contentView.layer?.masksToBounds = true

        let title = NSTextField(labelWithString: "Browitch is running")
        title.font = .systemFont(ofSize: 15, weight: .semibold)
        title.textColor = .labelColor
        title.translatesAutoresizingMaskIntoConstraints = false

        let message = NSTextField(labelWithString: "Use the menu bar icon to switch browsers.")
        message.font = .systemFont(ofSize: 13, weight: .regular)
        message.textColor = .secondaryLabelColor
        message.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(title)
        contentView.addSubview(message)

        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            title.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            title.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 17),
            message.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            message.trailingAnchor.constraint(equalTo: title.trailingAnchor),
            message.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 6)
        ])

        let panel = NSPanel(
            contentRect: contentView.frame,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.contentView = contentView
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .transient]
        panel.hidesOnDeactivate = false
        panel.ignoresMouseEvents = true

        return panel
    }

    private func position(_ panel: NSPanel) {
        let screen = NSScreen.main ?? NSScreen.screens.first
        guard let visibleFrame = screen?.visibleFrame else {
            panel.center()
            return
        }

        let size = panel.frame.size
        let origin = NSPoint(
            x: visibleFrame.maxX - size.width - 22,
            y: visibleFrame.maxY - size.height - 22
        )
        panel.setFrameOrigin(origin)
    }
}
