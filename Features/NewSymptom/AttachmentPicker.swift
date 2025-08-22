import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct AttachmentPicker: View {
    let onAttachmentSelected: (Data, String) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingImagePicker = false
    @State private var showingDocumentPicker = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    
    var body: some View {
        NavigationView {
            List {
                Section("Add Attachment") {
                    // Photo/Image Button
                    Button(action: {
                        showingImagePicker = true
                    }) {
                        HStack {
                            Image(systemName: "photo")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Photo or Image")
                                    .foregroundColor(.primary)
                                
                                Text("JPG, PNG, HEIC")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    // Document Button
                    Button(action: {
                        showingDocumentPicker = true
                    }) {
                        HStack {
                            Image(systemName: "doc.text")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Document")
                                    .foregroundColor(.primary)
                                
                                Text("PDF, DOC, DOCX")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .navigationTitle("Add Attachment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .photosPicker(isPresented: $showingImagePicker, 
                      selection: $selectedPhotoItem,
                      matching: .any(of: [.images, .not(.videos)]))
        .fileImporter(
            isPresented: $showingDocumentPicker,
            allowedContentTypes: [.pdf, 
                                UTType(filenameExtension: "doc") ?? .data,
                                UTType(filenameExtension: "docx") ?? .data],
            allowsMultipleSelection: false
        ) { result in
            handleDocumentSelection(result)
        }
        .onChange(of: selectedPhotoItem) { photoItem in
            if let photoItem = photoItem {
                handlePhotoSelection(photoItem)
            }
        }
    }
    
    private func handlePhotoSelection(_ item: PhotosPickerItem) {
        item.loadTransferable(type: Data.self) { result in
            switch result {
            case .success(let data):
                if let data = data {
                    // Determine file extension based on data type
                    let fileExtension = self.determineImageFileExtension(from: data)
                    let filename = "image_\(Date().timeIntervalSince1970).\(fileExtension)"
                    DispatchQueue.main.async {
                        onAttachmentSelected(data, filename)
                        dismiss()
                    }
                }
            case .failure(let error):
                print("Failed to load photo: \(error)")
                DispatchQueue.main.async {
                    dismiss()
                }
            }
        }
    }
    
    private func determineImageFileExtension(from data: Data) -> String {
        // Check the first few bytes to determine image type
        guard data.count > 4 else { return "jpg" }
        
        if data.starts(with: [0xFF, 0xD8, 0xFF]) {
            return "jpg"
        } else if data.starts(with: [0x89, 0x50, 0x4E, 0x47]) {
            return "png"
        } else if data.starts(with: [0x66, 0x74, 0x79, 0x70]) {
            return "heic"
        } else {
            return "jpg" // Default fallback
        }
    }
    
    private func handleDocumentSelection(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            
            do {
                let data = try Data(contentsOf: url)
                let filename = url.lastPathComponent
                
                DispatchQueue.main.async {
                    onAttachmentSelected(data, filename)
                    dismiss()
                }
            } catch {
                print("Failed to load document: \(error)")
            }
            
        case .failure(let error):
            print("Document picker error: \(error)")
        }
    }
}

#Preview {
    AttachmentPicker { data, filename in
        print("Selected: \(filename)")
    }
}