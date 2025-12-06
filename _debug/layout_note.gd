class_name LayoutNote extends ColorRect

# --- Components ---
var label: Label

# --- Data ---
var note_data: NoteData

func _init():
	# create a label to display the note name
	label = Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	# Make label fill the rect
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	# Set a font size that fits (adjust as needed)
	label.add_theme_font_size_override("font_size", 10)
	# Contrast color
	label.modulate = Color(0, 0, 0, 1)
	add_child(label)

func setup(data: NoteData, lane_height: float, pixels_per_second: float):
	note_data = data
	
	# 1. Determine Note Name (e.g., 60 -> C4)
	label.text = note_data.key_name()
	
	# 2. Set visual properties based on Pitch (X-axis)
	# A standard 88-key piano goes from MIDI note 21 (A0) to 108 (C8).
	# We map the highest pitch (108) to the top (y=0).
	var key_index = clamp(108 - data.pitch, 0, 87)
	
	self.position.y = key_index * lane_height
	self.size.y = lane_height * 0.9 # Small gap between lanes
	
	# 3. Set Color (Optional: Visual flair based on velocity)
	self.color = Color.from_hsv((data.pitch % 12) / 12.0, 0.6, 0.9)
	
	# 4. Apply Initial Zoom (Length)
	update_zoom(pixels_per_second)

func update_zoom(pixels_per_second: float):
	if note_data == null: return
	
	# Calculate X position based on time
	self.position.x = note_data.start_time * pixels_per_second
	
	# Calculate Width based on duration
	var width = note_data.duration * pixels_per_second
	self.size.x = max(width, 10.0) # Ensure minimal visibility