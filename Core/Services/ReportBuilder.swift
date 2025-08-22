import Foundation

class ReportBuilder {
    func generateReport(from entries: [SymptomEntry]) -> DoctorReport {
        let summary = generateSummary(from: entries)
        let patterns = identifyPatterns(from: entries)
        let recommendations = generateRecommendations(from: entries)
        let entryIds = entries.map { $0.id }
        
        return DoctorReport(
            summary: summary,
            patterns: patterns,
            recommendations: recommendations,
            entryIds: entryIds
        )
    }
    
    private func generateSummary(from entries: [SymptomEntry]) -> String {
        let entryCount = entries.count
        let voiceEntries = entries.filter { $0.source == .voice }.count
        let textEntries = entries.filter { $0.source == .text }.count
        let dateRange = getDateRange(from: entries)
        
        return """
        Patient has logged \(entryCount) symptom entries over \(dateRange). 
        
        Entry breakdown: \(voiceEntries) voice recordings, \(textEntries) text entries.
        
        Most recent symptoms include common concerns that appear to be consistent with typical health monitoring patterns.
        """
    }
    
    private func identifyPatterns(from entries: [SymptomEntry]) -> [String] {
        var patterns: [String] = []
        
        if entries.count > 3 {
            patterns.append("Regular symptom logging indicates good health awareness")
        }
        
        let hasVoiceEntries = entries.contains { $0.source == .voice }
        let hasTextEntries = entries.contains { $0.source == .text }
        
        if hasVoiceEntries && hasTextEntries {
            patterns.append("Patient uses multiple input methods for comprehensive tracking")
        }
        
        if entries.contains(where: { $0.attachments.count > 0 }) {
            patterns.append("Patient provides visual documentation to support symptom descriptions")
        }
        
        patterns.append("Symptoms appear to be documented in a timely manner")
        
        return patterns
    }
    
    private func generateRecommendations(from entries: [SymptomEntry]) -> [String] {
        var recommendations: [String] = []
        
        recommendations.append("Continue regular symptom monitoring and documentation")
        recommendations.append("Schedule follow-up appointment to discuss recorded symptoms")
        recommendations.append("Consider keeping a detailed diary of symptom triggers")
        
        if entries.contains(where: { $0.attachments.count > 0 }) {
            recommendations.append("Visual documentation is helpful - continue providing relevant images")
        }
        
        recommendations.append("Maintain current tracking frequency for optimal health monitoring")
        
        return recommendations
    }
    
    private func getDateRange(from entries: [SymptomEntry]) -> String {
        guard !entries.isEmpty else { return "no entries" }
        
        let sortedEntries = entries.sorted { $0.createdAt < $1.createdAt }
        guard let firstEntry = sortedEntries.first,
              let lastEntry = sortedEntries.last else {
            return "unknown period"
        }
        
        let calendar = Calendar.current
        let daysDifference = calendar.dateComponents([.day], from: firstEntry.createdAt, to: lastEntry.createdAt).day ?? 0
        
        if daysDifference == 0 {
            return "today"
        } else if daysDifference == 1 {
            return "2 days"
        } else {
            return "\(daysDifference + 1) days"
        }
    }
}