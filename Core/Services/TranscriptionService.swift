import Foundation
import Combine

protocol TranscriptionService {
    func transcribe(_ audioData: Data) -> AnyPublisher<String, Error>
}

class MockTranscriptionService: TranscriptionService {
    func transcribe(_ audioData: Data) -> AnyPublisher<String, Error> {
        return Future { promise in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                promise(.success("Mock transcription text"))
            }
        }
        .eraseToAnyPublisher()
    }
}