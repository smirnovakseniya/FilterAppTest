import Foundation

protocol LocalizationTranslatorProtocol {
    func translation(forKey key: String, defValue: String?) -> String
}
