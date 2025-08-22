import Foundation
import Combine

class SettingsViewModel: ObservableObject {
    @Published var isCloudStorageEnabled: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showingDeleteConfirmation: Bool = false
    
    private let storage: StorageProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(storage: StorageProtocol) {
        self.storage = storage
        loadSettings()
    }
    
    func loadSettings() {
        storage.loadSettings(Bool.self, forKey: "cloudStorageEnabled")
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        self.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { isEnabled in
                    self.isCloudStorageEnabled = isEnabled ?? false
                }
            )
            .store(in: &cancellables)
    }
    
    func toggleCloudStorage() {
        isCloudStorageEnabled.toggle()
        
        storage.saveSettings(isCloudStorageEnabled, forKey: "cloudStorageEnabled")
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        self.errorMessage = error.localizedDescription
                        // Revert on error
                        self.isCloudStorageEnabled.toggle()
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
    }
    
    func deleteAllData() {
        isLoading = true
        
        storage.clearAllData()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    self.isLoading = false
                    if case .failure(let error) = completion {
                        self.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { _ in
                    // Data cleared successfully
                }
            )
            .store(in: &cancellables)
    }
    
    func logout() {
        // Stub implementation for logout functionality
        errorMessage = "Logout functionality not implemented yet"
    }
}