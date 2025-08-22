import Foundation
import SwiftUI
import Combine
import AVFoundation

class NewSymptomViewModel: ObservableObject {
    @Published var transcriptionState: TranscriptionState = .idle
    @Published var textInput: String = ""
    @Published var aiSummary: String = ""
    @Published var selectedLanguage: Language = .english
    @Published var attachments: [Attachment] = []
    @Published var isGeneratingSummary: Bool = false
    @Published var isSaving: Bool = false
    @Published var isTranslating: Bool = false
    @Published var showingAttachmentPicker: Bool = false
    @Published var showingLanguageSelector: Bool = false
    @Published var showingTranscriptionSheet: Bool = false
    @Published var errorMessage: String?
    
    private let transcriptionService: TranscriptionService
    private let aiSummaryService: AISummaryService
    private let translationService: TranslationService
    private let storage: StorageProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // Audio recording
    private var audioRecorder: AVAudioRecorder?
    private var recordingSession: AVAudioSession?
    private var recordingURL: URL?
    
    init(transcriptionService: TranscriptionService,
         aiSummaryService: AISummaryService,
         translationService: TranslationService,
         storage: StorageProtocol) {
        self.transcriptionService = transcriptionService
        self.aiSummaryService = aiSummaryService
        self.translationService = translationService
        self.storage = storage
        
        setupAudioSession()
        setupTranscriptionStateObserver()
    }
    
    // MARK: - Audio Setup
    
    private func setupTranscriptionStateObserver() {
        $transcriptionState
            .sink { state in
                switch state {
                case .transcribing, .ready, .error:
                    self.showingTranscriptionSheet = true
                default:
                    self.showingTranscriptionSheet = false
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupAudioSession() {
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession?.setCategory(.playAndRecord, mode: .default)
            try recordingSession?.setActive(true)
        } catch {
            print("Failed to set up recording session: \(error)")
        }
    }
    
    // MARK: - Recording
    
    func startRecording() {
        guard transcriptionState.isRecording == false else { return }
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        recordingURL = documentsPath.appendingPathComponent("recording.m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: recordingURL!, settings: settings)
            audioRecorder?.record()
            transcriptionState = .recording
        } catch {
            transcriptionState = .error(message: "Failed to start recording: \(error.localizedDescription)")
        }
    }
    
    func stopRecording() {
        guard transcriptionState.isRecording else { return }
        
        audioRecorder?.stop()
        audioRecorder = nil
        
        guard let recordingURL = recordingURL else {
            transcriptionState = .error(message: "No recording found")
            return
        }
        
        do {
            let audioData = try Data(contentsOf: recordingURL)
            transcribeAudio(audioData)
        } catch {
            transcriptionState = .error(message: "Failed to read recording: \(error.localizedDescription)")
        }
    }
    
    private func transcribeAudio(_ audioData: Data) {
        transcriptionState = .transcribing(progress: 0.0)
        
        // Simulate progress
        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if case .transcribing(let progress) = self.transcriptionState {
                if progress < 0.9 {
                    self.transcriptionState = .transcribing(progress: progress + 0.15)
                }
            } else {
                timer.invalidate()
            }
        }
        
        transcriptionService.transcribe(audioData)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    timer.invalidate()
                    if case .failure(let error) = completion {
                        self.transcriptionState = .error(message: error.localizedDescription)
                    }
                },
                receiveValue: { text in
                    timer.invalidate()
                    self.transcriptionState = .ready(text: text)
                    self.textInput = text
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - AI Summary
    
    func generateAISummary() {
        guard !textInput.isEmpty, !isGeneratingSummary else { return }
        
        isGeneratingSummary = true
        
        aiSummaryService.generateSummary(for: textInput, language: selectedLanguage)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    self.isGeneratingSummary = false
                    if case .failure(let error) = completion {
                        self.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { summary in
                    self.aiSummary = summary
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Translation
    
    func translateContent() {
        guard !textInput.isEmpty else { return }
        
        isTranslating = true
        
        let textToTranslate = textInput
        let summaryToTranslate = aiSummary
        
        let textPublisher = translationService.translate(textToTranslate, to: selectedLanguage)
        let summaryPublisher = !summaryToTranslate.isEmpty ?
            translationService.translate(summaryToTranslate, to: selectedLanguage) :
            Just("").setFailureType(to: Error.self).eraseToAnyPublisher()
        
        Publishers.CombineLatest(textPublisher, summaryPublisher)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    self.isTranslating = false
                    if case .failure(let error) = completion {
                        self.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { translatedText, translatedSummary in
                    self.textInput = translatedText
                    if !translatedSummary.isEmpty {
                        self.aiSummary = translatedSummary
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Attachments
    
    func addAttachment(data: Data, filename: String) {
        storage.saveAttachment(data: data, filename: filename)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        self.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { attachment in
                    self.attachments.append(attachment)
                }
            )
            .store(in: &cancellables)
    }
    
    func removeAttachment(_ attachment: Attachment) {
        storage.deleteAttachment(attachment)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        self.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { _ in
                    self.attachments.removeAll { $0.id == attachment.id }
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Save Entry
    
    func saveEntry(inputMode: SymptomInputMode, completion: @escaping () -> Void) {
        guard !textInput.isEmpty else { return }
        
        isSaving = true
        
        let source: SymptomEntry.InputSource = inputMode == .voice ? .voice : .text
        var entry = SymptomEntry(source: source, rawText: textInput, language: selectedLanguage)
        entry.aiSummary = aiSummary.isEmpty ? nil : aiSummary
        entry.attachments = attachments
        
        storage.saveEntry(entry)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completionResult in
                    self.isSaving = false
                    if case .failure(let error) = completionResult {
                        self.errorMessage = error.localizedDescription
                    } else {
                        completion()
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Computed Properties
    
    var canGenerateSummary: Bool {
        !textInput.isEmpty && !isGeneratingSummary
    }
    
    var canSave: Bool {
        !textInput.isEmpty && !isSaving
    }
    
    var hasContent: Bool {
        !textInput.isEmpty || !aiSummary.isEmpty || !attachments.isEmpty
    }
}

enum SymptomInputMode {
    case voice, text
}