import SwiftUI

struct HistoryView: View {
    @StateObject private var viewModel = DIContainer.shared.historyViewModel
    @State private var showingDoctorReport = false
    @State private var showingFilterSheet = false
    @State private var selectedFilter: FilterOption = .all
    
    enum FilterOption: String, CaseIterable {
        case all = "All"
        case voice = "Voice"
        case text = "Text"
        case today = "Today"
        case thisWeek = "This Week"
        
        var systemImage: String {
            switch self {
            case .all: return "list.bullet"
            case .voice: return "mic.fill"
            case .text: return "pencil"
            case .today: return "calendar"
            case .thisWeek: return "calendar.badge.clock"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Filter bar
                if !viewModel.entries.isEmpty {
                    filterBar
                }
                
                if viewModel.isLoading {
                    Spacer()
                    ProgressView("Loading entries...")
                    Spacer()
                } else if filteredEntries.isEmpty {
                    emptyStateView
                } else {
                    entriesListView
                }
            }
            .navigationTitle("History")
            .searchable(text: $viewModel.searchText, prompt: "Search symptoms...")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if !viewModel.entries.isEmpty {
                        Button(action: {
                            showingFilterSheet = true
                        }) {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !viewModel.entries.isEmpty {
                        Button("AI Report") {
                            showingDoctorReport = true
                        }
                        .foregroundColor(.blue)
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
        .sheet(isPresented: $showingFilterSheet) {
            filterSheet
        }
    }
    
    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(FilterOption.allCases, id: \.self) { filter in
                    Button(action: {
                        selectedFilter = filter
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: filter.systemImage)
                                .font(.caption)
                            Text(filter.rawValue)
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(selectedFilter == filter ? Color.blue : Color.gray.opacity(0.2))
                        )
                        .foregroundColor(selectedFilter == filter ? .white : .primary)
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
    
    private var filterSheet: some View {
        NavigationView {
            List {
                Section("Filter Options") {
                    ForEach(FilterOption.allCases, id: \.self) { filter in
                        Button(action: {
                            selectedFilter = filter
                            showingFilterSheet = false
                        }) {
                            HStack {
                                Image(systemName: filter.systemImage)
                                    .foregroundColor(.blue)
                                    .frame(width: 24)
                                
                                Text(filter.rawValue)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                if selectedFilter == filter {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Filter Entries")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showingFilterSheet = false
                    }
                }
            }
        }
    }
    
    private var filteredEntries: [SymptomEntry] {
        let searchFiltered = viewModel.filteredEntries
        
        switch selectedFilter {
        case .all:
            return searchFiltered
        case .voice:
            return searchFiltered.filter { $0.source == .voice }
        case .text:
            return searchFiltered.filter { $0.source == .text }
        case .today:
            let today = Calendar.current.startOfDay(for: Date())
            return searchFiltered.filter { Calendar.current.isDate($0.createdAt, inSameDayAs: today) }
        case .thisWeek:
            let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
            return searchFiltered.filter { $0.createdAt >= weekAgo }
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
            ForEach(filteredEntries) { entry in
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