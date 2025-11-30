shader_type canvas_item;

// The noise textures that will create the flame shape
uniform sampler2D noise_tex : repeat_enable;
uniform sampler2D noise_tex_2 : repeat_enable;

// The color gradient (black -> red -> orange -> yellow)
uniform sampler2D gradient_tex;

// Settings to control the look
uniform vec2 scroll_speed = vec2(0.0, 1.0);
uniform vec2 scroll_speed_2 = vec2(0.0, 0.6);
uniform float fire_strength : hint_range(0.0, 2.0) = 1.0;
uniform float distortion_strength : hint_range(0.0, 1.0) = 0.4;

// Helper to curve the vertical gradient
float uv_curve(float y) {
    return pow(1.0 - y, 1.0); // Invert Y so 0 is top, 1 is bottom
}

void fragment() {
    // 1. Create a base "shape" for the fire using the UV coordinates.
    // This creates a gradient that is white at the bottom (1.0) and black at the top (0.0).
    // We use 'pow' to curve the falloff so it stays hot at the bottom longer.
    float base_shape = uv_curve(UV.y);

    // 2. Sample the two noise textures with different scroll speeds.
    // 'TIME' allows them to move upwards.
    vec2 noise_uv = UV + TIME * scroll_speed;
    vec2 noise_uv_2 = UV + TIME * scroll_speed_2;
    
    float noise_val = texture(noise_tex, noise_uv).r;
    float noise_val_2 = texture(noise_tex_2, noise_uv_2).r;
    
    // Combine noises for a more organic, less repetitive look
    float combined_noise = (noise_val * noise_val_2);

    // 3. Distort the base shape using the noise.
    // We subtract the noise from the base shape to "eat away" at the flame as it goes up.
    float energy = base_shape - (combined_noise * distortion_strength);
    
    // Clamp values to keep them clean
    energy = clamp(energy * fire_strength, 0.0, 1.0);

    // 4. Map the energy value to a color using the gradient texture.
    // vec2(energy, 0.0) samples the gradient from left (0.0) to right (1.0).
    vec4 fire_color = texture(gradient_tex, vec2(energy, 0.0));
    
    // 5. Apply Alpha
    // If the energy is very low (black parts), make it transparent.
    // We use a smoothstep for a softer edge, or just use the gradient's alpha if set.
    fire_color.a *= step(0., energy); // Simple hard cutout
    
    COLOR = fire_color;
}
