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

---

## Step 6 - The role page

### The idea
The role page answers "is this for me, and what do I do?". It opens with a 60-minute taste test, so people try the work before committing to a route. Then it shows the route, the skills, the daily work, interviews, and the market facts with their sources.

### Files

**Web repo: `scripts/build-ios-content.ts`** - the taste test
- Reads `content/taste-tests.yaml` and adds one `tasteTest` to each role. The script fails if a role has no taste test.

**`CodeJourney/Core/Models/Role.swift`** - the taste test type
- `Role.TasteTest` is nested inside `Role`, because it only means something for a role.
- `tasteTest` is optional. A role page still works if the field is missing.

**`CodeJourney/Features/Roles/RoleDetailScreen.swift`** - the page
- The page is one `ScrollView` with a `VStack` of sections. Each section is a computed property, such as `skillsSection`. Reading the page top to bottom is the same as reading the code top to bottom.
- `CJLayout.sideMargin` (20) sets the left and right margin, so it matches every other screen.
- **Chips wrap** with `LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))])`. A row of chips flows onto the next line when it runs out of room. SwiftUI has no built-in "wrap" layout, so a grid does the same job.
- **Skill names** come from `content.skill(slug:)`. The file stores slugs such as `"how-the-internet-works"`, and the screen shows the title. If a slug is missing, the slug is shown instead, so nothing disappears silently.
- **Links** use `Link` for practice resources (they open in Safari) and `NavigationLink(value:)` for nearby roles. Nearby roles push onto the same stack, so Back returns to the page you came from.
- `CJSourceChip` shows each market fact's source, so every number has one.

**`CodeJourney/Features/Roles/StageCard.swift`** - one stage
- The skills now show as a `CJStepRail`, the component from step 3. Every skill starts as "not started". Real progress comes in step 7, when the app stores ticks.
- `CJCard` replaces the card background, so the card style lives in one place.

### What is not here yet
- **"Make this my path"** is in the spec, but it needs somewhere to save the path. That comes with My Path in step 8.

### Test (you)
1. Regenerate content if you haven't: `node scripts/build-ios-content.ts` in the web repo.
2. Explore, then open iOS Engineer. The page should open with the 60-minute taste test, then the stages.
3. Each stage shows its skills as a list with a small circle beside each one. The skill names should be readable words, not slugs such as `command-line`.
4. Scroll down. Skills should appear in three groups (must, should, nice). Tools appear as chips.
5. Tap a practice link under Interviews. It should open in Safari.
6. Tap a nearby role. It should open that role's page, and Back should return you to iOS Engineer.
7. Check the bottom line, "Last checked", shows a date.

### Commit
```bash
git add -A && git commit -m "feat: role page with taste test, stages, skills, interviews and market"
```

---

## Step 6 (redesign) - The role page as a climb

Two changes: the Explore rows show only the role name, and the role page is now a single scrolling story instead of a list of boxes.

### The idea
The role is a **climb**. The hero draws the route as a line with numbered camps. The stages are cards you swipe through, one camp at a time. Sections rise into place as you scroll. Every effect uses a built-in SwiftUI API, so the page stays smooth.

### Files

**`Shared/Components/CJChipWrap.swift`** - a reusable chip grid
- Wraps any list of chips onto new lines. Skills, tools and stage skills all use it, so the grid logic lives in one file.

**`Features/Roles/RoleHero.swift`** - the top of the page
- `ClimbGraphic` draws the route. `ClimbLine` is a `Shape`, and `.trim(from:to:)` draws part of it. Animating `progress` from 0 to 1 makes the line draw itself.
- Each camp is positioned with `.position`. A camp lights up when the line reaches it.
- With Reduce Motion on, the line appears at once.

**`Features/Roles/TasteTestCard.swift`** - the taste test
- A large accent card. The "60" uses the rounded number style, and the two "if" boxes sit on top of the accent.

**`Features/Roles/StageDeck.swift`** - stages you swipe through
- `ScrollView(.horizontal)` with `.scrollTargetBehavior(.viewAligned)` makes each card snap into place.
- `.containerRelativeFrame` makes each card 84% of the screen width, so the next card peeks in at the edge.
- `.scrollPosition(id:)` tracks which card is in view. The dots and the haptic tap both follow it.
- `.scrollTransition` shrinks and fades the cards at the edges.

**`Features/Roles/StageCard.swift`** - one camp
- A large numeral, the stage name, skills, project and "done when". The numeral is the one place we use a fixed font size, because it is decoration, not reading text. `minimumScaleFactor` keeps it on screen at large text sizes.

**`Features/Roles/RoleDetailScreen.swift`** - the page
- Every section uses `.revealOnScroll()`, a small extension. It applies `.scrollTransition` to fade and lift a section as it enters the screen.
- The nearby roles scroll sideways as cards. Each card is a `NavigationLink`, so it opens that role's page.

**`Features/Explore/ExploreScreen.swift`** - the rows
- Each row shows only the role name. The "N stages" line is gone.

### Test (you)
1. Explore: each row shows only the role name.
2. Open iOS Engineer. The climb line should draw itself, and the camps should light up in turn.
3. The taste test sits in a filled accent card below the hero.
4. Swipe the stage cards sideways. Each card should snap into place, the dots should follow, and you should feel a light tap on each change.
5. Scroll down. Each section should fade and rise as it enters the screen.
6. Tap a nearby card. It should open that role, and Back should return you.
7. Optional: turn on Reduce Motion (Settings, Accessibility, Motion). The line should appear at once and nothing should slide.

### Commit
```bash
git add -A && git commit -m "feat: redesign role page as a climb with swipeable stages"
```

### Hero update: the mountain scene
The first climb line looked plain, so `RoleHero.swift` now draws a scene instead:
- **`RoleIllustration`** layers a gradient sky, a sun, two mountain ranges, a dotted route and one numbered camp per stage. A flag marks the peak.
- **`MountainShape`** is a `Shape` made from peak points. The points are fractions (0 to 1) of the box, so the mountains scale to any screen.
- **`RouteShape`** joins the camps with curves (`addQuadCurve`), so the route bends like a trail.
- Colours come from the theme (`CJColor.onAccent` for the drawing). The scene works in light and dark mode.
- The route still draws itself on open, and Reduce Motion turns that off.

### Test (you)
1. Open iOS Engineer. A mountain scene should fill the top of the page, with the route and camps climbing to a flag.
2. Open another role, such as Backend Engineer. The scene should fit the screen width and the camps should match its stage count.
3. Switch to dark mode. The scene should stay readable.

---

## Step 7 - Skill page and progress

### The idea
A skill page is where people learn and track it. They read the brief, tick the checklist, and mark the skill done. The ticks have to survive closing the app, so we store them on the phone with **SwiftData**, Apple's database for app data.

### Files

**`CodeJourney/Core/Models/SkillProgress.swift`** - what is saved
- `@Model` tells SwiftData to save this class. Each property is stored automatically.
- `@Attribute(.unique)` on `skillSlug` means a skill can only have one record. That lets us find a skill's progress with one lookup.
- `completedAt` is a `Date?`. It is `nil` until the person marks the skill done, so "done" and "when" are one value, not two that can disagree.
- Records are created only when the person first changes something. A skill never touched has no record, so the database stays small.

**`CodeJourney/App/MyApp.swift`** - the database
- `.modelContainer(for: SkillProgress.self)` opens the database and makes it available to every screen. `import SwiftData` is needed for that call.

**`CodeJourney/Features/Skill/SkillScreen.swift`** - the page
- `@Query` reads the saved records, and its filter only matches this skill. The filter is set in `init`, because it needs the skill's slug, and the query is built before the view appears.
- `recordForChange()` returns the existing record, or creates one. Every tick and every "done" goes through it.
- The checklist is the skill's **learning topics** from the content file. Each topic is one tick. The content does not yet have a separate "done when" list per skill, so this is the closest honest checklist. We can add real per-skill checklists to the content later.
- `sensoryFeedback` gives a light tap on each tick and a success tap on "done".
- `safeAreaInset(edge: .bottom)` keeps the "Mark skill done" button in thumb reach, above the bottom of the screen.
- The "Learn it" links open in Safari. Free resources get a green cost chip.

**`CodeJourney/Features/Skill/SkillChipLinks.swift`** - tappable skills
- Skill chips on the stage cards and role pages are now links. Tapping one opens that skill. Slugs without content are left out, so a tap never opens an empty page.

**`Features/Explore/ExploreScreen.swift`** - the route to a skill
- `.navigationDestination(for: Skill.self)` tells the stack how to show a skill when a link pushes one. The same rule covers skills opened from role pages, because they share the stack.

**`Features/Roles/StageCard.swift`, `RoleDetailScreen.swift`** - small changes
- Both use `SkillChipLinks` in place of plain chips. `StageCard` no longer needs the content store.

### Not yet
- The stage rails on the role page still show every skill as "not started". Reading progress back into the role page comes in step 8, with My Path.

### Test (you)
1. Open a role, then tap a skill chip. The skill page should open with its brief, analogy and checklist.
2. Tick two checklist items. The count should update, and you should feel a light tap on each.
3. Tap "Mark skill done". The button should change to "Mark as not done", a "Done" chip should appear, and you should feel a success tap.
4. Close the app completely (swipe it away from the app switcher), reopen it, and open the same skill. The ticks and "done" should still be there.
5. Tap a "Learn it" link. It should open in Safari.
6. Optional: mark a skill done, then tap "Mark as not done". It should go back to not done.

### Commit
```bash
git add -A && git commit -m "feat: skill page with checklist, done state and saved progress"
```
