class_name NoteNode extends ColorRect

var speed: float = 0.0
var vp_size: Vector2
var data: NoteData

# Called by Main when spawning this note
func setup(note_data: NoteData, lane_width: float, fall_speed: float):
	self.data = note_data
	vp_size = get_viewport().size
	
	# 1. Calculate dimensions
	# Width is slightly smaller than the lane to leave a gap
	var w = lane_width * 0.9
	
	# Height = Duration (seconds) * Speed (pixels/second)
	var h = data.duration * fall_speed
	
	# Minimum height to ensure short notes are visible
	h = max(h, 5.0)
	
	self.size = Vector2(w, h)

func _process(_delta):
	# Cleanup: If we fall way below the screen, delete ourselves
	if position.y - self.size.y > vp_size.y:
		print("Note fell below viewport, destroying")
		self.queue_free()
