# Learn as we build

Each step adds a section here: what changed, what each file does, and why it is written that way.

---

## Step 1 - Design tokens (colours, type, spacing)

### The idea
A **token** is a named value. Instead of writing `Color(red: 0.29, ...)` on every screen, we write `CJColor.accent`. If the brand colour changes, we edit one line, and every screen follows. The same goes for type and spacing.

### Files

**`CodeJourney/Core/Design/Theme.swift`** - colours
- `enum CJColor` holds every colour. An `enum` with no cases works as a namespace: you can't make one, you only read its `static` values.
- Each colour uses `Color(light:dark:)`. That is a helper defined lower in the same file. It returns one colour in light mode and another in dark mode, so the app switches automatically when the phone does.
- `UIColor(hex:)` turns `"#4A46D6"` into a colour. It reads the hex digits as three numbers: red, green and blue, each from 0 to 255.
- `accentSoft` and `hairline` use `var` with `opacity`, so they follow the base colour in both modes.

**`CodeJourney/Core/Design/Typography.swift`** - text styles (replaces `Fonts.swift`)
- Every style uses a built-in **Dynamic Type** style such as `.body` or `.title2`. When the user changes their text size in Settings, these grow. Fixed sizes such as `size: 17` do not grow, so we avoid them.
- `Font.system(.largeTitle, design: .rounded)` gives the rounded look for titles. Body text stays in the default design, because rounded text is harder to read in long passages.
- `.monospacedDigit()` keeps numbers the same width, so columns of figures line up.

**`CodeJourney/Core/Design/Spacing.swift`** - spacing, corners and layout
- `CJSpace` is the spacing scale: 4, 8, 12, 16, 20, 24, 32, 48. Every gap and padding uses one of these names.
- `CJRadius` holds the corner sizes. Use them with `style: .continuous`. Apple's rounded corners are smoother that way, and it matches the rest of iOS.
- `CJLayout` holds the page margin (20 points) and the button height (52 points). A 52-point button is comfortable to tap, and Apple's guidance is at least 44.

**`CodeJourney/Features/Roles/RoleDetailScreen.swift`, `StageCard.swift`, `RolesScreen.swift`, `CodeJourney/Shared/Components/PlaceholderScreen.swift`**
- These are the four existing screens. They only changed names: old colours and fonts now point to the new tokens, and the numbers became `CJSpace` and `CJRadius` names. Nothing about what they show has changed.

**`CodeJourney/Info.plist`**
- This file holds app settings. The old `UIAppFonts` key told iOS to load the three custom fonts. We removed it because the app no longer uses them.

### Test (you)
1. Press Cmd+R in Xcode and open the Roles tab. The role should list with its stage count.
2. Open the role. The stage cards should show a white surface in light mode.
3. Switch the simulator to dark mode (Settings, Display and Brightness, or Cmd+Shift+A in the simulator). The background should turn near-black and the text light.
4. Open Settings, then Display and Text Size, and set a larger text size. The role titles should grow.

### Commit
```bash
git add -A && git commit -m "refactor: Ascent design tokens for colour, type and spacing"
```

### How to change a colour later
Open `Theme.swift`, find the token, and change its hex value, for example `"#4A46D6"`. Save, and the change shows everywhere on the next build.

---

## Step 2 - App shell: five tabs

### The idea
A **tab bar** is the row of buttons at the bottom of the app. Each tab is a separate area with its own navigation. Ascent has five: Today, Explore, Path, Tools and You.

### Files

**`CodeJourney/App/MainTabView.swift`** - the tab bar
- `TabView` holds the tabs. `Tab("Today", systemImage: "sun.horizon") { ... }` is the newer iOS 18 way to write one tab. The title and the SF Symbol are set together.
- `.tint(CJColor.accent)` colours the selected tab with the Ascent accent.
- Each tab shows one screen. Today and Tools are placeholders for now. Explore shows the role list from before, Path and You keep their current screens.

**`CodeJourney/App/Route.swift`** - where screens can go
- An `enum` lists every screen that can be opened from a list, for example a role or a skill. Later, a list pushes a `Route` value, and one place decides which screen to show.
- Nothing pushes a route yet. We add the cases now, so the navigation shape is fixed before the screens are built.

**`CodeJourney/Features/Today/TodayScreen.swift`** and **`CodeJourney/Features/Tools/ToolsScreen.swift`**
- New placeholder tabs. Each one has its own `NavigationStack`, so later it can push screens without changing the tab bar.
- `#Preview` shows the screen in Xcode's canvas without running the app.

**`RolesScreen.swift`, `MyPathScreen.swift`, `SettingsScreen.swift`** - titles only
- The tab names changed, so the screen titles changed to match: Explore, Path and You. The screens are otherwise unchanged. The You screen gets its real content in step 14.

### Test (you)
1. Press Cmd+R. The bottom bar should show five tabs: Today, Explore, Path, Tools and You, each with a symbol.
2. Tap each tab. Each should show its title at the top and a short message.
3. In Explore, tap a role. The stages should still open.
4. The selected tab should turn the Ascent indigo accent colour (Iris).

### Commit
```bash
git add -A && git commit -m "feat: five-tab app shell for the Ascent design"
```

---

## Step 3 - Shared components

### The idea
A **component** is a small view we write once and reuse everywhere. A chip looks the same on Explore and on Tools, so we build it once. Every component lives in `Shared/Components/`, and each has a `#Preview` so you can see it without running the app.

### Files

**`CJButtonStyle.swift`** - buttons
- A **`ButtonStyle`** decides how a button looks. The button's text and action stay the same. Use it like this: `Button("Continue") { }.buttonStyle(.cjPrimary)`.
- Three kinds: `primary` (filled accent), `secondary` (outlined) and `tinted` (soft accent).
- `CJButtonBody` is a small view inside the same file. A `ButtonStyle` cannot read the environment, but a view can. That is how the button knows it's disabled, and whether Reduce Motion is on. With Reduce Motion, the press animation is skipped.
- `.opacity(isEnabled ? 1 : 0.4)` makes a disabled button look faded.

**`CJChip.swift`** - small labels
- Four tones: neutral, selected, accent and success. The tone picks the colours, so you never type a colour here.
- The icon is optional. An `if let` only adds the icon when one is given.
- Neutral chips have an outline, because a grey fill on the grey background would be hard to see.

**`CJProgressRing.swift`** - a progress circle
- A circle is drawn twice: a grey track, then a coloured arc on top. `trim(from:to:)` shows only part of the circle. `rotationEffect(-90)` starts the arc at the top instead of the right side.
- `clamped` keeps the value between 0 and 1, so a bad number cannot draw an invalid arc.
- The accessibility label and value let VoiceOver read "Progress, 50 percent".

**`CJStepRail.swift`** - the list of steps
- Each step shows its state with a **shape** as well as a colour: a tick for done, a ring with a dot for up next, an outline for not started, a lock for locked. Someone who can't see colour still knows what each step is.
- The line between steps turns green once the step above is done.
- `Item` is a nested struct. Each item has an `id`, which SwiftUI needs to track rows in a list.
- `.accessibilityElement(children: .combine)` makes each row one thing for VoiceOver. It reads the title and the state.

**`CJSectionHeader.swift`** - headings
- The small label above the title is called an **eyebrow**. It's uppercased in code, so the text can be written in normal case.
- `.accessibilityAddTraits(.isHeader)` tells VoiceOver that the text is a heading, so users can jump between headings.

**`CJSourceChip.swift`** - source links
- `Link` opens a web address in Safari. This is a simpler stand-in for the in-app browser in the spec. We can change it later without changing any screen that uses it.
- The label is built from the name and an optional date, for example "PayScale, 7 Jul 2026". Every number in the app should have one of these.

**`CJCard.swift`** - the surface
- `CJCard { ... }` takes any content as a closure. `@ViewBuilder` lets the closure hold several views without a container, the same way a `VStack` does.
- `Content` is a **generic type**: the card works with any content, and Swift works out the type.

**`Core/Design/Spacing.swift`** - one new value
- `CJRadius.button` (14 points) is the button corner. It sits between the chip (10) and the card (16).

### Test (you)
1. Open the Canvas in Xcode (the panel on the right, or Editor, Canvas). Each component file shows a **Light** and a **Dark** preview. Check that each one looks right in both.
2. In `CJButtonStyle.swift`, the Disabled button should look faded.
3. In `CJStepRail.swift`, the done step has a green tick, the current step has an indigo ring, and the locked step has a lock.
4. In `CJProgressRing.swift`, the 50% ring is half filled and the 100% ring is green.
5. Optional: if you use the simulator, turn on Reduce Motion (Settings, Accessibility, Motion). Press a button. It should change colour without bouncing.

### Commit
```bash
git add -A && git commit -m "feat: shared Ascent components (buttons, chips, rings, step rail, cards)"
```

---

## Step 4 - Content data

### The idea
The app must work offline, and the website already holds all the content as YAML and Markdown. We write a **build script** in the web repo. It reads that content and writes one JSON file, `content.json`, into the app. The app only reads the JSON, so the app and the website always show the same facts.

### Files

**Web repo: `scripts/build-ios-content.ts`** - the build script
- Run it from the web repo: `node scripts/build-ios-content.ts`. Add `--out <path>` to write somewhere else. By default it writes to `../Code-Journey-iOS/CodeJourney/Resources/Data/content.json`.
- It uses the same parsers as the website (`gray-matter` for Markdown frontmatter, `yaml` for YAML, `zod` for shapes), so a bad value fails here, not on the phone.
- **Cross-checks:** every stage must name a skill that exists, every adjacent role must exist, and every skill needs an analogy. Any problem stops the script and lists every problem at once.
- Prints the counts. Expected: 10 domains, 26 roles, 99 skills, 361 unique links. 361 is the number on the website footer.

**`CodeJourney/Core/Models/Resource.swift`** - a link to learn from
- `Codable` lets the type read and write JSON. Each property has the same name as its JSON key, so no mapping is needed.
- Nested `enum Kind` and `enum Cost` turn text such as `"docs"` into a checked value. A typo in the data becomes a decode error, not a wrong label.
- `url` is a `URL`, not a `String`, so a bad address is caught when the data loads.
- `id` is the URL, because each link is unique.

**`Domain.swift`, `Skill.swift`, `Stage.swift`, `Role.swift`** - the content shapes
- They mirror the JSON. Optional fields (`hours`, `weeks`, `analogy`) are `String?`. A missing value is `nil`, not an empty string.
- `Role` has nested types (`SkillPriorities`, `Interview`, `MarketNote`). Nesting keeps related types together, so `Role.Interview` reads clearly.
- `Stage.skills` holds skill slugs, such as `"git"`. Screens look up the full skill with `ContentStore.skill(slug:)`.

**`ContentFile.swift`** - the whole file
- One type matches the whole JSON file. Only the decoder uses it.

**`CodeJourney/Core/Data/ContentStore.swift`** - the content in memory
- `@Observable` means SwiftUI redraws the screens that read it when it changes.
- It loads the file once, in `init`. If loading fails, `loadError` holds a message and the screens show it.
- It keeps two dictionaries (`skillsBySlug`, `rolesBySlug`), so looking up a skill by slug is quick.
- `private(set)` means screens can read the lists but not change them.
- `Dictionary(uniqueKeysWithValues:)` stops the app if two items share a slug. That cannot happen with the build script's file names, so it is a safe check.

**`CodeJourney/App/MyApp.swift`** - create the store once
- `@State` keeps the store alive for the life of the app. `.environment(content)` gives it to every screen. A screen reads it with `@Environment(ContentStore.self)`.

**`Features/Roles/RolesScreen.swift`** - reads the store
- It no longer loads a file itself. It shows `content.roles`, and the loading error if there is one.

**`Features/Roles/StageCard.swift`, `RoleDetailScreen.swift`** - field names
- `skillIDs` is now `skills`. The role preview uses the real bundled data instead of a made-up role.

**Removed:** `RoleLoader.swift` and the old `roles.json` with one role. The store replaces both.

### Test (you)
1. Run the build script in the web repo: `node scripts/build-ios-content.ts`. It should print 10 domains, 26 roles, 99 skills and 361 links.
2. In Xcode, Cmd+R. The Explore tab should list 26 roles, each with its number of stages.
3. Tap a role. Its stages should show, with their skills, projects and "done when".
4. Optional: break the content on purpose (for example, rename a skill in a stage) and run the script. It should list the broken reference and stop.

### Commit (iOS repo)
```bash
git add -A && git commit -m "feat: bundled content.json from the website's content, with typed models"
```

### Commit (web repo)
```bash
git add scripts/build-ios-content.ts && git commit -m "feat: script that builds the iOS app's content file"
```

---

## Step 5 - Explore: roles by domain, with search

### The idea
Explore is where people browse. Roles sit under their domain (Web, Data, AI and so on), and a search box filters them. We keep the search logic in plain Swift, separate from the screen. That makes it easy to test, and the screen stays simple.

### Files

**`CodeJourney/Core/Logic/RoleSearch.swift`** - the search and grouping logic
- `DomainGroup` is one heading and its roles. It is `Identifiable`, so `ForEach` can show it.
- `RoleSearch.matches` splits the query into words and checks that **every** word appears somewhere in the role's title, aliases or summary. Typing "data engineer" finds roles that contain both words.
- `normalised` lowers the case, removes accents and squashes extra spaces. `folding(options:)` does the accent part, so "Dáta" and "data" match.
- `RoleSearch.groups` keeps the order of the domains from the content file. A domain with no matches disappears, so the list never shows empty headings. Any role whose domain is unknown goes under "Other".
- There is no SwiftUI in this file, so the same logic can run in a test later.

**`CodeJourney/Features/Explore/ExploreScreen.swift`** - the screen
- `@State private var query` holds the search text. When it changes, SwiftUI redraws the screen.
- `.searchable` adds the search field at the top. It is on the navigation stack, so it sits under the title.
- `ContentUnavailableView.search(text:)` is Apple's standard "no results" view. It names what the person searched for.
- `NavigationLink(value: role)` pushes the role by value, and `.navigationDestination(for: Role.self)` says which screen to show. That is the Apple-recommended way, and it sets up the typed routes from step 2.
- `Section` with a `header:` gives each domain its heading.

**Removed:** `Features/Roles/RolesScreen.swift`. Explore replaces it, and `MainTabView` now shows `ExploreScreen`.

### Test (you)
1. Cmd+R. Explore should show headings for each domain (Web, Mobile, Data, and so on), with their roles under them.
2. Type `data` in the search box. Only roles with "data" in their text should stay. The headings with no matches should disappear.
3. Type `IOS` in capitals. iOS Engineer should still appear.
4. Type `zzzz`. The screen should say there are no results for that search.
5. Clear the search. All 26 roles should return.
6. Tap a role. Its stages should open, and Back should return you to the same search.

### Commit
```bash
git add -A && git commit -m "feat: Explore lists roles by domain with search"
```
