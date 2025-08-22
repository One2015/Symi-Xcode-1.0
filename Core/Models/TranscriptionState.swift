import Foundation

enum TranscriptionState {
    case idle
    case recording
    case transcribing(progress: Double)
    case ready(text: String)
    case error(message: String)
    
    var isRecording: Bool {
        if case .recording = self {
            return true
        }
        return false
    }
    
    var isTranscribing: Bool {
        if case .transcribing = self {
            return true
        }
        return false
    }
    
    var isReady: Bool {
        if case .ready = self {
            return true
        }
        return false
    }
    
    var hasError: Bool {
        if case .error = self {
            return true
        }
        return false
    }
    
    var readyText: String? {
        if case .ready(let text) = self {
            return text
        }
        return nil
    }
    
    var errorMessage: String? {
        if case .error(let message) = self {
            return message
        }
        return nil
    }
    
    var progress: Double? {
        if case .transcribing(let progress) = self {
            return progress
        }
        return nil
    }
}