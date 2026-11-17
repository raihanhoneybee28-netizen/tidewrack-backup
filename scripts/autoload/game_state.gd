extends Node
## GameState — global save/load, story flags, and durable journal state.
##
## Autoloaded as `GameState`. Version 1 saves contain scene + story flags.
## Version 2 adds the Journal payload without changing the legacy fields.

signal state_changed

const SAVE_PATH := "user://save.json"
const TEMP_SAVE_PATH := "user://save.json.tmp"
const SAVE_VERSION := 2
const DEFAULT_SCENE := "res://scenes/game.tscn"

## Story flags set during play, e.g. {"trusted_edith": true}.
var flags: Dictionary = {}
## Path of the scene the player should resume into.
var current_scene: String = DEFAULT_SCENE


func set_flag(name: String, value: Variant) -> void:
	flags[name] = value
	state_changed.emit()


func get_flag(name: String, default: Variant = false) -> Variant:
	return flags.get(name, default)


func new_game() -> void:
	flags.clear()
	current_scene = DEFAULT_SCENE
	var journal := _journal()
	if journal != null and journal.has_method("reset"):
		journal.reset()
	state_changed.emit()


## Kept for existing callers that only need to know whether a save file exists.
func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


## Use this for UI that should not offer Continue for a malformed or obsolete save.
func has_usable_save() -> bool:
	return not _read_save_data(false).is_empty()


func save_game() -> bool:
	var journal_payload: Variant = {}
	var journal := _journal()
	if journal != null and journal.has_method("to_save_data"):
		journal_payload = journal.to_save_data()

	var payload := {
		"version": SAVE_VERSION,
		"scene": current_scene,
		"flags": flags,
		"journal": journal_payload,
	}
	var text := JSON.stringify(payload, "\t")
	var file := FileAccess.open(TEMP_SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("GameState: could not open temporary save file for writing.")
		return false
	file.store_string(text)
	file.flush()
	file.close()

	# Do not replace the last known-good save unless the staged file parses.
	if _read_save_data_from(TEMP_SAVE_PATH, true).is_empty():
		DirAccess.remove_absolute(TEMP_SAVE_PATH)
		push_error("GameState: staged save could not be verified.")
		return false

	var result := DirAccess.rename_absolute(TEMP_SAVE_PATH, SAVE_PATH)
	if result != OK:
		DirAccess.remove_absolute(TEMP_SAVE_PATH)
		push_error("GameState: could not replace save file (error %s)." % result)
		return false
	return true


func load_game() -> bool:
	var data := _read_save_data(true)
	if data.is_empty():
		return false

	var loaded_scene: Variant = data.get("scene", DEFAULT_SCENE)
	if typeof(loaded_scene) != TYPE_STRING or not ResourceLoader.exists(loaded_scene, "PackedScene"):
		push_error("GameState: save references an unavailable scene.")
		return false

	var loaded_flags: Variant = data.get("flags", {})
	if typeof(loaded_flags) != TYPE_DICTIONARY:
		push_error("GameState: save has invalid story flags.")
		return false

	# Apply only after the whole payload has passed validation. This leaves an
	# in-progress session intact when a damaged save fails to load.
	current_scene = loaded_scene
	flags = (loaded_flags as Dictionary).duplicate(true)

	var journal := _journal()
	if journal != null and journal.has_method("load_from_save"):
		# Version 1 has no journal; treating it as an empty collection preserves
		# its flags and makes the migration invisible to players.
		journal.load_from_save(_journal_payload_from(data))

	state_changed.emit()
	return true


func delete_save() -> void:
	if has_save():
		DirAccess.remove_absolute(SAVE_PATH)
	if FileAccess.file_exists(TEMP_SAVE_PATH):
		DirAccess.remove_absolute(TEMP_SAVE_PATH)


func _journal() -> Node:
	return get_node_or_null("/root/Journal")


func _journal_payload_from(data: Dictionary) -> Variant:
	# Accept the nested v2 format and the short-lived array format used by
	# early journal experiments.
	if data.has("journal"):
		return data["journal"]
	return data.get("journal_entries", [])


func _read_save_data(report_errors: bool) -> Dictionary:
	return _read_save_data_from(SAVE_PATH, report_errors)


func _read_save_data_from(path: String, report_errors: bool) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		if report_errors:
			push_error("GameState: could not open save file for reading.")
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		if report_errors:
			push_error("GameState: save file is corrupt.")
		return {}
	return parsed
