@tool

class_name Keyboard extends Control

# 88 keys: A0 (21) to C8 (108)
const MIN_PITCH = 21
const MAX_PITCH = 108
const WHITE_KEY_COUNT = 52 # Number of white keys in 88-key range

# -- Configuration --
@export_color_no_alpha var white_key_color = Color.WHITE
@export_color_no_alpha var black_key_color = Color.BLACK
@export var show_labels: bool = true

# -- State --
## pitch -> key node
var key_nodes: Dictionary[int, ColorRect] = {}

func _ready():
    print('[keyboard] self.size: ', self.size)
    var width = self.size.x
    setup(width)

func _reset():
    # Clear existing
    for child in get_children():
        child.queue_free()
    key_nodes.clear()

func setup(available_width: float):
    self._reset()

    var white_key_width = available_width / float(WHITE_KEY_COUNT)
    var black_key_width = white_key_width * 0.6
    var black_key_height = self.size.y * 0.65

    var white_key_index = 0

    # We iterate through pitches.
    # We need to ensure correct Z-ordering. Black keys should be on top.
    # We can use z_index or just ensure black keys are added after white keys if they overlap?
    # But we are iterating in pitch order.
    # So we use z_index for black keys.

    for pitch in range(MIN_PITCH, MAX_PITCH + 1):
        var is_black = _is_black(pitch)
        var key = ColorRect.new()

        if show_labels:
            add_note_label(pitch, key)

        key_nodes[pitch] = key

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
            # Round to nearest pixel to avoid jagged sub-pixel rendering artifacts
            var pos_x = round(white_key_index * white_key_width)
            var next_pos_x = round((white_key_index + 1) * white_key_width)
            key.size = Vector2(next_pos_x - pos_x - 1, self.size.y)
            key.position = Vector2(pos_x, 0)
            key.z_index = 0
            white_key_index += 1
        add_child(key)

func add_note_label(pitch: int, parent: ColorRect):
    var key_name: String = pitch_to_key_name(pitch)
    # only label natural C keys (avoid the sharps)
    if not key_name.contains('C') or key_name.contains('#'):
        return

    # create a label to display the note name
    var label = Label.new()
    label.set_anchors_preset(Control.PRESET_TOP_LEFT)
    label.add_theme_font_size_override("font_size", 15)
    # Contrast color
    label.modulate = Color(0, 0, 0, 1)
    label.text = key_name
    parent.add_child(label)

func pitch_octave(pitch: int) -> int:
    return floor((pitch - Globals.NOTES_IN_OCTAVE) / Globals.NOTES_IN_OCTAVE)

func _is_black(pitch: int) -> bool:
    var p = pitch % 12
    return p in [1, 3, 6, 8, 10]

"""
Returns the name of the key for this pitch
"""
func pitch_to_key_name(pitch: int, with_octave: bool = true) -> String:
    var key_index = pitch % Globals.NOTES_IN_OCTAVE

    if not with_octave:
        return Globals.NOTE_NAMES[key_index]

    var octave: int = pitch_octave(pitch)
    # 88 keys: A0 (21) to C8 (108)
    return "%s%d" % [Globals.NOTE_NAMES[key_index], octave]

func get_key_x(pitch: int) -> float:
    if key_nodes.has(pitch):
        var key = key_nodes[pitch]
        # Return center X of the key
        return key.position.x + key.size.x / 2.0
    return 0.0

func get_key_width(pitch: int) -> float:
    if key_nodes.has(pitch):
        return key_nodes[pitch].size.x
    return 0.0
