# Code Journey iOS - plan to move to the Ascent design

Branch: `feat/ascent-redesign` (cut from `main`).
Spec: `docs/ios/IOS-REDESIGN.md` in the web repo (`Code-Journey-V3`), with the visual board at https://claude.ai/artifact/9oTS6LfAPNhiQgj9t3u4ys.

## How we work

1. I make one step at a time, with only the files that step needs.
2. You build and run in Xcode (Cmd+R) and check the step's "Test" list.
3. You commit with the message I suggest, then push.
4. I explain each file in `docs/LEARN.md`, and in chat.
5. Next step only after you say the step passed.

Nothing is committed or pushed by me unless you ask.

## Decisions (set to the best recommendation, changeable)

All seven decisions are set. Each one has its current value, the reason, and where to change it in `docs/DECISIONS.md`.

- D1 Minimum iOS **18.0** (set in the project file)
- D2 Swift **5** language mode
- D3 Colours in **Swift code** (`Theme.swift`)
- D4 Bundle ID **space.codejourney.app** (set in the project file)
- D5 Content **generated JSON** from the web repo, bundled in the app (step 4)
- D6 Sign-in: **Sign in with Apple, then email one-time code**, through Supabase (step 14)
- D7 Ask CJ: **Supabase session token** sent to `/api/chat` (step 13)

## Steps

Each step lists the files it touches, what you should see, and a commit message.

### Step 0 - Save the current state (you)
Commit the staged work on `main` as the baseline, so the old UI stays in history.
- Commit: `chore: save the old SwiftUI shell before the Ascent redesign`

### Step 1 - Design tokens (colours, type, spacing) - in progress
Files: `Core/Design/Theme.swift` (colours), `Core/Design/Typography.swift` (new, replaces `Fonts.swift`), `Core/Design/Spacing.swift` (new), four screen files renamed to the new names, font files and `Info.plist` font entry removed.
- Test: app builds. Roles tab lists the role in light and dark mode. Text uses the system font and rounded titles. Turn on a larger text size in Settings, Display and Text Size, and check text grows.
- Commit: `refactor: Ascent design tokens for colour, type and spacing`

### Step 2 - App shell: five tabs
Files: `App/MainTabView.swift` (five tabs: Today, Explore, Path, Tools, You), `App/Route.swift` (typed navigation destinations), placeholder screens for each tab.
- Test: five tabs with the spec's SF Symbols. Each tab opens its placeholder.

### Step 3 - Shared components
Files under `Shared/Components/`: `PrimaryButton`, `ChipView`, `ProgressRing`, `StepRail`, `SectionHeader`, `SourceChip`, `Card`.
- Test: each component has a `#Preview` in light, dark and at the largest text size.

### Step 4 - Content data
Files: a Node script in the web repo (`scripts/build-ios-content.ts`) writes `Resources/Data/content.json`. Swift models `Role`, `Stage`, `Skill`, `Resource` and a `ContentStore`.
- Test: a unit test checks 26 roles, 99 skills and 361 resources.

### Step 5 - Explore
Role list grouped by domain, with search.
### Step 6 - Role page
Stages, the 60-minute taste test, interviews, market notes, nearby roles.
### Step 7 - Skill page and progress
Checklist, "Mark skill done", saved with SwiftData, so it survives a relaunch.
### Step 8 - Today and My Path
Next step card, stage progress, streak rules (with unit tests).
### Step 9 - Compass quiz
Eight questions, scoring as pure Swift, tested.
### Step 10 - Compare, Pay, Switch
Pay uses Swift Charts, with the source and date shown for each figure.
### Step 11 - Job post checker
Matcher runs on the phone and is tested against web examples.
### Step 12 - Interview prep, System design, Glossary, Guides
Reader views and flashcards. Stored ticks stay on the device.
### Step 13 - Ask CJ
Streaming answers with source chips. Needs decision D6.
### Step 14 - You, sign-in and sync
Settings, appearance, sign in, account deletion, sync.
### Step 15 - Optional iOS extras
Widgets, App Intents (Siri), Share extension, Spotlight.
### Step 16 - Release
Accessibility pass, privacy manifest, app icon, real bundle ID, TestFlight.
