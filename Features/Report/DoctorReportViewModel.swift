import Foundation
import SwiftUI

class DoctorReportViewModel: ObservableObject {
    let report: DoctorReport
    
    init(report: DoctorReport) {
        self.report = report
    }
    
    var formattedReport: String {
        var reportText = "# Symptom Report\n\n"
        reportText += "**Generated:** \(report.formattedDate)\n\n"
        
        reportText += "## Summary\n"
        reportText += "\(report.summary)\n\n"
        
        reportText += "## Patterns Identified\n"
        for (index, pattern) in report.patterns.enumerated() {
            reportText += "\(index + 1). \(pattern)\n"
        }
        reportText += "\n"
        
        reportText += "## Recommendations\n"
        for (index, recommendation) in report.recommendations.enumerated() {
            reportText += "\(index + 1). \(recommendation)\n"
        }
        reportText += "\n"
        
        reportText += "## Disclaimer\n"
        reportText += "\(report.disclaimer)\n"
        
        return reportText
    }
    
    func shareReport() {
        let activityController = UIActivityViewController(
            activityItems: [formattedReport],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityController, animated: true)
        }
    }
    
    func copyReport() {
        UIPasteboard.general.string = formattedReport
    }
}