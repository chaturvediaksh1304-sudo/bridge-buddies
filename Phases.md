# Bridge Buddies — Phases

Each phase is a loop: implement → verify against done-criteria → fix → re-check → proceed. Never skip ahead.

## Phase 0: Design system + component library
- Goal: shared SwiftUI foundation every screen builds on
- Done-criteria:
  - [ ] Colors, Typography, Spacing tokens match UI_SPEC.md §1 exactly
  - [ ] All components in §2 of UI_SPEC.md exist in /Components
  - [ ] Project compiles with Splash + Login + Home screens rendering (already done in starter)
- Depends on: none

## Phase 1: Firebase setup + Auth
- Goal: working sign-up/login with CMU email verification and Apple Sign-In
- Done-criteria:
  - [ ] Firebase project connected, FirebaseAuth SDK integrated
  - [ ] Email/password auth with CMU domain validation working
  - [ ] Apple Sign-In working end-to-end
  - [ ] School Select screen built and functional (CMU-only list per UI_SPEC §4.3)
  - [ ] Tests written first for AuthService, passing
- Depends on: Phase 0

## Phase 2: Profile + Identity Bubbles
- Goal: users can create and edit a full profile including comfort bubbles
- Done-criteria:
  - [ ] UserProfile and Preferences Firestore models defined and tested
  - [ ] Profile Setup screen (UI_SPEC §4.4) writes to Firestore
  - [ ] Edit Profile screen reads/updates the same data
  - [ ] Identity Bubbles screen (UI_SPEC §4.5) supports multi-select + custom entries, persists to Preferences
- Depends on: Phase 1

## Phase 3: Matching
- Goal: users receive, accept, or decline matches; Home dashboard reflects real data
- Done-criteria:
  - [ ] Match Firestore model + Cloud Function matching logic (interests/languages/schedule/comfort bubbles)
  - [ ] Home dashboard (UI_SPEC §6 draft layout) shows real match/stat data, not mock data
  - [ ] Accept/decline flow updates Match state correctly
  - [ ] Tests written first for MatchingService, passing
- Depends on: Phase 2

## Phase 4: Chat
- Goal: real-time messaging between matched users
- Done-criteria:
  - [ ] Chat Thread UI spec exists (blocked — needs Aksh's input before this phase starts)
  - [ ] ChatMessage Firestore model + real-time listener
  - [ ] Chat List (UI_SPEC §4.6) shows real conversations, not mock data
  - [ ] Chat Thread screen built and functional
  - [ ] Tests written first for ChatService, passing
- Depends on: Phase 3, and a completed Chat Thread spec

## Phase 5: Campus Resources + Profile/Settings
- Goal: resource directory with location, and a working settings/profile screen
- Done-criteria:
  - [ ] Campus Resources screen (UI_SPEC §4.7) reads a seeded Firestore collection, opens external webpages
  - [ ] MapKit integration shows resource location where applicable
  - [ ] Profile/Settings screen (UI_SPEC §4.8) — Edit Profile, Sign Out, stats — functional
  - [ ] Sign Out correctly returns to Splash
- Depends on: Phase 2

## Phase 6: Polish + QA
- Goal: coherent, submittable v1
- Done-criteria:
  - [ ] Test coverage reviewed across all Services — no untested Service code
  - [ ] Visual consistency pass across all screens against UI_SPEC.md (no drift)
  - [ ] Empty/loading/error states exist for every screen (flagged as missing in UI_SPEC §6)
  - [ ] Full end-to-end flow works: signup → profile → match → chat → resources
- Depends on: Phases 1–5
