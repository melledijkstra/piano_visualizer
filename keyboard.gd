@tool

class_name Keyboard

extends Control

@export var keyboard_height: float = 150.0:
	set(val):
		keyboard_height = val
		if is_node_ready():
			_update_keys()

var white_key_color = Color.WHITE
var black_key_color = Color.BLACK
var key_dict = {} # pitch: int -> ColorRect

# 88 keys: A0 (21) to C8 (108)
const MIN_PITCH = 21
const MAX_PITCH = 108
const WHITE_KEY_COUNT = 52 # Number of white keys in 88-key range

func _ready():
	# Initial setup with current viewport width
	var vp_size = get_viewport().size
	var width = vp_size.x
	setup(width)

func setup(screen_width: float):
	# Clear existing
	for child in get_children():
		child.queue_free()
	key_dict.clear()

	var white_key_width = screen_width / float(WHITE_KEY_COUNT)
	var black_key_width = white_key_width * 0.6
	var black_key_height = keyboard_height * 0.65

	var white_key_index = 0

	# We iterate through pitches.
	# We need to ensure correct Z-ordering. Black keys should be on top.
	# We can use z_index or just ensure black keys are added after white keys if they overlap?
	# But we are iterating in pitch order.
	# So we use z_index for black keys.

	for pitch in range(MIN_PITCH, MAX_PITCH + 1):
		var is_black = _is_black(pitch)
		var key = ColorRect.new()
		key_dict[pitch] = key

		if is_black:
			key.color = black_key_color
			key.size = Vector2(black_key_width, black_key_height)
			key.z_index = 1
			# Position depends on previous white key index.
			# Since we are in pitch order, white_key_index currently points to the *next* white key slot.
			# But for the calculation, the border is at white_key_index * white_key_width.
			var center_x = white_key_index * white_key_width
			key.position = Vector2(center_x - black_key_width / 2.0, 0)
		else:
			key.color = white_key_color
			# Use a slightly smaller width for visual separation (1px gap)
			key.size = Vector2(white_key_width - 1, keyboard_height)
			key.position = Vector2(white_key_index * white_key_width, 0)
			key.z_index = 0
			white_key_index += 1

		print('added key', pitch, key.position)
		add_child(key)

func _is_black(pitch: int) -> bool:
	var p = pitch % 12
	return p in [1, 3, 6, 8, 10]

func get_key_x(pitch: int) -> float:
	if key_dict.has(pitch):
		var key = key_dict[pitch]
		# Return center X of the key
		return key.position.x + key.size.x / 2.0
	return 0.0

func get_key_width(pitch: int) -> float:
	if key_dict.has(pitch):
		return key_dict[pitch].size.x
	return 0.0

func _update_keys():
	print('_update_keys')
	# If keyboard_height changes, update heights.
	# If width changes, we should recall setup(), but here we handle keyboard_height.
	var black_key_height = self.keyboard_height * 0.65
	for pitch in key_dict:
		var key = key_dict[pitch]
		if _is_black(pitch):
			key.size.y = black_key_height
		else:
			key.size.y = keyboard_height
