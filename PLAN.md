# Fix broken recording UI — timer and stop button

**Problem**: The recording screen appears but the timer stays at 0:00 and the stop button does nothing. This happens because on the cloud simulator there's no microphone, so recording silently fails but the overlay gets stuck.

**Fixes**:
- Show the recording overlay only when recording actually starts successfully
- If recording fails (e.g. no microphone permission), show a brief alert explaining the issue instead of a stuck overlay
- Add a dismiss/close button to the recording overlay so it can never get permanently stuck
- Make the stop button always dismiss the overlay even if the recorder isn't actively recording (safety fallback)
- On the simulator, show a friendly message: "Install this app on your device via the Rork App to record audio"