extends Node2D

# --- Configuration ---
@export var note_scene: PackedScene  # Drag Note.tscn here in Inspector
@export var fall_speed: float = 150.0 # Pixels per second

# --- State ---
var midi_processor = preload("res://midi_preprocessor.gd").new()
var parser: MidiFileParser
var song_data: Array = []
var spawn_index: int = 0
var current_time: float = -3.0 # Start negative to give a "Get Ready" pause

var screen_height: float
var screen_width: float

@onready var keyboard = $Keyboard

# Calculated property: How many seconds it takes to fall from top to target
var fall_duration: float:
	get:
		var target_y = screen_height
		if keyboard:
			target_y -= keyboard.height
		return target_y / fall_speed

func _ready():
	print('has movie: ', OS.has_feature('movie'))
	var viewport_size = get_viewport().size
	
	screen_height = viewport_size.y
	screen_width = viewport_size.x
	
	# Position keyboard at bottom
	if keyboard:
		keyboard.position.y = screen_height - keyboard.height

	# 1. Load your specific MIDI file here
	parser = MidiFileParser.load_file("res://input/clair_de_lune.mid")
	
	song_data = midi_processor.parse(parser)
	print("Loaded ", song_data.size(), " notes.")

func _process(delta):
	if song_data.is_empty(): return
	
	# 1. Advance time
	current_time += delta
	
	# 2. Check for notes to spawn
	var look_ahead_time = current_time + fall_duration
	
	while spawn_index < song_data.size():
		var note = song_data[spawn_index]
		
		if note.start_time <= look_ahead_time:
			_spawn_note(note)
			spawn_index += 1
		else:
			break

func _spawn_note(note_data: NoteData):
	if note_scene == null: return
	if keyboard == null: return

	var instance = note_scene.instantiate()
	add_child(instance)
	
	# Get layout from keyboard
	var key_center_x = keyboard.get_key_x(note_data.pitch)
	var key_width = keyboard.get_key_width(note_data.pitch)
	
	# Setup note
	instance.setup(note_data, key_width, fall_speed)

	# Adjust position
	var target_y = screen_height - keyboard.height
	
	var dist = (note_data.start_time - current_time) * fall_speed
	var y_pos = target_y - dist - (note_data.duration * fall_speed)

	# Centering X (Note.gd setup creates a rect of size.x)
	var x_pos = key_center_x - (instance.size.x / 2.0)
	
	instance.position = Vector2(x_pos, y_pos)
