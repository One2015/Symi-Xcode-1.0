import Foundation

struct DoctorReport: Identifiable, Codable {
    let id: UUID
    let generatedAt: Date
    let summary: String
    let patterns: [String]
    let recommendations: [String]
    let disclaimer: String
    let entryIds: [UUID]
    
    init(summary: String, patterns: [String], recommendations: [String], entryIds: [UUID]) {
        self.id = UUID()
        self.generatedAt = Date()
        self.summary = summary
        self.patterns = patterns
        self.recommendations = recommendations
        self.disclaimer = "This report is AI-generated based on symptom entries and should not replace professional medical advice. Please consult with a healthcare provider for proper diagnosis and treatment."
        self.entryIds = entryIds
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: generatedAt)
    }
}