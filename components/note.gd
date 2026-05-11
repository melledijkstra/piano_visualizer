class_name NoteNode extends ColorRect

var speed: float = 0.0
var data: NoteData
var has_hit_target: bool = false

func setup(note_data: NoteData, lane_width: float, fall_speed: float):
	self.data = note_data
	self.speed = fall_speed
	
	# 1. Calculate dimensions
	# Width is slightly smaller than the lane to leave a gap
	var w = lane_width * 0.9
	
	# Height = Duration (seconds) * Speed (pixels/second)
	var h = data.duration * speed
	
	# Minimum height to ensure short notes are visible
	h = calculate_height()
	
	self.size = Vector2(w, h)
	
	# Duplicate material to allow unique shader parameters per note
	if material:
		self.material = material.duplicate()
		_update_shader_size()

func calculate_height() -> float:
	self.size.y = max(data.duration * speed, 2.0)
	_update_shader_size()
	return self.size.y

func _update_shader_size() -> void:
	if material is ShaderMaterial:
		(material as ShaderMaterial).set_shader_parameter("node_size", self.size)

func bottom_y() -> float:
	# anchor is at the top left of the note rectangle (position.y)
	# so bottom y is position.y + height of the note
	return self.position.y + self.size.y
