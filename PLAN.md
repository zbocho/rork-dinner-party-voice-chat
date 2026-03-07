# Dinner Party — Developer Guide

## STATUS: The app is complete. Do NOT rewrite it.

All source files exist, the codebase has been cleaned up, and the app is ready to build. Your job is to **read the existing code**, understand how it fits together, and make small targeted fixes if needed. Do not scaffold a new project, do not create new files unless absolutely necessary, and do not restructure the architecture.

---

## Architecture

- **SwiftUI + SwiftData** iOS app (iOS 17+)
- Single-conversation voice message interface — users record and play back voice messages
- AI-generated conversation summaries via Rork toolkit API (`toolkit.rork.com/agent/chat`)
- Includes an **iMessage extension** for in-conversation access
- Local-only storage (no cloud sync between users)

## File Inventory

Every file is listed below. If you think something is missing, **check this list first** — it's probably already there.

### App Entry & Config
| File | Purpose |
|------|---------|
| `ios/DinnerParty/DinnerPartyApp.swift` | App entry point, sets up SwiftData ModelContainer with in-memory fallback |
| `ios/DinnerParty/ContentView.swift` | Root view, just renders `ConversationView` |
| `ios/DinnerParty/Config.swift` | Build-time config constants (toolkit URL, participant names) |

### Models (SwiftData)
| File | Purpose |
|------|---------|
| `ios/DinnerParty/Models/Conversation.swift` | `@Model` class — single conversation with participant name, summary, timestamps |
| `ios/DinnerParty/Models/VoiceMessage.swift` | `@Model` class — individual voice message with audio file URL, duration, sender |

### Services
| File | Purpose |
|------|---------|
| `ios/DinnerParty/Services/AudioRecorderService.swift` | `@Observable` — wraps AVAudioRecorder, manages recording state/duration |
| `ios/DinnerParty/Services/AudioPlayerService.swift` | `@Observable` — wraps AVAudioPlayer, manages playback state/progress |
| `ios/DinnerParty/Services/SummaryService.swift` | Posts conversation data to Rork toolkit API, returns AI summary text |

### ViewModels
| File | Purpose |
|------|---------|
| `ios/DinnerParty/ViewModels/ConversationViewModel.swift` | Central state management — loads/creates conversation, handles record/stop/send/summary flow |

### Views
| File | Purpose |
|------|---------|
| `ios/DinnerParty/Views/ConversationView.swift` | Main chat UI — message list, record button, recording overlay |
| `ios/DinnerParty/Views/VoiceMessageRow.swift` | Single message bubble with play/pause and progress bar |
| `ios/DinnerParty/Views/RecordingOverlay.swift` | Full-screen overlay during recording (timer, stop, cancel, dismiss X) |
| `ios/DinnerParty/Views/RecordButton.swift` | Animated mic/stop button with pulse effect |
| `ios/DinnerParty/Views/EmptyStateView.swift` | Placeholder shown when no messages exist |
| `ios/DinnerParty/Views/SummaryCardView.swift` | Displays AI-generated conversation summary |

### Utilities
| File | Purpose |
|------|---------|
| `ios/DinnerParty/Utilities/Theme.swift` | Color palette + shared `TimeInterval.formattedMinsSecs` extension |

### iMessage Extension
| File | Purpose |
|------|---------|
| `ios/DinnerPartyMessages MessagesExtension/MessagesViewController.swift` | iMessage extension entry point, hosts SwiftUI view |
| `ios/DinnerPartyMessages MessagesExtension/MessagesView.swift` | SwiftUI wrapper that renders `ConversationView` inside iMessage |
| `ios/DinnerPartyMessages MessagesExtension/Info.plist` | Extension configuration |

### Tests (placeholders)
| File | Purpose |
|------|---------|
| `ios/DinnerPartyTests/DinnerPartyTests.swift` | Placeholder unit test file |
| `ios/DinnerPartyUITests/DinnerPartyUITests.swift` | Placeholder UI test file |
| `ios/DinnerPartyUITests/DinnerPartyUITestsLaunchTests.swift` | Placeholder launch test |

### Project Files
| File | Purpose |
|------|---------|
| `ios/DinnerParty.xcodeproj/project.pbxproj` | Xcode project — all targets, build settings, file references |
| `ios/DinnerParty.xcworkspace/` | Workspace wrapper for build runner discovery |
| `rork.json` | Rork platform config — declares the iOS app at `ios/` path |

---

## Known Issues & Fixes

### Recording UI on simulator
The recording screen appears but the timer stays at 0:00 and the stop button does nothing. This happens because on the cloud simulator there's no microphone, so recording silently fails but the overlay gets stuck.

**Fixes applied**:
- Show the recording overlay only when recording actually starts successfully
- If recording fails (e.g. no microphone permission), show a brief alert explaining the issue instead of a stuck overlay
- Add a dismiss/close button to the recording overlay so it can never get permanently stuck
- Make the stop button always dismiss the overlay even if the recorder isn't actively recording (safety fallback)
- On the simulator, show a friendly message: "Install this app on your device via the Rork App to record audio"

---

## What Might Need Wiring

These are the only things that may need attention:

1. **`Config.EXPO_PUBLIC_TOOLKIT_URL`** is empty string — the app falls back to `https://toolkit.rork.com` at runtime, which is correct for the Rork platform. Only set this if you need to point to a different backend.

2. **Code signing / provisioning** — The Xcode project needs a valid team ID and provisioning profile for device builds and TestFlight. This is set in the Xcode project build settings, not in source code.

3. **Microphone permission** — `NSMicrophoneUsageDescription` should be in the app's Info.plist (check Xcode project settings under the target's Info tab). The code already handles permission denial gracefully.

4. **iMessage extension** — Has its own target in the Xcode project. Make sure both the main app and the extension share the same App Group if you need shared data access.

---

## What NOT To Do

- **Do not create a new Xcode project.** The `.xcodeproj` already exists with all targets configured.
- **Do not rewrite files from scratch.** Every service, view, and model is implemented and has been cleaned up.
- **Do not add new frameworks or dependencies.** The app uses only Apple frameworks (SwiftUI, SwiftData, AVFoundation).
- **Do not restructure the file layout.** The current organization (Models/Services/ViewModels/Views/Utilities) is standard and works.
- **Read the code first.** If something seems missing, it probably isn't — check the file inventory above.
