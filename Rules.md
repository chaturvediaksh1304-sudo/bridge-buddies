# Bridge Buddies — Rules

## Libraries
- Prefer: SwiftUI native components, Firebase official SDKs (FirebaseAuth, FirebaseFirestore, FirebaseMessaging), MapKit, AuthenticationServices (Apple Sign-In)
- Avoid: third-party UI/component libraries — no exceptions without asking first

## Error handling
Degrade gracefully. Log errors (print/OSLog for now, structured logging later) and keep the app usable — a failed network call shows an inline error state or stale cached data, not a crash or blank screen.

## Testing
TDD. Tests are written before implementation for every Service and Model. Screens get at minimum a smoke test verifying they render without crashing given valid/empty/error state data.

## Requires explicit approval before doing
- No GitHub push until explicitly told to push — this applies for the whole project, not just early phases.
- Deleting or modifying Firestore data
- Changing Firebase security rules or any prod config
- Installing new dependencies not already listed in Architecture.md

## Execution discipline (Karpathy guidelines — always included)
1. **Think before coding** — state assumptions explicitly; if multiple interpretations exist, present them, don't silently pick; stop and ask if genuinely unclear.
2. **Simplicity first** — minimum code that solves the task; no speculative abstraction, no unrequested configurability, no error handling for impossible cases.
3. **Surgical changes** — touch only what the task requires; don't refactor or "improve" adjacent code; match existing style; remove only orphans your own change created.
4. **Goal-driven execution** — every task starts with a stated, checkable success criterion; work in verify-then-proceed loops (implement → check against criterion → fix → re-check) rather than declaring done by feel.

## Looping mandate
Work phase-by-phase per Phases.md. Do not attempt multiple phases in a single pass. Each phase's done-criteria must be verifiably met before starting the next.

## Open item
Chat Thread has no UI spec yet (see UI_SPEC.md §6). Phase 4 cannot start until that spec exists — flag this rather than inventing a layout.
