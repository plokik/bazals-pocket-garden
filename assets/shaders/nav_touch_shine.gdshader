shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 1.0;
uniform float strength : hint_range(0.0, 1.0) = 0.72;

void fragment() {
	float diagonal_position = UV.x + (UV.y - 0.5) * 0.32;
	float shine_center = mix(-0.24, 1.24, progress);
	float shine_band = 1.0 - smoothstep(0.035, 0.18, abs(diagonal_position - shine_center));
	float lifetime_fade = sin(progress * 3.14159265);
	float vertical_softness = smoothstep(0.0, 0.10, UV.y) * smoothstep(0.0, 0.10, 1.0 - UV.y);
	float alpha = shine_band * lifetime_fade * vertical_softness * strength;
	COLOR = vec4(1.0, 0.97, 0.73, alpha);
}
