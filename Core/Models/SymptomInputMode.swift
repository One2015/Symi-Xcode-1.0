import Foundation

enum SymptomInputMode {
    case voice, text
    
    var displayName: String {
        switch self {
        case .voice: return "Voice"
        case .text: return "Text"
        }
    }
    
    var systemImage: String {
        switch self {
        case .voice: return "mic.fill"
        case .text: return "pencil"
        }
    }
}