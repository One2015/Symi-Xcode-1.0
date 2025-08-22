import Foundation
import Combine

protocol TranslationService {
    func translate(_ text: String, to language: Language) -> AnyPublisher<String, Error>
}

class MockTranslationService: TranslationService {
    func translate(_ text: String, to language: Language) -> AnyPublisher<String, Error> {
        return Future { promise in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                let translatedText = "\(text) (translated to \(language.displayName))"
                promise(.success(translatedText))
            }
        }
        .eraseToAnyPublisher()
    }
}