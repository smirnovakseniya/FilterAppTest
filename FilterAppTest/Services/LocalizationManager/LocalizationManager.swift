import Foundation

final class LocalizationManager {
    
    static let shared = LocalizationManager()
    
    private(set) var currentLocale: Locale = Locale.current
    private var translators: [String: LocalizationTranslatorProtocol] = [:]
    
    func update(locale: Locale) {
        self.currentLocale = locale
    }
    
    func localized(_ key: String, defValue: String? = nil) -> String {
        let translator = translator(for: currentLocale)
        return translator.translation(forKey: key, defValue: defValue)
    }
    
    private func translator(for locale: Locale) -> LocalizationTranslatorProtocol {
        let localeId = locale.identifier
        if let existing = translators[localeId] {
            return existing
        }
        
        let bundle = bundle(for: locale)
        let translator = BundleTranslator(bundle: bundle)
        translators[localeId] = translator
        return translator
    }
    
    func bundle(for locale: Locale) -> Bundle {
        let localeIdentifier = locale.identifier
        
        let mainBundle = Bundle.main
        
        var path = mainBundle.path(forResource: localeIdentifier, ofType: "lproj")
        var localeBundle = path != nil ? Bundle.init(path: path!) : nil
        if localeBundle == nil {
            path = mainBundle.path(forResource: locale.localeLanguageCode, ofType: "lproj")
            localeBundle = path != nil ? Bundle.init(path: path!) : nil
        }
        
        if localeBundle == nil {
            path = mainBundle.path(forResource: "Base", ofType: "lproj")
            localeBundle = path != nil ? Bundle.init(path: path!) : nil
        }
        
        if localeBundle == nil {
            localeBundle = mainBundle
        }
        
        return localeBundle!
    }
    
    private final class BundleTranslator: LocalizationTranslatorProtocol {
        private let bundle: Bundle
        
        init(bundle: Bundle) {
            self.bundle = bundle
        }
        
        func translation(forKey key: String, defValue: String?) -> String {
            bundle.localizedString(forKey: key, value: defValue, table: nil)
        }
    }
}
