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
            
            ZStack(alignment: .topLeading) {
                TextEditor(text: $viewModel.textInput)
                    .frame(minHeight: 150)
                    .padding(12)
                    .background(Color.clear)
                    .scrollContentBackground(.hidden)
                
                if viewModel.textInput.isEmpty {
                    Text("Describe what you're feeling, when it started, severity, etc...")
                        .foregroundColor(.secondary.opacity(0.7))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 20)
                        .allowsHitTesting(false)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(viewModel.textInput.isEmpty ? Color.gray.opacity(0.3) : Color.blue.opacity(0.5), lineWidth: 1.5)
                    )
            )
            
            // Character count
            HStack {
                Spacer()
                Text("\(viewModel.textInput.count) characters")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
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
                                if !viewModel.textInput.isEmpty {
                                    viewModel.translateContent()
                                }
                            }
                        }) {
                            HStack {
                                Text("\(language.flag) \(language.displayName)")
                                    .font(.body)
                                Spacer()
                                if viewModel.selectedLanguage == language {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.blue)
                                }
                            }
                            .contentShape(Rectangle())
                        }
                    }
                } label: {
                    VStack(spacing: 4) {
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.1))
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: "globe")
                                .font(.title3)
                                .foregroundColor(.blue)
                        }
                        
                        Text(viewModel.selectedLanguage.flag)
                            .font(.caption)
                    }
                }
                .disabled(viewModel.isTranslating)
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
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(attachment.isImage ? Color.blue.opacity(0.1) : Color.orange.opacity(0.1))
                    .frame(height: 60)
                    .overlay(
                        VStack {
                            Image(systemName: attachment.isImage ? "photo.fill" : "doc.text.fill")
                                .font(.title2)
                                .foregroundColor(attachment.isImage ? .blue : .orange)
                            
                            if attachment.isImage {
                                Text("IMG")
                                    .font(.caption2)
                                    .foregroundColor(.blue)
                            } else {
                                Text(attachment.fileExtension.uppercased())
                                    .font(.caption2)
                                    .foregroundColor(.orange)
                            }
                        }
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(attachment.isImage ? Color.blue.opacity(0.3) : Color.orange.opacity(0.3), lineWidth: 1)
                    )
                
                Button(action: onRemove) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.red)
                        .background(Color.white)
                        .clipShape(Circle())
                }
                .offset(x: 6, y: -6)
            }
            
            Text(attachment.filename)
                .font(.caption2)
                .lineLimit(1)
                .truncationMode(.middle)
                .foregroundColor(.primary)
        }
        .scaleEffect(isLoading ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isLoading)
        .onTapGesture {
            isLoading = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isLoading = false
            }
        }
    }
}

#Preview {
    NewSymptomView(inputMode: .voice)
}