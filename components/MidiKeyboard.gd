@tool

class_name MidiKeyboard extends Keyboard

@onready var particle_scene: PackedScene = preload("res://_debug/sparkle_particles.tscn")

var audio: AudioStreamPlayer

var pressed_key_color = Color.GRAY

func _ready() -> void:
	super._ready()
	if Engine.is_editor_hint():
		return
	audio = AudioStreamPlayer.new()
	audio.stream = preload("res://assets/audio/A440.wav")
	add_child(audio)

	OS.open_midi_inputs()

	print(OS.get_connected_midi_inputs())

func _input(event: InputEvent) -> void:
	if event is InputEventMIDI:
		# _print_midi_info(event)
		var pitch_index: int = event.pitch
		match event.message:
			MIDIMessage.MIDI_MESSAGE_NOTE_ON:
				print("Note ON: ", event.pitch)
				var exponent: float = (pitch_index - 69.0) / 12.0
				audio.pitch_scale = pow(2, exponent)
				audio.play()
				key_nodes[pitch_index].color = pressed_key_color
				# find center of the key
				print(Vector2(self.get_key_x(pitch_index), self.position.y))
				spawn_explosion(Vector2(self.get_key_x(pitch_index), self.position.y))
			MIDIMessage.MIDI_MESSAGE_NOTE_OFF:
				print("Note OFF: ", event.pitch)
				# audio.stop()
				if _is_black(pitch_index):
					key_nodes[pitch_index].color = black_key_color
				else:
					key_nodes[pitch_index].color = white_key_color


func _print_midi_info(midi_event):
	print(midi_event)
	print("Channel ", midi_event.channel)
	print("Message ", midi_event.message)
	print("Pitch ", midi_event.pitch)
	print("Velocity ", midi_event.velocity)
	print("Instrument ", midi_event.instrument)
	print("Pressure ", midi_event.pressure)
	print("Controller number: ", midi_event.controller_number)
	print("Controller value: ", midi_event.controller_value)

func _exit_tree() -> void:
	OS.close_midi_inputs()

func spawn_explosion(pos: Vector2) -> void:
	if particle_scene:
		# 1. Create a new instance of the particle scene 
		var instance = particle_scene.instantiate()
		
		# 2. Set its position to the click location
		instance.position = pos
		
		# 3. Add it to the scene tree so it becomes visible
		get_parent().add_child(instance)

		# 4. Start the explosion
		instance.emitting = true
		
		# 5. Auto-Cleanup: Delete the node when the particles finish
		# This requires 'One Shot' to be enabled on the GPUParticles2D
		instance.finished.connect(instance.queue_free)
