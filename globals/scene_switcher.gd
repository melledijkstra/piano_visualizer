class_name SceneSwitcher extends Node

## parameters to pass from one scene to another
static var _params = {}

func switch(scene_path: String, params = {}) -> void:
	get_tree().change_scene_to_file(scene_path)
	_params = params

static func get_param(key: String, default_value = null):
	if _params.has(key):
		return _params[key]
	return default_value

static func get_params() -> Dictionary:
	return _params
