import AppKit
import CoreServices

struct Browser: Equatable {
    let bundleIdentifier: String
    let displayName: String
    let appURL: URL
    let icon: NSImage
    let isDefault: Bool
}

enum BrowserManagerError: LocalizedError {
    case unableToSetDefaultBrowser(bundleIdentifier: String, status: OSStatus)

    var errorDescription: String? {
        switch self {
        case let .unableToSetDefaultBrowser(bundleIdentifier, status):
            return "macOS rejected changing the default browser to \(bundleIdentifier). LaunchServices returned \(status)."
        }
    }
}

enum DefaultBrowserChangeResult {
    case changed
    case requiresSystemConfirmation
}

final class BrowserManager {
    private let workspace = NSWorkspace.shared

    func installedBrowsers() -> [Browser] {
        let httpApps = applications(for: "http")
        let httpsApps = applications(for: "https")
        let browserBundleIdentifiers = Set(httpApps.keys)
            .intersection(Set(httpsApps.keys))
            .sorted { localizedName(for: $0, appURL: httpApps[$0]) < localizedName(for: $1, appURL: httpApps[$1]) }

        let defaultBrowser = defaultBrowserBundleIdentifier()

        return browserBundleIdentifiers.compactMap { bundleIdentifier in
            guard let appURL = httpApps[bundleIdentifier] else {
                return nil
            }

            let icon = workspace.icon(forFile: appURL.path)
            let displayName = displayName(for: appURL, fallbackBundleIdentifier: bundleIdentifier)

            return Browser(
                bundleIdentifier: bundleIdentifier,
                displayName: displayName,
                appURL: appURL,
                icon: icon,
                isDefault: bundleIdentifier == defaultBrowser
            )
        }
    }

    func isDefaultBrowser(bundleIdentifier: String) -> Bool {
        bundleIdentifier == defaultBrowserBundleIdentifier()
    }

    func setDefaultBrowser(bundleIdentifier: String) throws -> DefaultBrowserChangeResult {
        var requiresSystemConfirmation = false

        for scheme in ["http", "https"] {
            let status = LSSetDefaultHandlerForURLScheme(scheme as CFString, bundleIdentifier as CFString)

            if status == noErr {
                continue
            }

            if status == permErr {
                requiresSystemConfirmation = true
                continue
            }

            throw BrowserManagerError.unableToSetDefaultBrowser(
                bundleIdentifier: bundleIdentifier,
                status: status
            )
        }

        return requiresSystemConfirmation ? .requiresSystemConfirmation : .changed
    }

    private func applications(for scheme: String) -> [String: URL] {
        guard let testURL = URL(string: "\(scheme)://example.com") else {
            return [:]
        }

        return workspace.urlsForApplications(toOpen: testURL).reduce(into: [:]) { result, appURL in
            guard let bundleIdentifier = Bundle(url: appURL)?.bundleIdentifier else {
                return
            }

            result[bundleIdentifier] = appURL
        }
    }

    private func defaultBrowserBundleIdentifier() -> String? {
        guard let testURL = URL(string: "http://example.com"),
              let appURL = workspace.urlForApplication(toOpen: testURL) else {
            return nil
        }

        return Bundle(url: appURL)?.bundleIdentifier
    }

    private func localizedName(for bundleIdentifier: String, appURL: URL?) -> String {
        guard let appURL else {
            return bundleIdentifier
        }

        return displayName(for: appURL, fallbackBundleIdentifier: bundleIdentifier)
    }

    private func displayName(for appURL: URL, fallbackBundleIdentifier: String) -> String {
        if let bundle = Bundle(url: appURL),
           let displayName = bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String,
           !displayName.isEmpty {
            return displayName
        }

        if let bundle = Bundle(url: appURL),
           let name = bundle.object(forInfoDictionaryKey: "CFBundleName") as? String,
           !name.isEmpty {
            return name
        }

        return appURL.deletingPathExtension().lastPathComponent.isEmpty
            ? fallbackBundleIdentifier
            : appURL.deletingPathExtension().lastPathComponent
    }
}
