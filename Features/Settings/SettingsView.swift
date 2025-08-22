import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = DIContainer.shared.settingsViewModel
    
    var body: some View {
        NavigationView {
            List {
                // Storage Section
                Section("Storage") {
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
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.gray)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Symi 2.0")
                            Text("Symptom tracking app")
                                .font(.caption)
                                .foregroundColor(.secondary)
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
        }
    }
}

#Preview {
    SettingsView()
}