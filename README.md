# NOKSHI AI — iOS Starter

This is a **native iOS SwiftUI starter project source**, not a signed `.ipa`.

## Included
- Dark neon SwiftUI interface
- Text chat interface with a local demo response
- Tap-to-speak using iOS Speech framework (requires microphone/speech permission)
- Spoken replies using iOS text-to-speech
- Basic safe app-opening shortcuts for YouTube, Facebook, and Telegram where installed
- A simple bedtime reminder message

## Important limitations
- This starter does not include a cloud AI model. The chat response is a local demo placeholder.
- iOS does not let ordinary third-party apps continuously listen for a wake word like “Nokshi” while suspended.
- An app cannot freely control every other app or perform arbitrary actions in them. App-opening support depends on URL schemes and iOS restrictions.
- Creating an installable `.ipa` requires building and code-signing with an Apple-supported toolchain. A source ZIP is not an installable app.

## Build
1. Open `NokshiAI.xcodeproj` in Xcode on a Mac.
2. Set your own unique Bundle Identifier in Signing & Capabilities.
3. Choose your Apple development team.
4. Add the microphone and speech-recognition usage descriptions if prompted (already listed in `Info.plist`).
5. Build and run on your own device.

This starter is deliberately transparent: no hidden background recording, no bypass of iOS security, and no online services configured.
