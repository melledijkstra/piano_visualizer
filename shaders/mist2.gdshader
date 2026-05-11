shader_type canvas_item;

// --- Uniforms ---
// The noise texture you generated. Important: We set filter_linear_mipmap and repeat_enable for smooth, endless tiling.
uniform sampler2D noise_texture : filter_linear_mipmap, repeat_enable;

// The color and overall transparency of the fog.
// Use grey/blue with low alpha for mist, dark grey for heavy smoke.
uniform vec4 fog_color : source_color = vec4(0.7, 0.7, 0.8, 0.5);

// How fast the fog moves overall.
uniform float speed_factor = 0.1;

// Adjusts how thick the fog appears. Higher values make dark areas fill in.
uniform float density : hint_range(0.5, 3.0) = 1.0;

void fragment() {
	// We create two "layers" of fog moving in different directions and speeds.

	// Layer 1: Moves steadily diagonally.
    // We use the node's base UV and add time multiplied by speed vectors.
	vec2 uv_movement_1 = UV + vec2(TIME * speed_factor, TIME * speed_factor * 0.5);

	// Layer 2: Moves slower and in a slightly opposing direction.
    // This difference creates the churning turbulence effect.
	vec2 uv_movement_2 = UV + vec2(-TIME * speed_factor * 0.4, TIME * speed_factor * 0.8);

	// Sample the red channel of the greyscale noise texture at these new moving coordinates.
	float noise_layer_1 = texture(noise_texture, uv_movement_1).r;
	float noise_layer_2 = texture(noise_texture, uv_movement_2).r;

	// --- Combine Layers ---
	// Multiply the two noise layers together.
	// Where both are white, it stays bright. Where one is dark, the result gets dark.
	// This creates wispy, complex patterns that morph over time.
	float combined_noise = noise_layer_1 * noise_layer_2;

	// Apply density. Multiplying boosts the white values, making it thicker.
	combined_noise = combined_noise * density;

    // Clamp values to ensure we don't exceed reasonable alpha limits.
    combined_noise = clamp(combined_noise, 0.0, 1.0);

	// --- Final Output ---
	// Set the color to our chosen tint.
	COLOR.rgb = fog_color.rgb;
	// Set the alpha based on the combined noise patterns and the tint's master alpha.
	COLOR.a = combined_noise * fog_color.a;
}