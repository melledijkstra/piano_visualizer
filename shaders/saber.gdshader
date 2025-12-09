shader_type canvas_item;

uniform vec4 base_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float intensity = 1.0; 
// Controls how quickly it fades out (higher = faster)
uniform float falloff_exp = 2.0;

void fragment() {
    // Vertical gradient: 1.0 at bottom (UV.y = 1), 0.0 at top (UV.y = 0)
    float vertical_fade = pow(UV.y, falloff_exp);
    
    // Horizontal fade to make it look round/cylindrical
    float dist_from_center = abs(UV.x - 0.5) * 2.0;
    float horizontal_fade = 1.0 - pow(dist_from_center, 3.0);
    
    float alpha = vertical_fade * horizontal_fade * intensity;
    
    COLOR = vec4(base_color.rgb, base_color.a * alpha);
}
