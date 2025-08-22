import SwiftUI

struct DoctorReportView: View {
    let report: DoctorReport
    @StateObject private var viewModel: DoctorReportViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingCopyConfirmation = false
    
    init(report: DoctorReport) {
        self.report = report
        self._viewModel = StateObject(wrappedValue: DoctorReportViewModel(report: report))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    headerSection
                    
                    // Summary
                    reportSection(title: "Summary", content: report.summary)
                    
                    // Patterns
                    patternsSection
                    
                    // Recommendations
                    recommendationsSection
                    
                    // Disclaimer
                    disclaimerSection
                }
                .padding()
            }
            .navigationTitle("Doctor Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {
                            viewModel.copyReport()
                            showingCopyConfirmation = true
                        }) {
                            Label("Copy", systemImage: "doc.on.clipboard")
                        }
                        
                        Button(action: {
                            viewModel.shareReport()
                        }) {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .alert("Copied", isPresented: $showingCopyConfirmation) {
            Button("OK") { }
        } message: {
            Text("Report copied to clipboard")
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("AI-Generated Symptom Report")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Generated on \(report.formattedDate)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private func reportSection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(content)
                .font(.body)
                .foregroundColor(.secondary)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
        }
    }
    
    private var patternsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Patterns Identified")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(report.patterns.enumerated()), id: \.offset) { index, pattern in
                    HStack(alignment: .top, spacing: 8) {
                        Text("\(index + 1).")
                            .font(.body)
                            .foregroundColor(.blue)
                            .fontWeight(.medium)
                        
                        Text(pattern)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(Color.blue.opacity(0.05))
            .cornerRadius(8)
        }
    }
    
    private var recommendationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recommendations")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(report.recommendations.enumerated()), id: \.offset) { index, recommendation in
                    HStack(alignment: .top, spacing: 8) {
                        Text("\(index + 1).")
                            .font(.body)
                            .foregroundColor(.green)
                            .fontWeight(.medium)
                        
                        Text(recommendation)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(Color.green.opacity(0.05))
            .cornerRadius(8)
        }
    }
    
    private var disclaimerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Important Disclaimer")
                .font(.headline)
                .foregroundColor(.red)
            
            Text(report.disclaimer)
                .font(.body)
                .foregroundColor(.secondary)
                .padding()
                .background(Color.red.opacity(0.05))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.red.opacity(0.3), lineWidth: 1)
                )
        }
    }
}

#Preview {
    let sampleReport = DoctorReport(
        summary: "Patient has logged 5 symptom entries over 3 days.",
        patterns: ["Regular symptom logging", "Multiple input methods used"],
        recommendations: ["Continue monitoring", "Schedule follow-up"],
        entryIds: []
    )
    
    return DoctorReportView(report: sampleReport)
}