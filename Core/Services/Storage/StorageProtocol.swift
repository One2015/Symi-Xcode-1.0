import Foundation
import Combine

protocol StorageProtocol {
    // Symptom Entries
    func saveEntry(_ entry: SymptomEntry) -> AnyPublisher<Void, Error>
    func loadEntries() -> AnyPublisher<[SymptomEntry], Error>
    func deleteEntry(id: UUID) -> AnyPublisher<Void, Error>
    
    // Attachments
    func saveAttachment(data: Data, filename: String) -> AnyPublisher<Attachment, Error>
    func loadAttachment(attachment: Attachment) -> AnyPublisher<Data, Error>
    func deleteAttachment(_ attachment: Attachment) -> AnyPublisher<Void, Error>
    
    // Reports
    func saveReport(_ report: DoctorReport) -> AnyPublisher<Void, Error>
    func loadReports() -> AnyPublisher<[DoctorReport], Error>
    
    // Settings
    func saveSettings<T: Codable>(_ value: T, forKey key: String) -> AnyPublisher<Void, Error>
    func loadSettings<T: Codable>(_ type: T.Type, forKey key: String) -> AnyPublisher<T?, Error>
    
    // Cleanup
    func clearAllData() -> AnyPublisher<Void, Error>
}