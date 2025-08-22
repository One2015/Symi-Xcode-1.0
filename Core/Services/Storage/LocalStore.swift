import Foundation
import Combine

class LocalStore: StorageProtocol {
    private let fileManager = FileManager.default
    private let documentsDirectory: URL
    private let attachmentsDirectory: URL
    
    init() {
        let applicationSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        self.documentsDirectory = applicationSupportURL.appendingPathComponent("Symi")
        self.attachmentsDirectory = documentsDirectory.appendingPathComponent("attachments")
        
        createDirectoriesIfNeeded()
    }
    
    private func createDirectoriesIfNeeded() {
        try? fileManager.createDirectory(at: documentsDirectory, withIntermediateDirectories: true)
        try? fileManager.createDirectory(at: attachmentsDirectory, withIntermediateDirectories: true)
    }
    
    // MARK: - Symptom Entries
    
    func saveEntry(_ entry: SymptomEntry) -> AnyPublisher<Void, Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(StorageError.unknown))
                return
            }
            
            do {
                var entries = try self.loadEntriesSync()
                entries.removeAll { $0.id == entry.id }
                entries.append(entry)
                entries.sort { $0.createdAt > $1.createdAt }
                
                let data = try JSONEncoder().encode(entries)
                let url = self.documentsDirectory.appendingPathComponent("entries.json")
                try data.write(to: url)
                
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func loadEntries() -> AnyPublisher<[SymptomEntry], Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(StorageError.unknown))
                return
            }
            
            do {
                let entries = try self.loadEntriesSync()
                promise(.success(entries))
            } catch {
                promise(.success([]))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func deleteEntry(id: UUID) -> AnyPublisher<Void, Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(StorageError.unknown))
                return
            }
            
            do {
                var entries = try self.loadEntriesSync()
                if let entryIndex = entries.firstIndex(where: { $0.id == id }) {
                    let entry = entries[entryIndex]
                    
                    // Delete attachments
                    for attachment in entry.attachments {
                        _ = try? self.deleteAttachmentSync(attachment)
                    }
                    
                    entries.remove(at: entryIndex)
                    
                    let data = try JSONEncoder().encode(entries)
                    let url = self.documentsDirectory.appendingPathComponent("entries.json")
                    try data.write(to: url)
                }
                
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func loadEntriesSync() throws -> [SymptomEntry] {
        let url = documentsDirectory.appendingPathComponent("entries.json")
        guard fileManager.fileExists(atPath: url.path) else {
            return []
        }
        
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([SymptomEntry].self, from: data)
    }
    
    // MARK: - Attachments
    
    func saveAttachment(data: Data, filename: String) -> AnyPublisher<Attachment, Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(StorageError.unknown))
                return
            }
            
            do {
                let attachmentId = UUID().uuidString
                let fileExtension = (filename as NSString).pathExtension.lowercased()
                let newFilename = "\(attachmentId).\(fileExtension)"
                let fileURL = self.attachmentsDirectory.appendingPathComponent(newFilename)
                
                try data.write(to: fileURL)
                
                let type: Attachment.AttachmentType = ["jpg", "jpeg", "png", "heic"].contains(fileExtension) ? .image : .document
                let attachment = Attachment(filename: filename, localPath: fileURL.path, type: type)
                
                promise(.success(attachment))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func loadAttachment(attachment: Attachment) -> AnyPublisher<Data, Error> {
        return Future { promise in
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: attachment.localPath))
                promise(.success(data))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func deleteAttachment(_ attachment: Attachment) -> AnyPublisher<Void, Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(StorageError.unknown))
                return
            }
            
            do {
                try self.deleteAttachmentSync(attachment)
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func deleteAttachmentSync(_ attachment: Attachment) throws {
        let url = URL(fileURLWithPath: attachment.localPath)
        if fileManager.fileExists(atPath: url.path) {
            try fileManager.removeItem(at: url)
        }
    }
    
    // MARK: - Reports
    
    func saveReport(_ report: DoctorReport) -> AnyPublisher<Void, Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(StorageError.unknown))
                return
            }
            
            do {
                var reports = try self.loadReportsSync()
                reports.removeAll { $0.id == report.id }
                reports.append(report)
                reports.sort { $0.generatedAt > $1.generatedAt }
                
                let data = try JSONEncoder().encode(reports)
                let url = self.documentsDirectory.appendingPathComponent("reports.json")
                try data.write(to: url)
                
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func loadReports() -> AnyPublisher<[DoctorReport], Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(StorageError.unknown))
                return
            }
            
            do {
                let reports = try self.loadReportsSync()
                promise(.success(reports))
            } catch {
                promise(.success([]))
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func loadReportsSync() throws -> [DoctorReport] {
        let url = documentsDirectory.appendingPathComponent("reports.json")
        guard fileManager.fileExists(atPath: url.path) else {
            return []
        }
        
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([DoctorReport].self, from: data)
    }
    
    // MARK: - Settings
    
    func saveSettings<T: Codable>(_ value: T, forKey key: String) -> AnyPublisher<Void, Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(StorageError.unknown))
                return
            }
            
            do {
                let data = try JSONEncoder().encode(value)
                let url = self.documentsDirectory.appendingPathComponent("settings.json")
                
                var settings: [String: Data] = [:]
                if fileManager.fileExists(atPath: url.path) {
                    let existingData = try Data(contentsOf: url)
                    settings = try JSONDecoder().decode([String: Data].self, from: existingData)
                }
                
                settings[key] = data
                let finalData = try JSONEncoder().encode(settings)
                try finalData.write(to: url)
                
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func loadSettings<T: Codable>(_ type: T.Type, forKey key: String) -> AnyPublisher<T?, Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(StorageError.unknown))
                return
            }
            
            do {
                let url = self.documentsDirectory.appendingPathComponent("settings.json")
                guard fileManager.fileExists(atPath: url.path) else {
                    promise(.success(nil))
                    return
                }
                
                let data = try Data(contentsOf: url)
                let settings = try JSONDecoder().decode([String: Data].self, from: data)
                
                guard let valueData = settings[key] else {
                    promise(.success(nil))
                    return
                }
                
                let value = try JSONDecoder().decode(type, from: valueData)
                promise(.success(value))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Cleanup
    
    func clearAllData() -> AnyPublisher<Void, Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(StorageError.unknown))
                return
            }
            
            do {
                if fileManager.fileExists(atPath: self.documentsDirectory.path) {
                    try fileManager.removeItem(at: self.documentsDirectory)
                }
                self.createDirectoriesIfNeeded()
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
}

enum StorageError: Error, LocalizedError {
    case unknown
    case fileNotFound
    case encodingError
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .unknown:
            return "Unknown storage error"
        case .fileNotFound:
            return "File not found"
        case .encodingError:
            return "Failed to encode data"
        case .decodingError:
            return "Failed to decode data"
        }
    }
}