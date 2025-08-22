import Foundation

enum Language: String, Codable, CaseIterable {
    case english = "en"
    case chinese = "zh"
    case spanish = "es"
    case french = "fr"
    
    var displayName: String {
        switch self {
        case .english: return "English"
        case .chinese: return "中文"
        case .spanish: return "Español"
        case .french: return "Français"
        }
    }
    
    var code: String {
        return rawValue
    }
    
    var flag: String {
        switch self {
        case .english: return "🇺🇸"
        case .chinese: return "🇨🇳"
        case .spanish: return "🇪🇸"
        case .french: return "🇫🇷"
        }
    }
}