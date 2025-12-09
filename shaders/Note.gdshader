shader_type canvas_item;

uniform vec4 color_a : source_color = vec4(1.0, 0.0, 0.0, 1.0); // Red (Top)
uniform vec4 color_b : source_color = vec4(0.0, 0.0, 1.0, 1.0); // Blue (Bottom)

void vertex() {
	// Called for every vertex the material is visible on.
    // VERTEX.x = VERTEX.x * 2.0;
}

void fragment() {
	// Called for every pixel the material is visible on.
    float gradient_factor = UV.y;
    
    // Mixes color_a and color_b based on the gradient_factor
    COLOR = mix(color_a, color_b, gradient_factor);
}
