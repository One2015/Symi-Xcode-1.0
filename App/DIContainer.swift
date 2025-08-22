import Foundation

class DIContainer {
    static let shared = DIContainer()
    
    private init() {}
    
    // Services
    lazy var transcriptionService: TranscriptionService = MockTranscriptionService()
    lazy var aiSummaryService: AISummaryService = MockAISummaryService()
    lazy var translationService: TranslationService = MockTranslationService()
    lazy var reportBuilder: ReportBuilder = ReportBuilder()
    lazy var storage: StorageProtocol = LocalStore()
    
    // ViewModels
    lazy var mainViewModel: MainViewModel = MainViewModel()
    lazy var newSymptomViewModel: NewSymptomViewModel = NewSymptomViewModel(
        transcriptionService: transcriptionService,
        aiSummaryService: aiSummaryService,
        translationService: translationService,
        storage: storage
    )
    lazy var historyViewModel: HistoryViewModel = HistoryViewModel(
        storage: storage,
        reportBuilder: reportBuilder
    )
    lazy var settingsViewModel: SettingsViewModel = SettingsViewModel(storage: storage)
}