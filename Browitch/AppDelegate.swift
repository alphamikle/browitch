import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    private let browserManager = BrowserManager()
    private let loginItemController = LoginItemController()
    private var statusItem: NSStatusItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        configureStatusItem()
        rebuildMenu()

        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(workspaceApplicationsChanged),
            name: NSWorkspace.didLaunchApplicationNotification,
            object: nil
        )
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(workspaceApplicationsChanged),
            name: NSWorkspace.didTerminateApplicationNotification,
            object: nil
        )
    }

    func applicationWillTerminate(_ notification: Notification) {
        NSWorkspace.shared.notificationCenter.removeObserver(self)
    }

    private func configureStatusItem() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        item.button?.image = StatusIcon.make()
        item.button?.imagePosition = .imageOnly
        item.button?.toolTip = "Browitch"

        let menu = NSMenu()
        menu.delegate = self
        menu.autoenablesItems = false
        item.menu = menu

        statusItem = item
    }

    private func rebuildMenu() {
        guard let menu = statusItem?.menu else {
            return
        }

        menu.removeAllItems()
        menu.autoenablesItems = false

        let browsers = browserManager.installedBrowsers()
        if browsers.isEmpty {
            let emptyItem = NSMenuItem(title: "No HTTP(S) browsers found", action: nil, keyEquivalent: "")
            emptyItem.isEnabled = false
            menu.addItem(emptyItem)
        } else {
            for browser in browsers {
                let item = NSMenuItem(title: browser.displayName, action: #selector(selectBrowser(_:)), keyEquivalent: "")
                item.target = self
                item.representedObject = browser.bundleIdentifier
                item.state = browser.isDefault ? .on : .off
                item.image = browser.icon.menuSizedCopy()
                menu.addItem(item)
            }
        }

        menu.addItem(.separator())

        let launchAtLogin = NSMenuItem(
            title: "Launch at Login",
            action: #selector(toggleLaunchAtLogin(_:)),
            keyEquivalent: ""
        )
        launchAtLogin.target = self
        launchAtLogin.state = loginItemController.isEnabled ? .on : .off
        menu.addItem(launchAtLogin)

        let quit = NSMenuItem(title: "Quit Browitch", action: #selector(quit(_:)), keyEquivalent: "q")
        quit.target = self
        menu.addItem(quit)
    }

    @objc private func selectBrowser(_ sender: NSMenuItem) {
        guard let bundleIdentifier = sender.representedObject as? String else {
            return
        }

        guard !browserManager.isDefaultBrowser(bundleIdentifier: bundleIdentifier) else {
            return
        }

        do {
            let result = try browserManager.setDefaultBrowser(bundleIdentifier: bundleIdentifier)
            rebuildMenu()
            scheduleRefreshAfterDefaultChange()

            if result == .requiresSystemConfirmation {
                statusItem?.button?.highlight(false)
            }
        } catch {
            presentError(error)
        }
    }

    @objc private func toggleLaunchAtLogin(_ sender: NSMenuItem) {
        do {
            try loginItemController.setEnabled(!loginItemController.isEnabled)
            rebuildMenu()
        } catch {
            presentError(error)
        }
    }

    func menuNeedsUpdate(_ menu: NSMenu) {
        rebuildMenu()
    }

    @objc private func refreshBrowsersAfterDefaultChange() {
        rebuildMenu()
    }

    @objc private func workspaceApplicationsChanged(_ notification: Notification) {
        rebuildMenu()
    }

    @objc private func quit(_ sender: NSMenuItem) {
        NSApp.terminate(nil)
    }

    private func presentError(_ error: Error) {
        NSApp.activate(ignoringOtherApps: true)

        let alert = NSAlert(error: error)
        alert.messageText = "Browitch couldn't complete the change"
        alert.informativeText = error.localizedDescription
        alert.runModal()
    }

    private func scheduleRefreshAfterDefaultChange() {
        NSObject.cancelPreviousPerformRequests(
            withTarget: self,
            selector: #selector(refreshBrowsersAfterDefaultChange),
            object: nil
        )

        for delay in [0.4, 1.0, 2.0, 4.0, 8.0, 15.0, 30.0] {
            perform(#selector(refreshBrowsersAfterDefaultChange), with: nil, afterDelay: delay)
        }
    }
}
