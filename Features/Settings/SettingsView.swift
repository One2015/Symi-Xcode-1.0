import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = DIContainer.shared.settingsViewModel
    @State private var showingStorageInfo = false
    @State private var showingAppInfo = false
    
    var body: some View {
        NavigationView {
            List {
                // Storage Section
                Section("Storage & Sync") {
                    HStack {
                        Image(systemName: "icloud")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Cloud Storage")
                            Text("Sync data across devices")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $viewModel.isCloudStorageEnabled)
                            .onChange(of: viewModel.isCloudStorageEnabled) { _ in
                                viewModel.toggleCloudStorage()
                            }
                    }
                    
                    if viewModel.isCloudStorageEnabled {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.orange)
                                .frame(width: 24)
                            
                            Text("Cloud storage is not yet implemented. Data will remain local.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Button(action: {
                        showingStorageInfo = true
                    }) {
                        HStack {
                            Image(systemName: "internaldrive")
                                .foregroundColor(.gray)
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Storage Info")
                                    .foregroundColor(.primary)
                                Text("View data usage details")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                    }
                }
                
                // Data Management Section
                Section("Data Management") {
                    Button(action: {
                        viewModel.showingDeleteConfirmation = true
                    }) {
                        HStack {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                                .frame(width: 24)
                            
                            Text("Delete Account")
                                .foregroundColor(.red)
                        }
                    }
                }
                
                // Account Section
                Section("Account") {
                    Button(action: {
                        viewModel.logout()
                    }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            
                            Text("Logout")
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                // App Information
                Section("About") {
                    Button(action: {
                        showingAppInfo = true
                    }) {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Symi 2.0")
                                    .foregroundColor(.primary)
                                Text("Symptom tracking app")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                    }
                    
                    HStack {
                        Image(systemName: "hammer")
                            .foregroundColor(.gray)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Tech Stack")
                            Text("SwiftUI, MVVM, Mock Services")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack {
                        Image(systemName: "checkmark.seal")
                            .foregroundColor(.green)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Version")
                            Text("2.0.0 (Build 1)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .alert("Delete Account", isPresented: $viewModel.showingDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    viewModel.deleteAllData()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This will permanently delete all your symptom entries, attachments, and reports. This action cannot be undone.")
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .overlay {
                if viewModel.isLoading {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    ProgressView("Deleting data...")
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(8)
                }
            }
            .sheet(isPresented: $showingStorageInfo) {
                storageInfoSheet
            }
            .sheet(isPresented: $showingAppInfo) {
                appInfoSheet
            }
        }
    }
    
    private var storageInfoSheet: some View {
        NavigationView {
            List {
                Section("Local Storage") {
                    HStack {
                        Image(systemName: "doc.text")
                            .foregroundColor(.blue)
                        VStack(alignment: .leading) {
                            Text("Symptom Entries")
                            Text("Stored locally in JSON format")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text("~/Library/Application Support/Symi/")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "paperclip")
                            .foregroundColor(.orange)
                        VStack(alignment: .leading) {
                            Text("Attachments")
                            Text("Images and documents")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text("~/attachments/")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Data Security") {
                    HStack {
                        Image(systemName: "lock.shield")
                            .foregroundColor(.green)
                        Text("All data is stored locally on your device")
                    }
                    
                    HStack {
                        Image(systemName: "eye.slash")
                            .foregroundColor(.green)
                        Text("No data is shared with third parties")
                    }
                }
            }
            .navigationTitle("Storage Information")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showingStorageInfo = false
                    }
                }
            }
        }
    }
    
    private var appInfoSheet: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // App Icon and Title
                    VStack(spacing: 16) {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.blue.gradient)
                            .frame(width: 80, height: 80)
                            .overlay(
                                Text("S")
                                    .font(.system(size: 40, weight: .bold))
                                    .foregroundColor(.white)
                            )
                        
                        VStack(spacing: 4) {
                            Text("Symi 2.0")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("Symptom Tracking Made Simple")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 20)
                    
                    // Features
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Features")
                            .font(.headline)
                        
                        FeatureRow(icon: "mic.fill", title: "Voice Recording", description: "Record symptoms with your voice")
                        FeatureRow(icon: "pencil", title: "Text Input", description: "Write detailed symptom descriptions")
                        FeatureRow(icon: "sparkles", title: "AI Analysis", description: "Get intelligent symptom summaries")
                        FeatureRow(icon: "globe", title: "Translation", description: "Multi-language support")
                        FeatureRow(icon: "paperclip", title: "Attachments", description: "Add photos and documents")
                        FeatureRow(icon: "doc.text", title: "Doctor Reports", description: "Generate professional reports")
                    }
                    
                    // Credits
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Built With")
                            .font(.headline)
                        
                        Text("• SwiftUI for modern iOS design")
                        Text("• MVVM architecture pattern")
                        Text("• Combine for reactive programming")
                        Text("• Local storage with JSON + FileManager")
                        Text("• Mock services for development")
                    }
                    .font(.body)
                    .foregroundColor(.secondary)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("About Symi")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showingAppInfo = false
                    }
                }
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

#Preview {
    SettingsView()
}