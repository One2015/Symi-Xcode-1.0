import Foundation
import SwiftUI

class MainViewModel: ObservableObject {
    @Published var selectedTab: Tab = .main
    
    enum Tab: CaseIterable {
        case main
        case history
        case settings
        
        var title: String {
            switch self {
            case .main: return "Symi"
            case .history: return "History"
            case .settings: return "Settings"
            }
        }
        
        var systemImage: String {
            switch self {
            case .main: return "house.fill"
            case .history: return "clock.fill"
            case .settings: return "gearshape.fill"
            }
        }
    }
    
    func selectTab(_ tab: Tab) {
        selectedTab = tab
    }
}