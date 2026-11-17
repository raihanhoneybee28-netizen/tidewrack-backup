extends Node
## Journal — durable discovered-log collection.
##
## Journal owns validation and ordering; GameState owns the save file. The
## save-facing methods deliberately accept legacy payloads so old saves remain
## usable after the journal ships.

signal entry_added(id: String)

var _entries: Array[String] = []


func discover(id: String) -> void:
	var normalized := id.strip_edges()
	if normalized.is_empty() or normalized in _entries:
		return
	_entries.append(normalized)
	entry_added.emit(normalized)


func entries() -> Array[String]:
	return _entries.duplicate()


func has(id: String) -> bool:
	return id in _entries


func reset() -> void:
	_entries.clear()


func to_save_data() -> Dictionary:
	return {"entries": _entries.duplicate()}


func load_from_save(payload: Variant) -> void:
	_entries.clear()

	var raw_entries: Variant = payload
	if typeof(payload) == TYPE_DICTIONARY:
		var payload_dictionary: Dictionary = payload
		raw_entries = payload_dictionary.get("entries", [])
	if typeof(raw_entries) != TYPE_ARRAY:
		return

	for raw_id in raw_entries:
		if typeof(raw_id) == TYPE_STRING:
			discover(str(raw_id))
