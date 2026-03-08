# Dinner Party — Developer Guide

## Architecture
SwiftUI + SwiftData, MVVM, iOS 18+. Voice messaging app with AI conversation summaries via Rork toolkit API. Includes an iMessage extension.

## File Inventory

### App Entry
- `DinnerPartyApp.swift` — @main, ModelContainer setup (falls back to in-memory on failure)
- `ContentView.swift` — Root view, hosts ConversationView
- `Config.swift` — Environment variables + participant name constants

### Models
- `Conversation.swift` — @Model: id, participantName, summary, timestamps
- `VoiceMessage.swift` — @Model: id, conversationID, sender info, duration, audio file reference

### Views
- `ConversationView.swift` — Main screen: message list, summary card, record button, recording overlay
- `EmptyStateView.swift` — First-launch empty state with record prompt
- `RecordButton.swift` — Mic/stop button with pulse animation
- `RecordingOverlay.swift` — Full-screen recording UI with dismiss button, stop/send/discard actions
- `VoiceMessageRow.swift` — Individual voice message bubble with playback controls
- `SummaryCardView.swift` — AI summary display card

### ViewModels
- `ConversationViewModel.swift` — Recording, playback, message CRUD, summary generation

### Services
- `AudioRecorderService.swift` — AVAudioRecorder wrapper, @Observable
- `AudioPlayerService.swift` — AVAudioPlayer wrapper, @Observable, 10Hz progress timer
- `SummaryService.swift` — Rork toolkit API client for AI summaries

### Utilities
- `Theme.swift` — Color constants + TimeInterval.formattedMinsSecs extension

### iMessage Extension
- `MessagesViewController.swift` — MSMessagesAppViewController host
- `MessagesView.swift` — SwiftUI bridge for iMessage

## Applied Fixes
- [x] Recording overlay only appears when recording actually starts successfully
- [x] Microphone unavailable alert shown on simulator instead of stuck overlay
- [x] Dismiss (X) button added to recording overlay as safety fallback
- [x] Stop button always dismisses overlay even if recorder isn't active
- [x] ModelContainer falls back to in-memory instead of fatalError on failure
- [x] Playback timer reduced from 20Hz to 10Hz
- [x] Removed redundant recorder polling loop (SwiftUI @Observable handles it)
- [x] Extracted time formatting into TimeInterval.formattedMinsSecs extension
- [x] Moved hardcoded participant names into Config constants
- [x] Summary response parsing: tries JSON decode first, falls back to raw string
- [x] Removed dead code: unused SummaryService structs/methods, empty MessagesViewController stubs, unused MessagesView properties
- [x] Fixed pointless ternary in RecordButton

## Remaining Wiring
- Toolkit URL: Set `EXPO_PUBLIC_TOOLKIT_URL` in project environment variables for AI summaries
- Code signing: Configure for device builds via Rork App
- Microphone: `INFOPLIST_KEY_NSMicrophoneUsageDescription` must be set in project.pbxproj
- iMessage: App Group needed for shared data between host app and extension
