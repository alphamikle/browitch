import Foundation
import ServiceManagement

enum LoginItemError: LocalizedError {
    case unableToEnable(Error)
    case unableToDisable(Error)

    var errorDescription: String? {
        switch self {
        case let .unableToEnable(error):
            return "Launch at Login could not be enabled. \(error.localizedDescription)"
        case let .unableToDisable(error):
            return "Launch at Login could not be disabled. \(error.localizedDescription)"
        }
    }
}

final class LoginItemController {
    var isEnabled: Bool {
        SMAppService.mainApp.status == .enabled
    }

    func setEnabled(_ enabled: Bool) throws {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            throw enabled ? LoginItemError.unableToEnable(error) : LoginItemError.unableToDisable(error)
        }
    }
}
