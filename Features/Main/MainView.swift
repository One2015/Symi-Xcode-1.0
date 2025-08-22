import SwiftUI

struct MainView: View {
    @EnvironmentObject var viewModel: MainViewModel
    
    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: MainViewModel.Tab.main.systemImage)
                    Text(MainViewModel.Tab.main.title)
                }
                .tag(MainViewModel.Tab.main)
            
            HistoryView()
                .tabItem {
                    Image(systemName: MainViewModel.Tab.history.systemImage)
                    Text(MainViewModel.Tab.history.title)
                }
                .tag(MainViewModel.Tab.history)
            
            SettingsView()
                .tabItem {
                    Image(systemName: MainViewModel.Tab.settings.systemImage)
                    Text(MainViewModel.Tab.settings.title)
                }
                .tag(MainViewModel.Tab.settings)
        }
        .accentColor(.blue)
    }
}

struct HomeView: View {
    @State private var showingNewSymptom = false
    @State private var symptomInputMode: SymptomInputMode = .voice
    
    var body: some View {
        NavigationView {
            VStack(spacing: 40) {
                Spacer()
                
                // App Title and Description
                VStack(spacing: 16) {
                    Text("Symi")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("Track your symptoms with voice or text")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 24) {
                    // Voice Button
                    Button(action: {
                        symptomInputMode = .voice
                        showingNewSymptom = true
                    }) {
                        HStack(spacing: 16) {
                            Image(systemName: "mic.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                            
                            Text("Speak your symptom")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.blue)
                                .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                        )
                    }
                    .padding(.horizontal, 32)
                    
                    // Text Button
                    Button(action: {
                        symptomInputMode = .text
                        showingNewSymptom = true
                    }) {
                        HStack(spacing: 16) {
                            Image(systemName: "pencil")
                                .font(.title2)
                                .foregroundColor(.blue)
                            
                            Text("Write your symptom")
                                .font(.headline)
                                .foregroundColor(.blue)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .strokeBorder(Color.blue, lineWidth: 2)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.blue.opacity(0.05))
                                )
                        )
                    }
                    .padding(.horizontal, 32)
                }
                
                Spacer()
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showingNewSymptom) {
            NewSymptomView(inputMode: symptomInputMode)
        }
    }
}

#Preview {
    MainView()
        .environmentObject(MainViewModel())
}