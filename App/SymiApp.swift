import SwiftUI

@main
struct SymiApp: App {
    private let container = DIContainer.shared
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(container.mainViewModel)
        }
    }
}