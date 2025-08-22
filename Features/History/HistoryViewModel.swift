import Foundation
import Combine

class HistoryViewModel: ObservableObject {
    @Published var entries: [SymptomEntry] = []
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let storage: StorageProtocol
    private let reportBuilder: ReportBuilder
    private var cancellables = Set<AnyCancellable>()
    
    init(storage: StorageProtocol, reportBuilder: ReportBuilder) {
        self.storage = storage
        self.reportBuilder = reportBuilder
        loadEntries()
    }
    
    var filteredEntries: [SymptomEntry] {
        if searchText.isEmpty {
            return entries
        } else {
            return entries.filter { entry in
                entry.rawText.localizedCaseInsensitiveContains(searchText) ||
                (entry.aiSummary?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
    }
    
    func loadEntries() {
        isLoading = true
        
        storage.loadEntries()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    self.isLoading = false
                    if case .failure(let error) = completion {
                        self.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { entries in
                    self.entries = entries
                }
            )
            .store(in: &cancellables)
    }
    
    func deleteEntry(_ entry: SymptomEntry) {
        storage.deleteEntry(id: entry.id)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        self.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { _ in
                    self.entries.removeAll { $0.id == entry.id }
                }
            )
            .store(in: &cancellables)
    }
    
    func generateDoctorReport() -> DoctorReport {
        return reportBuilder.generateReport(from: entries)
    }
}