import SwiftUI

struct HistoryView: View {
    @StateObject private var viewModel = DIContainer.shared.historyViewModel
    @State private var showingDoctorReport = false
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    Spacer()
                    ProgressView("Loading entries...")
                    Spacer()
                } else if viewModel.entries.isEmpty {
                    emptyStateView
                } else {
                    entriesListView
                }
            }
            .navigationTitle("History")
            .searchable(text: $viewModel.searchText, prompt: "Search symptoms...")
            .toolbar {
                if !viewModel.entries.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("AI History") {
                            showingDoctorReport = true
                        }
                    }
                }
            }
            .sheet(isPresented: $showingDoctorReport) {
                DoctorReportView(report: viewModel.generateDoctorReport())
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
        .onAppear {
            viewModel.loadEntries()
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "clock.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Symptoms Recorded")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("Start tracking your symptoms by using the voice or text input on the home screen.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
        }
    }
    
    private var entriesListView: some View {
        List {
            ForEach(viewModel.filteredEntries) { entry in
                SymptomEntryRow(entry: entry)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button("Delete", role: .destructive) {
                            viewModel.deleteEntry(entry)
                        }
                    }
            }
        }
        .refreshable {
            viewModel.loadEntries()
        }
    }
}

struct SymptomEntryRow: View {
    let entry: SymptomEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: entry.source == .voice ? "mic.fill" : "pencil")
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    Text(entry.source.displayName)
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                Text(entry.createdAt, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Content
            Text(entry.rawText)
                .font(.body)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
            
            // AI Summary (if available)
            if let aiSummary = entry.aiSummary, !aiSummary.isEmpty {
                Text(aiSummary)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(6)
                    .lineLimit(2)
            }
            
            // Attachments indicator
            if !entry.attachments.isEmpty {
                HStack {
                    Image(systemName: "paperclip")
                        .font(.caption2)
                        .foregroundColor(.gray)
                    
                    Text("\(entry.attachments.count) attachment\(entry.attachments.count == 1 ? "" : "s")")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    HistoryView()
}