extends Node2D

@onready var particle_scene: PackedScene = preload("res://_debug/sparkle_particles.tscn")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		spawn_explosion(get_global_mouse_position())

func spawn_explosion(pos: Vector2) -> void:
	print(particle_scene)
	if particle_scene:
		# 1. Create a new instance of the particle scene 
		var instance = particle_scene.instantiate()
		
		# 2. Set its position to the click location
		instance.position = pos
		
		# 3. Add it to the scene tree so it becomes visible
		add_child(instance)
		
		# 4. Start the explosion
		instance.emitting = true
		
		# 5. Auto-Cleanup: Delete the node when the particles finish
		# This requires 'One Shot' to be enabled on the GPUParticles2D
		instance.finished.connect(instance.queue_free)