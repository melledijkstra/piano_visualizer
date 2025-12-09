extends ColorRect

@export var decay_speed: float = 5.0

var current_intensity: float = 0.0

func _process(delta: float) -> void:
    if current_intensity > 0:
        current_intensity -= decay_speed * delta
        current_intensity = max(current_intensity, 0.0)
        
        # Update opacity based on intensity
        var _material = self.material as ShaderMaterial
        if _material:
            _material.set_shader_parameter("intensity", current_intensity)
    else:
        pass
        visible = false

func hit(p_color: Color = Color.WHITE) -> void:
    visible = true
    current_intensity = 2.0 # Start bright
    
    var _material = self.material as ShaderMaterial
    if _material:
        _material.set_shader_parameter("base_color", p_color)
        _material.set_shader_parameter("intensity", current_intensity)

func _on_note_hit_target(_note_data: NoteData) -> void:
  hit()
