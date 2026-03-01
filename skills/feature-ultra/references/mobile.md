# Mobile Application Domain Checks

Additional analysis for features in iOS, Android, and cross-platform mobile applications.

## Table of Contents
- [Lifecycle and State](#lifecycle-and-state)
- [Network and Connectivity](#network-and-connectivity)
- [Platform Constraints](#platform-constraints)
- [User Behavior Patterns](#user-behavior-patterns)
- [Mobile Anti-Patterns](#mobile-anti-patterns)

---

## Lifecycle and State

### App Lifecycle
- What happens when the app is backgrounded mid-operation? Is state preserved? Does the operation continue, pause, or cancel?
- What happens when the app is killed by the OS (low memory)? Is in-progress data lost?
- On app restore (cold start after being killed), does the feature resume from a valid state or does the user start over?
- If using background tasks (background fetch, background processing), are they compliant with OS restrictions? Do they complete within the time limit?

### Screen Lifecycle
- What happens when the screen is rotated mid-operation? Is state preserved through configuration changes?
- If navigating away and back to a screen, is the state fresh or stale? Should it be?
- Deep links: if the user enters the feature via a deep link, is there enough context to render the screen? Are required parent screens in the back stack?

### Persistent State
- Is local storage (Core Data, Room, SQLite, SharedPreferences/UserDefaults) used correctly?
- If the app updates, are local databases migrated? What if migration fails?
- Is sensitive data stored in the keychain/keystore, not in plain local storage?

---

## Network and Connectivity

### Offline Behavior
- What does the feature look like with no network? Blank screen, cached data, or explicit offline message?
- If the user performs an action offline, is it queued for sync? What's the conflict resolution when sync happens?
- If the app shows cached data, is there an indication of staleness?

### Network Transitions
- What happens when network drops mid-request? Is there retry logic? Does it retry on reconnect?
- What happens when switching from WiFi to cellular mid-operation? (Connection may briefly drop)
- On slow networks (2G, high latency), does the feature degrade gracefully? Are timeouts appropriate?

### Data Sync
- If data is modified on another device or the web, when does this device learn about it? Push notification, pull on foreground, or manual refresh?
- If there are conflicts between local changes and server changes, who wins? Is the user informed?
- Is sync atomic? If sync fails partway, is local state consistent?

---

## Platform Constraints

### Permissions
- Does the feature require runtime permissions (camera, location, contacts, notifications)?
- What's the experience if the user denies the permission? Is there a fallback, or does the feature break?
- If the user revokes permission after granting it (in Settings), does the app handle the revocation gracefully?
- On Android: does the feature handle "Don't ask again" state? On iOS: does it guide users to Settings when permission is denied?

### Battery and Resources
- Does the feature use location, Bluetooth, or sensors continuously? What's the battery impact?
- Are there wake locks or background processes that could drain battery?
- Is image/video processing done on a background thread? Does it respect memory limits on low-end devices?

### OS Version Compatibility
- Does the feature use APIs that aren't available on the minimum supported OS version?
- Are there behavioral differences between OS versions that affect this feature?
- On Android: does the feature work across manufacturer-specific OS variants (Samsung, Xiaomi, etc.)?

---

## User Behavior Patterns

Check these mobile-specific usage patterns:

1. **Interruptions** — Phone call, notification from another app, alarm. User leaves mid-flow, returns minutes or hours later.
2. **One-handed use** — Are critical actions reachable? Are destructive actions far from common tap targets?
3. **Multitasking** — User switches between this app and another. State should be preserved.
4. **Poor connectivity** — Elevator, subway, rural area. Requests may timeout or fail unpredictably.
5. **Low storage** — Device is nearly full. Downloads, caches, and local databases may fail to write.
6. **Accessibility** — VoiceOver/TalkBack, Dynamic Type/font scaling, reduced motion, high contrast. Does the feature work with all of these?
7. **Rapid back navigation** — User quickly taps back multiple times. Are intermediate screens handling this gracefully?
8. **Background to foreground** — App was in background for hours. Are auth tokens expired? Is data stale? Is there a refresh?

---

## Mobile Anti-Patterns

| Anti-Pattern | Description |
|-------------|-------------|
| **Cold Start Crash** | App killed by OS, restored via deep link. Required state is nil. Crash on forced unwrap / null access. |
| **Rotation Amnesia** | Device rotated, activity/fragment recreated, all in-progress form data lost. |
| **Permission Wall** | Feature requires permission but provides no value explanation. User denies, feature is broken with no graceful fallback. |
| **Background Timeout** | Background task exceeds OS time limit. Task killed mid-operation. Data left inconsistent. |
| **Stale Token** | App foregrounded after hours. Auth token expired. Every request fails until user re-authenticates, but no automatic redirect to login. |
| **Sync Conflict Swallow** | Local and remote changes conflict. App silently picks one. User's work disappears without explanation. |
| **Keyboard Occlusion** | Keyboard opens and covers the input field or submit button. User can't see what they're typing or submit the form. |
| **Unbounded Cache** | Local cache grows without limit. Eventually consumes all available storage. App crashes on write. |
