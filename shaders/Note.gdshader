shader_type canvas_item;

uniform sampler2D noise_tex : repeat_enable;

uniform vec4 color_a : source_color = vec4(1.0, 0.0, 0.0, 1.0); // Red (Top)
uniform vec4 color_b : source_color = vec4(0.0, 0.0, 1.0, 1.0); // Blue (Bottom)
uniform vec2 node_size = vec2(50.0, 50.0);

void vertex() {
	// Called for every vertex the material is visible on.
    // VERTEX.x = VERTEX.x * 2.0;
}

uniform vec2 scroll_speed = vec2(0.0, 0.5);

void fragment() {
	// Called for every pixel the material is visible on.
    vec2 noise_uv = (UV * node_size * 0.01) + TIME * scroll_speed;
    float noise = texture(noise_tex, noise_uv).r;
    float gradient_factor = UV.y + (noise - 0.5) * 0.2;
    
    // Mixes color_a and color_b based on the gradient_factor
    COLOR = mix(color_a, color_b, clamp(gradient_factor, 0.0, 1.0));
}
