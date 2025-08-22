import SwiftUI

struct NewSymptomView: View {
    let inputMode: SymptomInputMode
    @StateObject private var viewModel = DIContainer.shared.newSymptomViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Main Content
                ScrollView {
                    VStack(spacing: 20) {
                        if inputMode == .voice {
                            voiceSection
                        } else {
                            textSection
                        }
                        
                        if viewModel.hasContent {
                            bottomSheetContent
                        }
                    }
                    .padding()
                }
                
                Spacer()
            }
            .navigationTitle(inputMode == .voice ? "Voice Input" : "Text Input")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                if viewModel.hasContent {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Save") {
                            viewModel.saveEntry(inputMode: inputMode) {
                                dismiss()
                            }
                        }
                        .disabled(!viewModel.canSave)
                    }
                }
            }
        }
        .sheet(isPresented: $viewModel.showingTranscriptionSheet) {
            TranscriptionSheetView(state: viewModel.transcriptionState)
        }
        .sheet(isPresented: $viewModel.showingAttachmentPicker) {
            AttachmentPicker { data, filename in
                viewModel.addAttachment(data: data, filename: filename)
            }
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
    
    // MARK: - Voice Section
    
    private var voiceSection: some View {
        VStack(spacing: 24) {
            Text("Tap to record your symptoms")
                .font(.headline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: {
                if viewModel.transcriptionState.isRecording {
                    viewModel.stopRecording()
                } else {
                    viewModel.startRecording()
                }
            }) {
                ZStack {
                    Circle()
                        .fill(viewModel.transcriptionState.isRecording ? Color.red : Color.blue)
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: viewModel.transcriptionState.isRecording ? "stop.fill" : "mic.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                }
            }
            .scaleEffect(viewModel.transcriptionState.isRecording ? 1.1 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: viewModel.transcriptionState.isRecording)
            
            if case .ready(let text) = viewModel.transcriptionState {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Transcription:")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(text)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    
    // MARK: - Text Section
    
    private var textSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Describe your symptoms")
                .font(.headline)
                .foregroundColor(.primary)
            
            TextEditor(text: $viewModel.textInput)
                .frame(minHeight: 150)
                .padding(8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
    }
    
    // MARK: - Bottom Sheet Content
    
    private var bottomSheetContent: some View {
        VStack(spacing: 20) {
            // Attachment and Translation Row
            HStack {
                Spacer()
                
                // Attachment Button
                Button(action: {
                    viewModel.showingAttachmentPicker = true
                }) {
                    Image(systemName: "paperclip")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                
                Spacer().frame(width: 20)
                
                // Translation Button
                Menu {
                    ForEach(Language.allCases, id: \.self) { language in
                        Button(action: {
                            if viewModel.selectedLanguage != language {
                                viewModel.selectedLanguage = language
                                viewModel.translateContent()
                            }
                        }) {
                            HStack {
                                Text("\(language.flag) \(language.displayName)")
                                if viewModel.selectedLanguage == language {
                                    Spacer()
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    Image(systemName: "globe")
                        .font(.title2)
                        .foregroundColor(.blue)
                        .overlay(
                            Text(viewModel.selectedLanguage.flag)
                                .font(.caption2)
                                .offset(x: 8, y: 8)
                        )
                }
            }
            
            // Attachments
            if !viewModel.attachments.isEmpty {
                attachmentsSection
            }
            
            // AI Summary Section
            aiSummarySection
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 4)
    }
    
    private var attachmentsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Attachments")
                .font(.headline)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                ForEach(viewModel.attachments) { attachment in
                    AttachmentChip(attachment: attachment) {
                        viewModel.removeAttachment(attachment)
                    }
                }
            }
        }
    }
    
    private var aiSummarySection: some View {
        VStack(spacing: 16) {
            // AI Summary Button
            Button(action: {
                viewModel.generateAISummary()
            }) {
                HStack {
                    if viewModel.isGeneratingSummary {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "sparkles")
                    }
                    
                    Text("AI Summary")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(viewModel.canGenerateSummary ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(25)
            }
            .disabled(!viewModel.canGenerateSummary)
            
            // AI Summary Content
            if !viewModel.aiSummary.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("AI Summary:")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(viewModel.aiSummary)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

struct AttachmentChip: View {
    let attachment: Attachment
    let onRemove: () -> Void
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 60)
                    .overlay(
                        Image(systemName: attachment.isImage ? "photo" : "doc.text")
                            .font(.title2)
                            .foregroundColor(.gray)
                    )
                
                Button(action: onRemove) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.red)
                        .background(Color.white)
                        .clipShape(Circle())
                }
                .offset(x: 4, y: -4)
            }
            
            Text(attachment.filename)
                .font(.caption2)
                .lineLimit(1)
                .truncationMode(.middle)
        }
    }
}

#Preview {
    NewSymptomView(inputMode: .voice)
}