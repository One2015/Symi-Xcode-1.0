import SwiftUI

struct TranscriptionSheetView: View {
    let state: TranscriptionState
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                
                // Status Content
                switch state {
                case .idle:
                    idleContent
                case .recording:
                    recordingContent
                case .transcribing(let progress):
                    transcribingContent(progress: progress)
                case .ready(let text):
                    readyContent(text: text)
                case .error(let message):
                    errorContent(message: message)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Transcription")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var idleContent: some View {
        VStack(spacing: 20) {
            Image(systemName: "mic.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Ready to record")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("Tap the microphone to start recording your symptoms")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var recordingContent: some View {
        VStack(spacing: 20) {
            ZStack {
                // Outer pulse ring
                Circle()
                    .fill(Color.red.opacity(0.2))
                    .frame(width: 140, height: 140)
                    .scaleEffect(1.2)
                    .opacity(0.6)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false), value: UUID())
                
                // Inner pulse ring
                Circle()
                    .fill(Color.red.opacity(0.3))
                    .frame(width: 120, height: 120)
                    .scaleEffect(1.1)
                    .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: false), value: UUID())
                
                // Core circle
                Circle()
                    .fill(Color.red)
                    .frame(width: 100, height: 100)
                
                Image(systemName: "mic.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }
            
            Text("Recording...")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.red)
                .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: UUID())
            
            Text("Speak clearly about your symptoms")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            // Recording timer could be added here
            Text("🎤 Listening...")
                .font(.caption)
                .foregroundColor(.red)
                .opacity(0.8)
        }
    }
    
    private func transcribingContent(progress: Double) -> some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 100, height: 100)
                
                ProgressView(value: progress)
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    .scaleEffect(2.0)
            }
            
            Text("Transcribing...")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.blue)
            
            Text("Converting your speech to text")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Text("\(Int(progress * 100))%")
                .font(.caption)
                .foregroundColor(.blue)
        }
    }
    
    private func readyContent(text: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            Text("Transcription Complete")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.green)
            
            ScrollView {
                Text(text)
                    .font(.body)
                    .foregroundColor(.primary)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
            .frame(maxHeight: 200)
        }
    }
    
    private func errorContent(message: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.red)
            
            Text("Transcription Error")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.red)
            
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()
                .background(Color.red.opacity(0.1))
                .cornerRadius(8)
        }
    }
}

#Preview {
    TranscriptionSheetView(state: .transcribing(progress: 0.6))
}