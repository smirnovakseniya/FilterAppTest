import Foundation

extension String {
    var localized: String {
        LocalizationManager.shared.localized(self)
    }
}
