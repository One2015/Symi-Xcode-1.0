import Foundation

struct Attachment: Identifiable, Codable {
    let id: UUID
    let filename: String
    let localPath: String
    let type: AttachmentType
    let createdAt: Date
    var metadata: [String: String]
    
    init(filename: String, localPath: String, type: AttachmentType) {
        self.id = UUID()
        self.filename = filename
        self.localPath = localPath
        self.type = type
        self.createdAt = Date()
        self.metadata = [:]
    }
    
    enum AttachmentType: String, Codable, CaseIterable {
        case image = "image"
        case document = "document"
        
        var supportedExtensions: [String] {
            switch self {
            case .image:
                return ["jpg", "jpeg", "png", "heic"]
            case .document:
                return ["pdf", "doc", "docx"]
            }
        }
        
        var displayName: String {
            switch self {
            case .image: return "Image"
            case .document: return "Document"
            }
        }
    }
    
    var fileExtension: String {
        (filename as NSString).pathExtension.lowercased()
    }
    
    var isImage: Bool {
        type == .image
    }
    
    var isDocument: Bool {
        type == .document
    }
}