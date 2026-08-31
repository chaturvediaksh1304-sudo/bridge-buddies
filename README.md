# Bridge Buddies

An iOS app that pairs university students — domestic and international — for
low-pressure, in-person connection based on shared interests, comfort levels and
social pace. SwiftUI, no third-party UI libraries.

See [PRD.md](PRD.md), [Architecture.md](Architecture.md), [Phases.md](Phases.md)
and [Rules.md](Rules.md) for scope, stack and working agreements.

## Status

Front-end only. Every screen uses local `@State` — **no Firebase, auth, or
persistence is wired up yet.**

**Built:** Splash · Login · School Select · Profile Setup · Identity Bubbles ·
Chat List · Campus Resources · Profile · Home

**Not built:** Chat Thread (deliberately stubbed — no wireframe or spec exists
for it yet, so the layout hasn't been invented), Edit Profile (same form as
Profile Setup, straightforward to derive), and the entire backend.

## Layout

```
BridgeBuddies/BridgeBuddies/
  DesignSystem/   Colors, Typography, Spacing — every token lives here
  Components/     17 shared components; screens compose these, never restyle
  Screens/        one file per screen
```

The rule the codebase is built on: **screens contain no styling of their own.**
Colours, type, radii, shadows and spacing all come from `DesignSystem/`, and
anything reusable is a component. If a screen needs a new visual pattern, it
becomes a component rather than inline styling.

## Design

The visual language is derived from the Herae health-app case study — a
five-swatch palette (`#F4E0AC` cream, `#D6DDC6` sage, `#8E9E6E` olive,
`#10120C` ink, white) over a single cream-to-sage canvas gradient, with
translucent layered surfaces. Display type is a serif (Playfair Display,
falling back to the system serif); UI type is the system sans.

The four semantic status colours are the only hues outside that palette — they
encode meaning (available / busy / off campus / none), so they stay
distinguishable rather than decorative.

> **Note:** `Design.md` still documents the earlier CMU-maroon direction and is
> out of date with the code.

## Building

There is no `.xcodeproj` yet — the sources are a loose tree intended to be
dragged into an Xcode SwiftUI app target. To typecheck without a project:

```bash
cd BridgeBuddies/BridgeBuddies && xcrun swiftc -typecheck -sdk "$(xcrun --sdk iphoneos --show-sdk-path)" -target arm64-apple-ios17.0 DesignSystem/*.swift Components/*.swift Screens/*/*.swift
```

Add `PlayfairDisplay-Bold` to the target and to `UIAppFonts` for the intended
display face; without it the system serif is used.
