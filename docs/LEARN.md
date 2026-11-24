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
