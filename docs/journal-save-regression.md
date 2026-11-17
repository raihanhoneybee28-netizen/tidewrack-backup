# Journal Save Regression Checklist

Run this checklist against a build with an isolated user:// data directory.
The journal save format is version 2; it stores the current scene, story flags,
and an ordered list of unique journal entry IDs.

## Baseline save / Continue

- [ ] Start a new game, set at least two branching story flags, add two distinct
      journal entries, and save from the pause menu.
- [ ] Return to the title screen and choose Continue.
- [ ] Confirm the saved scene opens.
- [ ] Confirm every chosen story flag still affects dialogue/world behavior.
- [ ] Confirm both journal entries are present, in discovery order.
- [ ] Save again, quit, relaunch, and Continue again; state remains unchanged.

## Journal entry handling

- [ ] Discover the same entry twice. Confirm it appears only once.
- [ ] Discover entries with leading/trailing whitespace. Confirm stored IDs are
      normalized and blank IDs are ignored.
- [ ] Save, Continue, add a third entry, save, and Continue. Confirm the first
      two entries are retained and the third is appended.
- [ ] Begin New Game. Confirm in-memory story flags and journal entries clear.
- [ ] After New Game, do not save; relaunch and Continue. Confirm the previous
      saved slot remains available. Then save the new game and confirm it
      replaces that slot.

## Legacy and compatibility saves

- [ ] Place a version-1 save containing a valid scene and multiple story flags
      in user://save.json.
- [ ] Confirm Continue is available and loads the scene and all flags.
- [ ] Confirm the journal starts empty.
- [ ] Save the loaded legacy game, relaunch, and Continue. Confirm flags remain
      intact and the rewritten save contains version 2 journal data.

## Invalid-save handling

For each case below, return to the title screen or relaunch the game.

- [ ] Empty or truncated save.json: Continue is disabled; New Game still works.
- [ ] Invalid JSON or a top-level JSON array: Continue is disabled.
- [ ] A save whose scene is missing, non-string, or not a packaged scene:
      Continue is disabled or loading fails without changing the active session.
- [ ] A save whose flags value is not an object: Continue is disabled or
      loading fails without changing the active session.
- [ ] A journal payload with a non-array entries value: the save loads, with
      an empty journal and intact scene/flags.

## Write and recovery behavior

- [ ] With a known-good save present, make more progress and save. Confirm the
      newly saved state loads after relaunch.
- [ ] Simulate a failed write (for example, make the user-data directory
      unwritable). Confirm Save reports failure and the earlier known-good save
      still loads.
- [ ] Leave a malformed or partial save.json.tmp beside a valid save.json.
      Confirm Continue uses the valid save.
- [ ] Delete the save through the game flow. Confirm both save.json and any
      temporary save file are removed, and Continue is disabled.

## Release gate

- [ ] Complete the Godot parser check:

      godot --headless --path . --check-only

- [ ] Perform one full controller and keyboard pass through Save, Main Menu,
      Continue, and New Game.
- [ ] Record the build version and platform(s) tested with this checklist in
      the release notes or playtest log.
