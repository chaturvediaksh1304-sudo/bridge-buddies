# Bridge Buddies — SwiftUI Starter

This is a **real, compilable-structure SwiftUI codebase** built directly from `UI_SPEC.md` — every color, type size, and component maps 1:1 to a token or section number in the spec. It's the seed your Claude Code agents build on, not a finished app.

## What's here

```
BridgeBuddies/
  DesignSystem/
    Colors.swift        — every color token in UI_SPEC §1
    Typography.swift     — display/body font scale, Herae's 4px-step sizes
    Spacing.swift         — radius/spacing constants + cardShadow() modifier
  Components/
    InputPill.swift              — §2.1
    SearchActionBar.swift        — §2.2
    PrimaryButton.swift          — §2.5
    CircularNavButton.swift      — §2.4
    ListCard.swift               — §2.6
    BottomTabBar.swift           — §2.7
    DualOrbAvatar.swift          — §2.8, §2.9 (avatar + status dot)
    ProgressRing.swift           — §2.15 (Herae-derived)
    DashboardModules.swift       — §2.14, 2.16–2.20 (ModuleCard, StatTrioRow,
                                    RangeGradientBar, ExpandableDataRow,
                                    FilterPillGroup, DetailCardWithIconCTA —
                                    all Herae-derived)
  Screens/
    Onboarding/SplashView.swift  — Splash + Login (wireframes #9, #8)
    Home/HomeView.swift          — the previously-unbuilt dashboard Home
                                    screen, assembled from the new
                                    Herae-derived components
```

## Not yet built (still open per UI_SPEC §6)

- School Select, Profile Setup/Edit Profile, Identity Bubbles, Chat List, Campus Resources, Profile — these are fully specced in UI_SPEC.md §4 but not coded yet. Same component patterns apply; they're straightforward to generate from the spec.
- **Chat Thread screen** — still has no wireframe or spec. Needs your input before anyone (human or agent) can build it.
- Firebase wiring, Auth, Firestore models — none of this is connected. Every screen here uses local `@State` only.

## How to use this with Claude Code

1. Open Xcode, create a new SwiftUI App project named `BridgeBuddies`.
2. Drag the `BridgeBuddies/DesignSystem`, `Components`, and `Screens` folders into the project (check "Copy items if needed").
3. Add `PlayfairDisplay-Bold` and `PlayfairDisplay-Regular` (Google Fonts, free) to the project and Info.plist's `UIAppFonts` array — `Typography.swift` references them and falls back to system serif if missing.
4. Point Claude Code agents at `UI_SPEC.md` as the source of truth and this folder as the existing component library — instruct them to **extend**, not duplicate, what's in `/Components`.

## Font note

`Typography.swift` hardcodes `"PlayfairDisplay-Bold"`. If you pick a different serif, that's the one line to change — every screen inherits from `Font.displayLG/MD/SM`, nothing else needs touching.
