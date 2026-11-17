# Tidewrack — Game Design Document

Concise and living. For story canon see [`narrative-bible.md`](narrative-bible.md);
for schedule see [`milestones.md`](milestones.md).

## Pillars

1. **The fog keeps its secrets.** Discovery is slow, earned, and atmospheric.
2. **Words over combat.** The game is exploration + reading + choices. No fail
   states, no timers, no death.
3. **A place you tend.** The lighthouse is a home and a job; verbs are keeper's
   verbs — light the lamp, log the night, work the radio.

## Core loop

Explore a location → find a document, recording, or object → read/hear it in a
branching conversation → make a choice that sets a flag → the world (and later,
who answers you) responds. Repeat across locations toward the water.

## Systems

| System | State | Notes |
|--------|-------|-------|
| Branching dialogue | ✅ vertical slice | JSON graphs, choices set flags. |
| Save / load        | ✅ vertical slice | Single slot, `user://save.json`. |
| Menus + settings   | ✅ vertical slice | Title, pause, volume, fullscreen. |
| Player movement    | ✅ vertical slice | Top-down; wall collision pending. |
| Journal state      | ✅ persisted      | Ordered, duplicate-free log IDs save with story state; reader UI and discovery hooks remain demo work. |
| Second location    | ⏳ demo           | The lamp room. |
| Controller + remap  | ⏳ demo          | Currently keyboard-only, built-in actions. |
| Localization        | ⏳ press build    | String extraction + translation tables. |
| Accessibility       | ⏳ press build    | Text scale, dyslexia-friendly font, no-flash. |
| Steam integration   | ⏳ launch         | Achievements, cloud saves. |

## Journal & save contract

The Journal is an autoloaded, durable collection of ordered, unique log IDs.
A manual save stores it alongside the current scene and branching-story flags in
the single `user://save.json` slot. Continue rejects unreadable saves and saves
that reference an unavailable scene. A malformed flags field is recoverable:
the valid scene loads with empty story flags. Restored journal entries load
silently, without emitting new-entry notifications.

Journal persistence is additive: legacy version-1 saves retain their scene and
story flags and load with an empty journal. The shipped save format is version 2
and writes through a verified temporary file before replacing the active save.

The log reader and the content hooks that call `Journal.discover(id)` are still
Public Demo work. Until those hooks land, the persistence layer is ready but
normal gameplay does not add journal entries on its own.

## Interaction design

Proximity-based: walk near an object, a prompt appears, press Enter. Dialogue
uses a typewriter reveal with press-to-skip; choices are keyboard-navigable and
focus the first option automatically. Movement is locked during conversation.

## Art & audio direction

Placeholder primitives today. Target: muted, desaturated palette (slate, kelp,
lamp-gold as the one warm accent — `#ffd466`); hand-painted 2D; a sound bed of
foghorn, surf, and radio static carrying most of the mood. Concept art and
final assets are produced per-milestone (see the tracker's `art` label).

## Out of scope (YAGNI)

No inventory economy, no crafting, no procedural generation, no multiplayer.
