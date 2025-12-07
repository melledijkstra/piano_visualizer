class_name NoteNode extends ColorRect

var speed: float = 0.0
var data: NoteData

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

func calculate_height() -> float:
	return max(data.duration * speed, 2.0)
