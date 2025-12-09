extends Node

# -- Configuration --
@export var particle_scene: PackedScene = preload("res://components/note_hit_particles.tscn")

# -- References --
@onready var keyboard: Keyboard = %VisualKeyboard

# -- State --
var keyboard_y: float

func _ready() -> void:
    await keyboard.ready
    keyboard_y = keyboard.position.y

func _on_note_hit_target(note_data: NoteData) -> void:
    var x = keyboard.get_key_x(note_data.pitch)
    var key_size = keyboard.get_key_width(note_data.pitch)
    var particles := particle_scene.instantiate() as GPUParticles2D
    particles.position = Vector2(x, keyboard_y)
    var material := particles.process_material as ParticleProcessMaterial
    material.emission_box_extents.x = key_size / 2
    particles.finished.connect(particles.queue_free)
    particles.emitting = true
    add_child(particles)