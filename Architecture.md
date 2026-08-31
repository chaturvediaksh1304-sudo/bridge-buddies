# Bridge Buddies — Architecture

## Platform
iOS (native), built with Xcode + SwiftUI

## Stack
- Frontend: SwiftUI, native components only (no third-party UI libraries)
- Backend: Firebase (Auth, Firestore, Cloud Functions, Firebase Cloud Messaging)
- Database: Firestore — collections for UserProfile, Preferences, Match, ChatMessage, Meetup (post-MVP), Event (post-MVP)
- Auth: Firebase Auth — CMU-email domain verification + Apple Sign-In
- Hosting/deploy: Firebase-managed backend; app distributed via TestFlight/App Store when ready
- Third-party APIs/services: MapKit (Campus Resources location), Apple Sign-In (AuthenticationServices)

## Folder structure
Extends the existing starter (`BridgeBuddies/` from the design phase):
```
BridgeBuddies/
  DesignSystem/          — Colors, Typography, Spacing (done)
  Components/            — shared UI components (done, extend as needed)
  Screens/
    Onboarding/           — Splash, Login, SchoolSelect, ProfileSetup, IdentityBubbles
    Home/                 — HomeView (dashboard)
    Chat/                 — ChatListView, ChatThreadView (pending spec)
    Explore/              — CampusResourcesView
    Profile/              — ProfileView, EditProfileView
  Models/                 — Firestore-backed model structs (UserProfile, Preferences, Match, ChatMessage)
  Services/               — FirebaseAuthService, FirestoreService, MatchingService, MapKitService
  Tests/                  — unit tests, one target per Service (TDD — tests land before implementation)
```

## Data flow
User authenticates via Firebase Auth (CMU email or Apple Sign-In) → completes Profile + Preferences, written to Firestore → matching logic (Cloud Function) reads Preferences across users, writes candidate Match documents → user accepts/declines from Home → accepted Match unlocks a Chat thread, messages read/written to Firestore in real time → Campus Resources reads a static/seeded Firestore collection, MapKit renders location where applicable.
