import Foundation

struct SymptomEntry: Identifiable, Codable {
    let id: UUID
    let createdAt: Date
    let source: InputSource
    var rawText: String
    var aiSummary: String?
    var language: Language
    var attachments: [Attachment]
    
    init(source: InputSource, rawText: String, language: Language = .english) {
        self.id = UUID()
        self.createdAt = Date()
        self.source = source
        self.rawText = rawText
        self.aiSummary = nil
        self.language = language
        self.attachments = []
    }
    
    enum InputSource: String, Codable, CaseIterable {
        case voice = "voice"
        case text = "text"
        
        var displayName: String {
            switch self {
            case .voice: return "Voice"
            case .text: return "Text"
            }
        }
    }
}