import Foundation
import Combine

protocol AISummaryService {
    func generateSummary(for text: String, language: Language) -> AnyPublisher<String, Error>
}

class MockAISummaryService: AISummaryService {
    func generateSummary(for text: String, language: Language) -> AnyPublisher<String, Error> {
        return Future { promise in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                let summary = """
                Based on the symptoms described, this appears to be a common condition that may require attention. 
                
                Key observations:
                • \(text.prefix(50))...
                • Duration and severity should be monitored
                • Consider environmental factors
                
                Recommendation: Track symptoms and consult healthcare provider if symptoms persist or worsen.
                """
                promise(.success(summary))
            }
        }
        .eraseToAnyPublisher()
    }
}