# Decisions

Each decision has a current value, the reason for it, and where to change it. Change a value here and in the place listed, then note the change in the table at the bottom.

| # | Decision | Current value | Why | Where to change | Revisit |
|---|---|---|---|---|---|
| D1 | Minimum iOS version | **18.0** | Covers most active iPhones. Gives us the Tab API, SwiftData and zoom transitions. | Xcode: target CodeJourney, General, Minimum Deployments. Stored in `CodeJourney.xcodeproj/project.xcproj` as `IPHONEOS_DEPLOYMENT_TARGET`. | Each September, when the new iOS ships. Raise it only when a feature we need requires it. |
| D2 | Swift language mode | **Swift 5** (`SWIFT_VERSION` 5.0) | Fewer concurrency errors while we learn. The code already uses `async/await` and `@Observable`, so the move is small. | Xcode: target, Build Settings, Swift Language Version. | After TestFlight is working, when all steps are merged. |
| D3 | Where colours live | **Swift code** (`Core/Design/Theme.swift`) | One readable file, easy to explain. | Edit the hex values in `Theme.swift`. To move to the asset catalogue, see the note in `LEARN.md`. | When we need Xcode's colour pickers or high-contrast variants. |
| D4 | Bundle ID | **space.codejourney.app** | Matches the web domain `codejourney.space`, so the app and website share one name. | Xcode: target, Signing and Capabilities. Also register it in the Apple Developer portal before TestFlight. | Before the first App Store submission. Cannot be changed after you publish. |
| D5 | Content source | **Generated JSON** built from the web repo's `content/` folder, bundled into the app | Works offline. Web and app read the same source, so they cannot drift apart. | Step 4 adds `scripts/build-ios-content.ts` in the web repo. Output path is set in that script. | When the content is large enough to need downloading, or when you want updates without an app release. |
| D6 | Sign-in | **Sign in with Apple first, then email one-time code**, both through Supabase Auth. No passwords in the app. | Apple requires Sign in with Apple when another login is offered. One-time codes avoid storing passwords. | Step 14. The Supabase client is set up there. | After the first TestFlight feedback. |
| D7 | Chat (Ask CJ) authentication | **Send the signed-in user's Supabase session token** to `/api/chat`. Guests use the free-question limit. | Reuses the login we already have. Keeps the Gemini key on the server. | Step 13. The web route must accept the token from the app (open item A5 in the spec). | If the web route changes its auth. |

## Change log

| Date | Decision | From | To | Reason |
|---|---|---|---|---|
| 24 Nov 2026 | D1 | 27.2 | 18.0 | Wider reach, and the spec's features need 18 at most. |
| 24 Nov 2026 | D4 | `devplaceholder...` | `space.codejourney.app` | Real ID to match the domain. |
| 24 Nov 2026 | D2, D3, D5, D6, D7 | open | recommended value | Set to the best recommendation so work can continue. |
