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

### Step 1 - Design tokens (colours, type, spacing) - done, committed
Files: `Core/Design/Theme.swift` (colours), `Core/Design/Typography.swift` (new, replaces `Fonts.swift`), `Core/Design/Spacing.swift` (new), four screen files renamed to the new names, font files and `Info.plist` font entry removed.
- Test: app builds. Roles tab lists the role in light and dark mode. Text uses the system font and rounded titles. Turn on a larger text size in Settings, Display and Text Size, and check text grows.
- Commit: `refactor: Ascent design tokens for colour, type and spacing`

### Step 2 - App shell: five tabs - done, committed
Files: `App/MainTabView.swift` (five tabs: Today, Explore, Path, Tools, You), `App/Route.swift` (typed navigation destinations), placeholder screens for each tab.
- Test: five tabs with the spec's SF Symbols. Each tab opens its placeholder.

### Step 3 - Shared components - done, committed
Files under `Shared/Components/`: `CJButtonStyle` (primary, secondary, tinted), `CJChip`, `CJProgressRing`, `CJStepRail`, `CJSectionHeader`, `CJSourceChip`, `CJCard`. Plus one new radius in `Spacing.swift`.
- Test: each component's Canvas preview shows light and dark and looks right. Steps in `LEARN.md`.

### Step 4 - Content data - done, committed
Files: web repo `scripts/build-ios-content.ts` (writes `Resources/Data/content.json`). iOS: `Core/Models/` (`Resource`, `Domain`, `Skill`, `Stage`, `Role`, `ContentFile`), `Core/Data/ContentStore.swift`. Removed `RoleLoader.swift` and the old `roles.json`.
- Test: the script prints 10 domains, 26 roles, 99 skills, 361 links. The Explore tab lists 26 roles. Steps in `LEARN.md`.
- Unit tests are not set up yet. Adding a test target is a separate small step, so the checks run in the build script for now.

### Step 5 - Explore - done, committed
Roles grouped by domain, with search. Files: `Core/Logic/RoleSearch.swift`, `Features/Explore/ExploreScreen.swift`. Removed `Features/Roles/RolesScreen.swift`. Steps in `LEARN.md`.
### Step 6 - Role page - done (redesigned, hero updated)
Taste test, stages, skills, day in the life, tools, interviews, AI impact, market notes with sources, nearby roles. "Make this my path" waits for step 8. Files: `Features/Roles/RoleDetailScreen.swift`, `StageCard.swift`, `Core/Models/Role.swift`, and the taste test in the web repo's build script. Steps in `LEARN.md`.
### Step 7 - Skill page and progress - done, committed
Brief, analogy, checklist (learning topics), "Mark skill done", resources. Saved with SwiftData, so it survives a relaunch. Files: `Core/Models/SkillProgress.swift`, `Features/Skill/SkillScreen.swift`, `Features/Skill/SkillChipLinks.swift`, and small edits to the role pages and `MyApp.swift`. Steps in `LEARN.md`.
### Step 8 - Today and My Path - done, committed
"Make this my path" on the role page, Today (next skill, streak, stage progress), Path (whole route with states). Files: `Core/Models/PathSelection.swift`, `Core/Logic/PathProgress.swift`, `Core/Logic/StreakRules.swift`, `Features/Today/TodayScreen.swift`, `Features/Path/PathScreen.swift`, `Features/Path/NextSkillCard.swift`. Removed `Features/MyPath/MyPathScreen.swift`. Rules checked with a test program; steps in `LEARN.md`.
### Step 9 - Compass quiz - ready to test
Eight questions, three results with "Because you" reasons, "Make my path". Ranking matches the website, checked on four answer sets including a tie. Files: `Core/Models/Compass.swift`, `Core/Logic/CompassScoring.swift`, `Core/Data/PathChooser.swift`, `Features/Compass/CompassScreen.swift`, `Features/Tools/ToolsScreen.swift`, and the quiz data in the web repo's build script. Steps in `LEARN.md`.
### Step 10 - Compare, Pay, Switch
- 10a Pay by role (Swift Charts, sourced figures): ready to test. Files: `Core/Models/Pay.swift`, `Features/Pay/PayScreen.swift`, and pay data in the web repo's build script.
- 10b Compare roles and Switch careers: ready to test. Switch matches and job-ready figures checked against the website. Files: `Core/Models/Switch.swift`, `Core/Logic/SwitchLogic.swift`, `Core/Logic/CompareLogic.swift`, `Features/Compare/CompareScreen.swift`, `Features/Switch/SwitchScreen.swift`.
### Step 11 - Job post checker - ready to test
Paste a post, see skills found, roles it looks like, skills to learn in order. The matcher is a port of the website's rules and gives the same results on its three example posts. Files: `Core/Logic/JobPostAnalyser.swift`, `Core/Models/JobGap.swift`, `Features/JobPost/JobPostScreen.swift`, and the matching data in the web repo's build script. Steps in `LEARN.md`.
### Step 12 - Interview prep, System design, Glossary, Guides
- 12a Interview prep (5 topics, 70 questions, ready marks saved on the phone): ready to test. Files: `Core/Models/Interview.swift`, `Core/Models/InterviewReady.swift`, `Features/Interview/InterviewScreen.swift`, `Features/Interview/InterviewPracticeScreen.swift`, and topics in the web repo's build script. Website visual explainers come later.
- 12b Glossary and flashcards (46 terms, search, flashcards that save known terms): ready to test. Files: `Core/Models/GlossaryTerm.swift`, `Features/Glossary/GlossaryScreen.swift`, `Features/Glossary/FlashcardsScreen.swift`.
- 12c Guides and blog (13 posts, Markdown reader): ready to test. Files: `Core/Models/BlogPost.swift`, `Core/Logic/MarkdownBlocks.swift`, `Features/Guides/GuidesScreen.swift`.
- 12d System design (8 paths, 71 articles, glossary): ready to test. Files: `Core/Models/SystemDesign.swift`, `Features/SystemDesign/SystemDesignScreen.swift`.
- Step 12 is done once these pass.
- Step 13 Ask CJ (streaming, sources, guest limit): ready to test. The website's chat route needed no change. Files: `Core/Network/CJAPI.swift`, `Core/Network/ChatService.swift`, `Core/Logic/SSEParser.swift`, `Features/Ask/AskModel.swift`, `Features/Ask/AskScreen.swift`. Signed-in token is sent when present; sign-in comes in step 14.
### Step 13 - Ask CJ
Streaming answers with source chips. Needs decision D6.
### Step 14 - You, sign-in and sync
Settings, appearance, sign in, account deletion, sync.
### Step 15 - Optional iOS extras
Widgets, App Intents (Siri), Share extension, Spotlight.
### Step 16 - Release
Accessibility pass, privacy manifest, app icon, real bundle ID, TestFlight.
