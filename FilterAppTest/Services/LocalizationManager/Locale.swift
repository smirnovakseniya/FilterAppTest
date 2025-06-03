import Foundation

extension Locale {
    
    static let english = Locale(identifier: "en")
    static let russian = Locale(identifier: "ru")
    
    private static let languageNameToLocale: [String: Locale] = [
        "English": .english,
        "Russian": .russian
    ]
    
    static func locale(forLanguageName name: String?) -> Locale {
        guard let name = name else { return .current }
        return languageNameToLocale[name] ?? .current
    }
    
    var languageName: String {
        switch self.localeLanguageCode {
        case "en": return "English"
        case "ru": return "Russian"
        default: return "English"
        }
    }
    
    var localeLanguageCode: String {
        if #available(iOS 16.0, *) {
            return self.language.languageCode?.identifier ?? ""
        } else {
            return self.languageCode ?? ""
        }
    }
    
    var longId: String {
        switch self.localeLanguageCode {
        case "en": return "eng"
        case "ru": return "rus"
        default:   return "rus"
        }
    }
}
