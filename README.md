# Symi 2.0 - Symptom Tracking iOS App

A SwiftUI-based iOS application for recording and tracking symptoms through voice or text input, with AI-powered summaries and doctor-friendly reports.

## 🏗 Project Status
**Phase 1 Complete**: ✅ Project structure and basic navigation implemented

## 📱 Features Implemented

### Core Architecture
- **MVVM Pattern**: Clean separation of concerns with ViewModels managing business logic
- **Dependency Injection**: DIContainer for service management and testability
- **Combine Framework**: Reactive programming for async operations
- **Local Storage**: JSON + FileManager with cloud storage stub

### Models
- `SymptomEntry`: Core symptom data with voice/text source, AI summary, attachments
- `Attachment`: Image/document support (JPG/PNG/HEIC + PDF/DOC/DOCX)
- `Language`: Multi-language support (EN/ZH/ES/FR)
- `TranscriptionState`: Voice recording state machine
- `DoctorReport`: AI-generated reports for medical professionals

### Services (Mock Implementation)
- **TranscriptionService**: Converts voice to text (0.6s mock delay)
- **AISummaryService**: Generates AI symptom summaries (1.0s mock delay)
- **TranslationService**: Translates content between languages (0.3s mock delay)
- **ReportBuilder**: Creates doctor-friendly reports from symptom history
- **LocalStore**: JSON-based local persistence
- **CloudStore**: Placeholder for future cloud integration

### User Interface
- **MainView**: Tab-based navigation (Home/History/Settings)
- **HomeView**: Two-button interface for voice/text symptom input
- **NewSymptomView**: Comprehensive symptom recording with attachments
- **TranscriptionSheetView**: Real-time voice transcription feedback
- **AttachmentPicker**: Photo and document import functionality
- **HistoryView**: Chronological symptom list with search
- **DoctorReportView**: Professional report generation and sharing
- **SettingsView**: App configuration and data management

## 🔄 State Machine Implementation

### Voice Recording Flow
```
IDLE → RECORDING → TRANSCRIBING (0→100%) → READY → AI_SUMMARY → SAVE
```

### Text Input Flow
```
IDLE → EDITING → AI_SUMMARY → TRANSLATE (optional) → SAVE
```

### Attachment Flow
```
PICKING → IMPORTING → ATTACHED → REMOVE (via ❌ button)
```

## 📂 Project Structure

```
Symi/
├── App/
│   ├── SymiApp.swift           # Main app entry point
│   └── DIContainer.swift       # Dependency injection container
├── Core/
│   ├── Models/                 # Data models
│   │   ├── SymptomEntry.swift
│   │   ├── Attachment.swift
│   │   ├── Language.swift
│   │   ├── TranscriptionState.swift
│   │   └── DoctorReport.swift
│   └── Services/              # Business logic
│       ├── TranscriptionService.swift
│       ├── AISummaryService.swift
│       ├── TranslationService.swift
│       ├── ReportBuilder.swift
│       └── Storage/
│           ├── StorageProtocol.swift
│           ├── LocalStore.swift
│           └── CloudStore.swift
├── Features/                  # UI Features
│   ├── Main/
│   │   ├── MainView.swift
│   │   └── MainViewModel.swift
│   ├── NewSymptom/
│   │   ├── NewSymptomView.swift
│   │   ├── NewSymptomViewModel.swift
│   │   ├── TranscriptionSheetView.swift
│   │   └── AttachmentPicker.swift
│   ├── History/
│   │   ├── HistoryView.swift
│   │   └── HistoryViewModel.swift
│   ├── Report/
│   │   ├── DoctorReportView.swift
│   │   └── DoctorReportViewModel.swift
│   └── Settings/
│       ├── SettingsView.swift
│       └── SettingsViewModel.swift
├── Resources/
└── README.md
```

## 🚀 How to Run

### Manual Xcode Setup (Recommended)
1. Open Xcode
2. Create a new iOS project:
   - Choose "App" template
   - Product Name: "Symi"
   - Interface: SwiftUI
   - Language: Swift
   - Deployment Target: iOS 16.0+
3. Replace the generated files with the source code from this directory
4. Add required permissions to Info.plist:
   ```xml
   <key>NSMicrophoneUsageDescription</key>
   <string>Symi needs microphone access to record your voice descriptions of symptoms.</string>
   ```
5. Build and run on iOS Simulator

### Command Line Build (Alternative)
```bash
# Navigate to project directory
cd /Users/yvoonezhan/Symi

# Create Xcode project manually or use the provided source files
# Then build with:
xcodebuild -scheme Symi -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build
```

## 🧪 Testing Strategy

### Phase 1 ✅ Completed
- [x] Project structure created
- [x] Basic navigation implemented
- [x] All core models defined
- [x] Mock services implemented
- [x] UI views structured

### Phase 2-7 Roadmap
- **Phase 2**: MainView navigation testing
- **Phase 3**: Voice recording and transcription
- **Phase 4**: Text input and AI summary
- **Phase 5**: Attachments and translation
- **Phase 6**: History and report generation
- **Phase 7**: Settings and persistence

## 🔧 Technical Details

### Tech Stack
- **Language**: Swift 5
- **Framework**: SwiftUI
- **Architecture**: MVVM
- **Min iOS Version**: 16.0+
- **State Management**: Combine + @Published properties
- **Storage**: Local JSON + FileManager
- **Audio**: AVFoundation for voice recording

### Mock Service Behavior
- **Transcription**: Always returns "Mock transcription text" after 0.6s
- **AI Summary**: Returns template summary with user input after 1.0s  
- **Translation**: Appends "(translated to [language])" after 0.3s
- **Storage**: All data persists locally in Application Support/Symi/

### MCP Integration Points
- Bottom sheet state management
- AI button enable/disable logic
- Attachment loading indicators
- Translation dropdown functionality
- Progress tracking for async operations

## 🔄 Next Steps

1. **Run in Simulator**: Test basic navigation between tabs
2. **Voice Flow**: Implement actual AVAudioRecorder integration
3. **Text Flow**: Verify text input and AI summary workflow
4. **Attachments**: Test image/document picker integration
5. **Translation**: Validate language switching functionality
6. **History**: Test search/filter and report generation
7. **Settings**: Verify data persistence and deletion

## 🎯 Design Guidelines

The app follows the provided Figma design specifications:
- Clean, minimal interface with blue accent color
- Two prominent buttons for voice/text input
- Bottom sheet pattern for additional options
- Professional report formatting for medical use
- Accessible icons and clear visual hierarchy

## 📝 Notes

- All services are currently mocked for development
- Real API integration points are clearly marked with TODO comments
- Cloud storage is stubbed but ready for implementation
- Microphone permissions are configured for voice recording
- The app supports offline-first architecture with local persistence

---

**Status**: Phase 1 Complete ✅  
**Next**: Test initial app navigation in iOS Simulator