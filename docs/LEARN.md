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

---

## Step 8 - Today and My Path

### The idea
A path is the role you are working towards. Choosing one makes Today show your next skill and Path show the whole route. Progress is never stored as a percentage. It is worked out each time from the skills you have finished, so it can never drift out of date.

### Files

**`Core/Models/PathSelection.swift`** - the chosen role
- One record holds the role's slug. `@Attribute(.unique)` and the rule "one path at a time" are enforced when a new path is chosen: the old record is deleted first.
- Skill progress is **not** deleted when you switch. Skills you finished on one route still count if the new route uses them.

**`Core/Logic/PathProgress.swift`** - the path rules (pure Swift)
- `skillSlugs(in:)` lists every skill on a route once. A skill that appears in two stages is counted once.
- `nextSkill(in:done:)` is the first unfinished skill, in stage order. Today and Path both use this, so they always agree.
- `stages(of:done:)` labels each skill as done, current (the next one) or not started. Only one skill is "current" at a time.
- It takes the set of finished skills as an input, so it does not depend on SwiftData. That is what makes it testable.

**`Core/Logic/StreakRules.swift`** - the streak (pure Swift)
- A day counts when you finished at least one skill. Days are compared by calendar day, so two finishes on one day count once.
- If nothing is finished yet today, the streak can still continue from yesterday. It only breaks when a full day is missed.
- The calendar and the current time are passed in, which makes the rule testable at any date.

**`Features/Path/NextSkillCard.swift`** - the "up next" card
- One component, shown on both Today and Path. It uses a `NavigationLink(value:)` into the skill page.

**`Features/Today/TodayScreen.swift`** - the Today tab
- A progress ring, the count of finished skills, the streak, the next skill and each stage's progress.
- It reads two lists with `@Query`: the path and the skill progress. When either changes, the screen redraws.
- With no path, it shows a short note on how to choose one.

**`Features/Path/PathScreen.swift`** - the Path tab
- The whole route: each stage as a step rail, with done, current and not started skills.
- Replaces the old placeholder `MyPathScreen.swift`, which I deleted.

**`Features/Roles/RoleDetailScreen.swift`** - "Make this my path"
- The button sits under the hero. When the role is already your path, it reads "This is your path" and is disabled.
- Switching to a different path asks first, with a confirmation dialog. The dialog's message says that finished skills are kept.

**`App/MyApp.swift`** - the database
- The container now holds both `SkillProgress` and `PathSelection`.

### Checks
Before writing the screens, I tested the rules on the real content (`swiftc`, a small test program outside Xcode):
- Streak: 6 cases pass, including a gap, two finishes on one day, and "today not finished yet".
- Path: 17 unique skills in the iOS Engineer route, the first skill is `swift`, the next skill moves on as skills are finished, and exactly one skill is current.

### Test (you)
1. Open Explore, then iOS Engineer. Tap **Make this my path**. The button should change to "This is your path".
2. Open Today. It should show "Up next" with the first skill, and "0 of 17 skills".
3. Tap **Continue**, tick a checklist item, then tap **Mark skill done**. Go back to Today. The count should go to "1 of 17" and the streak should show "1 day streak".
4. Open Path. The route should show that skill as done and the next one as current.
5. Open another role and tap **Make this my path**. A dialog should ask whether to switch. Choose **Switch path**. Today and Path should now show the new role, and your finished skills should still count where they overlap.
6. Close and reopen the app. Today and Path should look the same.

### Commit
```bash
git add -A && git commit -m "feat: Today and My Path show progress from finished skills"
```

---

## Step 9 - Compass quiz

### The idea
Compass asks eight questions and suggests three roles that fit the answers. Each answer gives points to some roles. The app adds the points and ranks the roles. The ranking must match the website exactly, so the two can never disagree about a person's results.

### Files

**Web repo: `scripts/build-ios-content.ts`** - the quiz data
- Adds the questions to `content.json`. Every role a question mentions must exist, or the script stops.
- Each answer's weights are written as an **ordered list**, not an object. JSON objects in Swift lose their key order, and the order matters for one rule below.

**`CodeJourney/Core/Models/Compass.swift`** - the quiz types
- `CompassQuestion` and `CompassOption` mirror the content file.
- `RoleWeight` is a role slug and a number. Using a small struct instead of a dictionary keeps the order.

**`CodeJourney/Core/Logic/CompassScoring.swift`** - the ranking (pure Swift)
- **Score:** each answer adds its weight to each role it names.
- **Rank:** roles are ordered by score divided by the square root of their maximum possible score. Dividing by the square root stops roles that appear in many answers from winning just by appearing often.
- **Ties:** when two roles are equal, the higher match percentage wins. If they still tie, the role that appears first in the quiz wins. The website does the same, and it changes the result when four roles tie exactly.
- **Reasons:** each role keeps up to three "Because you…" reasons, strongest first.
- The file has no SwiftUI, so it can be tested on its own.

**`CodeJourney/Core/Data/ContentStore.swift`** - the questions are loaded with the rest of the content.

**`CodeJourney/Core/Data/PathChooser.swift`** - "make this my path"
- The role page and the Compass result both use this one function, so choosing a path works the same way everywhere.

**`CodeJourney/Features/Compass/CompassScreen.swift`** - the quiz
- One screen with three steps: the intro, one step per question, and the results. The step is a `@State` value, so the screen redraws as it changes.
- Answers are kept in order. Going Back restores the answer you gave before, and changing an answer drops the later ones.
- The result shows the top three roles with "Best fit", "Good fit" and "Worth a look". The best fit has a "Make my path" button. If you already have a different path, it asks first.
- The results don't show percentages. The website shows rank labels, and the app matches it.

**`CodeJourney/Features/Tools/ToolsScreen.swift`** - the Tools tab
- Compass is now a row that opens the quiz. The other tools are listed as "Soon", so you can see what is coming.
- It has its own navigation for roles and skills, so the links from the results open inside the Tools tab.

### Checks
Before writing the screens, I compared the Swift ranking with the website's own scoring code on four sets of answers, including one with an exact four-way tie. The top three roles match in all four.

### Test (you)
1. Open Tools, then Compass quiz. Tap **Start**.
2. Answer a question. **Next** should only enable once you've picked an answer. **Back** should return to the previous question with your answer still selected.
3. Answer all eight questions. The results should show three roles labelled Best fit, Good fit and Worth a look, each with reasons that start with "Because you".
4. Tap **See the role**. The role page should open. Then go back.
5. Tap **Make my path** on the best fit. If you already have a path, a dialog should ask whether to switch.
6. Open Today or Path. They should show the new path.
7. Tap **Start again**. The quiz should go back to the start.

### Commit (iOS repo)
```bash
git add -A && git commit -m "feat: Compass quiz with the same ranking as the website"
```

### Commit (web repo)
```bash
git add scripts/build-ios-content.ts && git commit -m "feat: add Compass questions and ordered weights to the iOS content build"
```

---

## Step 10a - Pay by role (Swift Charts)

### The idea
Pay is the question most people ask first. Every figure comes from a public source, and the screen shows the source and its date next to every number. A chart shows the average, and a line shows the range (10th to 90th percentile).

### Files

**Web repo: `scripts/build-ios-content.ts`** - the pay data
- Reads `content/market.yaml` and joins each role to its India row and US row. The script checks that every link points to a real row, and it stops if one doesn't.
- Each role gets a `pay` object. A missing market is `null`, not an empty value, so the screen can tell "no figure" from "zero".
- The file's checked date becomes `payChecked`, which the screen shows at the top.

**`CodeJourney/Core/Models/Pay.swift`** - the pay types
- `IndiaPay` and `USPay` mirror the source data. `exact` says whether the source's title is the same job or only the closest match.
- `RolePay` holds both markets. Either can be `nil`.

**`CodeJourney/Core/Models/Role.swift`, `ContentFile.swift`, `ContentStore.swift`** - the new field
- The role has `pay`, the file has `payChecked`, and the store exposes `payChecked` for the screen.

**`CodeJourney/Features/Pay/PayScreen.swift`** - the screen
- **Swift Charts:** `Chart` draws a `BarMark` per role for the average, and a `RuleMark` from the 10th to the 90th percentile. Only India has a range, so US bars have no line.
- **One shape for both markets:** `PayScreen.Row` holds the same fields for India and US. The chart and the list don't need to know which market is showing.
- **Units:** India uses lakh rupees, and US figures are shown in thousands of dollars on the chart. The labels say which.
- **Sources:** every role lists its figure, its range, the number of profiles, and a `CJSourceChip` linking to the source with its date.
- **"Closest title":** when the source's job title is only a near match, the screen says so in amber. This is the honest version of a number that could otherwise look exact.
- **Footnotes:** PayScale's top band is rounded, so the 90th percentile is marked "about". US roles that share one BLS title are explained, so two identical bars don't look like a mistake.
- **Chart height:** it grows with the number of roles, so every bar has room for its label.

**`CodeJourney/Features/Tools/ToolsScreen.swift`** - the Pay row
- "Pay by role" is now live in Tools.

### Checks
- The content decodes: 26 roles, 25 with an India figure, 25 with a US figure, and the source date is 2 November 2026.
- The top India average is SRE at 17.48 lakh rupees, which matches the source file.

### Test (you)
1. Open Tools, then Pay by role. The chart should show India by default, sorted from highest to lowest average.
2. Each bar should have a line across its range. Hover is not needed: check that the line is visible.
3. Switch to US. The bars should change, and the axis should read thousand US dollars.
4. Scroll to the sources. Each role should show its figure and a source link. Tap one: it should open the source in Safari.
5. Find a role with "Closest title" in amber. The note should be there.
6. In dark mode, the chart labels and bars should stay readable.

### Commit (iOS repo)
```bash
git add -A && git commit -m "feat: Pay by role with Swift Charts and sourced figures"
```

### Commit (web repo)
```bash
git add scripts/build-ios-content.ts && git commit -m "feat: add pay figures and role links to the iOS content build"
```

### Change after testing in the simulator: drawn bars instead of Swift Charts
The first chart put each role's name on top of its bar, and the range lines floated above the bars, so the chart was hard to read. A `Chart` places its category labels on the same plot as the bars, and we could not move them cleanly.

`PayScreen.swift` now draws each role as its own row: the name and value above, and a bar below. The light band behind the bar is the 10th to 90th percentile. The bar grows in when the screen opens, and Reduce Motion turns that off.

**Lesson:** a chart is good for many numbers that share one axis. For a list of named items with a value each, drawing rows with `GeometryReader` gives more control over the labels.

### Fix: text on a card in dark mode
The taste test's "if" boxes were dark text on a dark box in dark mode. The card's text uses `onAccent`, which is dark in dark mode, and the boxes used `canvas`, which is also dark there. The fix gives the box text `CJColor.ink`, which is the right colour for the canvas in both modes.

**Rule:** the text colour must match the background it sits on. Text on the accent uses `onAccent`. Text on the canvas or a surface uses `ink` or `inkSecondary`.

### Test (you)
1. Open a role page, then the taste test card. In dark mode, the "You might enjoy it if" and "Maybe not if" boxes should show light text on a dark box.
2. Switch to light mode. The same boxes should show dark text on a light box.

---

## Step 10b - Compare roles and Switch careers

### The idea
Compare puts two roles side by side. Switch careers starts from the job someone does now and shows the tech roles closest to it. Both follow the website's rules, and both are checked against the website's own code.

### Files

**Web repo: `scripts/build-ios-content.ts`** - the switch jobs
- Adds the ten starting jobs to `content.json`. Every skill a job names must exist, or the script stops.

**`CodeJourney/Core/Models/Switch.swift`** - a starting job, with its strengths and head-start skills.

**`CodeJourney/Core/Logic/SwitchLogic.swift`** - the closest roles (pure Swift)
- For each role, it splits the route into skills the job gives you (`have`) and skills still to learn (`toLearn`).
- It keeps roles with at least one match, and sorts them: fewest skills to learn first, then the biggest share of the route, then by title.
- It returns the top three.

**`CodeJourney/Core/Logic/CompareLogic.swift`** - the comparison (pure Swift)
- `route(of:)` lists every skill a role touches, once each.
- `compare` splits two routes into shared skills and skills only one role needs.
- `jobReady(of:)` adds up the first three stages and turns the weeks into months. It uses the same rounding as the website.

**`CodeJourney/Features/Compare/CompareScreen.swift`** - the Compare tool
- Two menu pickers choose the roles. A grid compares the time to be job-ready, the stages, the skills, the interview rounds, and the pay.
- Skill lists show the shared skills, then the skills only each role needs.

**`CodeJourney/Features/Switch/SwitchScreen.swift`** - the Switch tool
- A grid of the ten jobs. Each job opens its own page.
- The job page shows the strengths, the closest roles with a ring for the share of the route covered, the skills the person likely has, and where to start.

**`CodeJourney/Features/Tools/ToolsScreen.swift`** - the Tools tab
- Compare and Switch careers are now live, in the same group as Compass and Pay.

### Checks
- **Switch matches:** the Swift version matches the website's `bridgeRoles` on all ten jobs.
- **Job-ready:** the Swift version matches the website's figure for all 26 roles.

### A bug found in the simulator
Taps on the job cards did nothing. The cards used value-based links (`NavigationLink(value:)`), and the screen that handles them was not reachable from the screen showing the cards. Adding the handler to the same screen didn't fix it either.

**The fix:** the links now push the screen directly, like the Tools rows do: `NavigationLink { SwitchJobScreen(job: job) } label: { ... }`. This is the pattern to use for links inside a screen that is pushed from another stack.

### Test (you)
1. Open Tools, then Compare roles. Change Role A and Role B. The metrics and the skill lists should update, and the two roles can't be the same.
2. Open Switch careers. Tap a job card. The job page should open, with its strengths and closest roles.
3. On the job page, tap a closest role. Its page should open, and Back should return you.
4. Check the rings: each one should say "of route" under the percentage.

### Commit (iOS repo)
```bash
git add -A && git commit -m "feat: Compare roles and Switch careers, with the website's rules"
```

### Commit (web repo)
```bash
git add scripts/build-ios-content.ts && git commit -m "feat: add switch careers jobs to the iOS content build"
```

---

## Step 11 - Job post checker

### The idea
Paste a job post, and the app finds the Code Journey skills it asks for. It says which ones you have, which to learn (in a sensible order), and which role the post looks like. The text is checked on the phone and never sent anywhere.

### Files

**Web repo: `scripts/build-ios-content.ts`** - the matching data
- The script calls the website's own `buildGapData` from `src/lib/gap.ts`. The app gets exactly the same skill names, aliases and role links as the site, so both recognise the same skills.

**`CodeJourney/Core/Models/JobGap.swift`** - the matching data types, mirroring the website's shape.

**`CodeJourney/Core/Logic/JobPostAnalyser.swift`** - the matcher (pure Swift)
- A port of the website's `gap.ts`. Each phrase becomes a regular expression with whole-word rules: "sql" does not match inside "mysql", and "js" does not match inside "node.js".
- **Longest match wins:** "React Native" counts as React Native, not as React too.
- **Case:** a leading `=` in an alias makes it case-sensitive, so "React" matches the name, but "react quickly" does not match it.
- **Roles:** a role is suggested when the post shares at least two skills with its route. The score also gives a bonus when the post names the role.
- **Learning order:** skills with no prerequisites come first. Then the skills the post mentions most.

**`CodeJourney/Features/JobPost/JobPostScreen.swift`** - the screen
- `PasteButton` pastes from the clipboard without a permission prompt.
- The check button is disabled until the post has at least 30 words.
- The results show the found skills, the roles it looks like, the skills you have, the skills to learn in order, and any technologies Code Journey does not teach yet.
- Each skill and role opens its own page.

### Checks
- The Swift matcher gives the same skills, counts, first positions and "not covered" lists as the website on its three example posts.
- The roles match on those examples too, once the comparison ignores quote marks in my test output.

### A note on the spec
The spec's job checker "adds missing skills to my path". A path is one role, so the app does not add skills to it. Each skill opens its page instead. Tell me if you want a different action here.

### Test (you)
1. Open Tools, then Job post checker.
2. Paste a job post with at least 30 words. Use the Paste button, or type one. "Check this post" should enable.
3. Tap the button. You should see the number of skills found, the roles it looks like, and the skills to learn.
4. Tap a skill to learn. Its page should open.
5. Finish a skill on its page, then come back and check the same post. That skill should move to "You have".

### Commit (iOS repo)
```bash
git add -A && git commit -m "feat: job post checker with the website's matching rules"
```

### Commit (web repo)
```bash
git add scripts/build-ios-content.ts && git commit -m "feat: build the job post checker data with the website's own function"
```
