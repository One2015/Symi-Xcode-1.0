import Foundation
import Combine

protocol AISummaryService {
    func generateSummary(for text: String, language: Language) -> AnyPublisher<String, Error>
}

class MockAISummaryService: AISummaryService {
    func generateSummary(for text: String, language: Language) -> AnyPublisher<String, Error> {
        return Future { promise in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                let summary = self.createIntelligentSummary(for: text, language: language)
                promise(.success(summary))
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func createIntelligentSummary(for text: String, language: Language) -> String {
        let lowercaseText = text.lowercased()
        
        // Detect symptom categories
        var categories: [String] = []
        if lowercaseText.contains("headache") || lowercaseText.contains("head") {
            categories.append("Neurological")
        }
        if lowercaseText.contains("fever") || lowercaseText.contains("temperature") {
            categories.append("Systemic")
        }
        if lowercaseText.contains("cough") || lowercaseText.contains("throat") || lowercaseText.contains("breathing") {
            categories.append("Respiratory")
        }
        if lowercaseText.contains("stomach") || lowercaseText.contains("nausea") || lowercaseText.contains("digestive") {
            categories.append("Gastrointestinal")
        }
        if lowercaseText.contains("pain") || lowercaseText.contains("ache") {
            categories.append("Pain-related")
        }
        
        // Detect severity indicators
        var severity = "Moderate"
        if lowercaseText.contains("severe") || lowercaseText.contains("intense") || lowercaseText.contains("unbearable") {
            severity = "High"
        } else if lowercaseText.contains("mild") || lowercaseText.contains("slight") || lowercaseText.contains("minor") {
            severity = "Low"
        }
        
        // Detect duration
        var duration = "Recent onset"
        if lowercaseText.contains("week") || lowercaseText.contains("days") {
            duration = "Several days"
        } else if lowercaseText.contains("month") || lowercaseText.contains("chronic") {
            duration = "Ongoing/Chronic"
        }
        
        let categoryText = categories.isEmpty ? "General symptoms" : categories.joined(separator: ", ")
        
        let baseTemplate = """
        📋 **Symptom Analysis**
        
        **Primary Area**: \(categoryText)
        **Severity Level**: \(severity)
        **Duration**: \(duration)
        
        **Key Points**:
        • Symptoms reported: \(text.prefix(80))...
        • Pattern suggests monitoring is recommended
        • Consider tracking triggers and timing
        
        **Next Steps**:
        ✓ Continue documenting symptoms
        ✓ Note any changes in severity
        ✓ Consider consulting healthcare provider if symptoms persist
        
        *This is an AI-generated analysis for tracking purposes only.*
        """
        
        switch language {
        case .chinese:
            return """
            📋 **症状分析**
            
            **主要区域**: \(categoryText)
            **严重程度**: \(severity == "High" ? "高" : severity == "Low" ? "低" : "中等")
            **持续时间**: \(duration)
            
            **要点**:
            • 报告症状: \(text.prefix(80))...
            • 建议继续监测
            • 考虑记录诱因和时间
            
            **下一步**:
            ✓ 继续记录症状
            ✓ 注意严重程度的变化
            ✓ 如症状持续，考虑咨询医生
            
            *这是仅供跟踪用途的AI生成分析。*
            """
        default:
            return baseTemplate
        }
    }
}