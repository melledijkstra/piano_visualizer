extends Node2D

@export var note_scene: PackedScene = preload("res://components/Note.tscn")
@export var fall_speed: float = 350.0 # Pixels per second
@export var debug: bool = false

# -- References --
@onready var keyboard = %VisualKeyboard

# --- State ---
var song: Song = null
var active_notes: Array[NoteNode] = []
var spawn_index: int = 0
var screen_h: float
var note_spawn_offset_time: float = 0.5 # Time offset for spawning notes
var current_time: float
var target_y: float
var target_debug_node: Line2D = null

# -- Signals --
signal finished()

# Calculated property: How many seconds it takes to fall from top to target
var fall_duration: float:
  get:
    return target_y / fall_speed

func _ready() -> void:
  get_viewport().size_changed.connect(_update_target_y)
  _update_target_y()
  if debug:
    setup_debug_line()

func _on_time_updated(_current_time: float) -> void:
  self.current_time = _current_time
  # we reached the end of the song_data, check if there are still notes on the screen
  if spawn_index >= song.notes.size() \
  and active_notes.size() == 0:
    emit_signal("finished")

  # - Check for notes to spawn
  spawn_check()

  # - Move notes
  move_notes()

func spawn_check():
  var look_ahead_time = current_time + fall_duration
  
  while spawn_index < song.notes.size():
    var note = song.notes[spawn_index]
    
    if note.start_time <= look_ahead_time:
      spawn_note(note)
      spawn_index += 1
    else:
      break

func move_notes():
  # Loop backwards so we can remove items safely while iterating
  for i in range(active_notes.size() - 1, -1, -1):
    var note_node = active_notes[i]
    
    # Safety check if node was deleted externally
    if not is_instance_valid(note_node):
        active_notes.remove_at(i)
        continue
    
    var new_y = calculate_note_position(note_node.data)
    note_node.position.y = new_y
    
    # Cleanup: If note is below the screen
    if new_y > screen_h + 50:
        note_node.queue_free()
        active_notes.remove_at(i)

func calculate_note_position(note_data: NoteData) -> float:
  var new_y = target_y - fall_speed * (note_data.start_time - current_time)
  return new_y

func spawn_note(note_data: NoteData):
  if note_scene == null: return
  if keyboard == null: return

  var instance = note_scene.instantiate()
  if debug:
    var label = Label.new()
    label.text = TimeUtils.format_seconds(note_data.start_time)
    label.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
    label.add_theme_font_size_override("font_size", 15)
    instance.add_child(label)
  add_child(instance)
  
  # Get layout from keyboard, this makes sure notes match up with the keyboard
  var key_center_x = keyboard.get_key_x(note_data.pitch)
  var key_width = keyboard.get_key_width(note_data.pitch)
  
  # Setup note
  instance.setup(note_data, key_width, fall_speed)

  # Adjust position
  var y_pos = calculate_note_position(note_data)

  # Centering X (Note.gd setup creates a rect of size.x)
  var x_pos = key_center_x - (instance.size.x / 2.0)

  instance.position = Vector2(x_pos, y_pos)

  active_notes.append(instance)

func setup_debug_line():
  target_debug_node = Line2D.new()
  target_debug_node.width = 2
  target_debug_node.default_color = Color.RED
  target_debug_node.position = Vector2(0, target_y)
  var vp_x = get_viewport_rect().size.x
  target_debug_node.add_point(Vector2(0, 0))
  target_debug_node.add_point(Vector2(vp_x, 0))
  target_debug_node.z_index = 100 # Make sure it's on top
  add_child(target_debug_node)

func _update_target_y() -> void:
  # Recalculate note positions when viewport size changes
  screen_h = get_viewport().get_visible_rect().size.y
  target_y = screen_h
  if keyboard:
    target_y -= keyboard.size.y
  if target_debug_node:
    target_debug_node.position.y = target_y

func _on_song_loaded(song_data: Song) -> void:
  self.song = song_data
  spawn_index = 0
  active_notes.map(func(node): node.queue_free())
  active_notes.clear()

func _on_speed_slider_value_changed(value: float) -> void:
  fall_speed = value
  for node in active_notes:
    if not is_instance_valid(node):
      continue
    node.speed = fall_speed
    node.calculate_height()
