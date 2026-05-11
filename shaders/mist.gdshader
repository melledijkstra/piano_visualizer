//shader_type canvas_item;
//
//// Assign a seamless noise texture here (OpenSimplexNoise is good)
//uniform sampler2D noise_texture1: repeat_enable, filter_nearest;
//uniform sampler2D noise_texture2: repeat_enable, filter_nearest;
//
//// Settings
//uniform vec2 scroll_speed1 = vec2(0.05, 0.0);
//uniform vec2 scroll_speed2 = vec2(-0.03, 0.0); // Move opposite for turbulence
//uniform float density : hint_range(0.0, 1.0) = 0.5;
//uniform vec4 smoke_color : source_color = vec4(0.8, 0.8, 0.8, 1.0);
//
//void fragment() {
	//// Scroll UVs over time
	//vec2 uv1 = UV + TIME * scroll_speed1;
	//vec2 uv2 = UV + TIME * scroll_speed2;
//
	//// Sample noise textures
	//float noise1 = texture(noise_texture1, uv1).r;
	//float noise2 = texture(noise_texture2, uv2).r;
//
	//// Combine noise for a more organic, less repetitive look
	//float combined_noise = (noise1 + noise2) * 0.5;
//
	//// Apply density and soft edges
	//float alpha = smoothstep(1.0 - density, 1.0, combined_noise);
    //
    //// 1. Basic Linear Fade (0 at top, 1 at bottom)
	//float fade_mask = UV.y;
    //
    //// 2. Controlled Fade (Optional: Use smoothstep for a softer transition)
	//// This keeps the top 20% transparent, then fades in until 80% down.
	//// Syntax: smoothstep(edge0, edge1, x)
	//fade_mask = smoothstep(0.0, 0.8, UV.y);
    //
    //// Apply the mask to your calculated alpha
	//alpha *= fade_mask; 
	//
	//COLOR = vec4(smoke_color.rgb, alpha * smoke_color.a);
//}

shader_type canvas_item;

float rand(vec2 n) {
    return fract(cos(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);
}

float noise(vec2 n) {
    vec2 d = vec2(0.0, 1.0);
    vec2 b = floor(n);
    vec2 f = smoothstep(vec2(0.0), vec2(1.0), fract(n));
    return mix(mix(rand(b), rand(b + d.yx), f.x), mix(rand(b + d.xy), rand(b + d.yy), f.x), f.y);
}

float fbm(vec2 n) {
    return noise(n) * 0.5 + noise(n * 2.0) * 0.25 + noise(n * 4.0) * 0.125 + noise(n * 8.0) * 0.065;
}

void fragment() {
    vec2 p = vec2(UV.x + 2.5, -UV.y * 1.0);
    float r = fbm(p - vec2(0.0, fbm(p) + TIME * 0.5));
    COLOR = vec4(r, r, r, UV.y);
}