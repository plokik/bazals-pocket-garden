shader_type canvas_item;
render_mode unshaded, blend_mix;

uniform float phase = 0.0;
uniform sampler2D butterfly_texture_image : filter_linear_mipmap, repeat_disable;
#include "res://scripts/ui/greenhouse_butterfly_frames.gdshaderinc"
varying vec4 aura_modulate;

void vertex() {
	aura_modulate = COLOR;
}

void fragment() {
	vec2 p = (UV - vec2(0.5)) * 2.0;
	vec2 painted_uv = (UV - vec2(0.5)) * (1.6 * 320.0 / 362.0) + vec2(0.5);
	float coverage = butterfly_frame_paint(butterfly_texture_image, painted_uv).a;
	float inner_halo = 0.0;
	float outer_halo = 0.0;
	// Blur the actual moving wings instead of lighting an oval behind them.
	for (int i = 0; i < 8; i++) {
		float angle = float(i) * 0.785398;
		vec2 direction = vec2(cos(angle), sin(angle));
		inner_halo += butterfly_frame_paint(butterfly_texture_image, painted_uv + direction * 0.045).a * 0.125;
		outer_halo += butterfly_frame_paint(butterfly_texture_image, painted_uv + direction * 0.105).a * 0.125;
	}
	// A muted green outer rim separates the golden light from bright glass.
	// Mixing colour (rather than only adding white) keeps it visible in daylight.
	float outside = 1.0 - coverage;
	inner_halo = smoothstep(0.0, 0.65, inner_halo) * outside;
	outer_halo = smoothstep(0.0, 0.75, outer_halo) * outside;
	float glints = 0.0;
	for (int i = 0; i < 3; i++) {
		float angle = float(i) * 2.0944 + phase * 0.18;
		vec2 centre = vec2(cos(angle), sin(angle) * 0.80) * 0.60;
		vec2 offset = abs(p - centre);
		float core_width = max(max(fwidth(p.x), fwidth(p.y)) * 0.9, 0.014);
		float cross_light = exp(-pow(offset.x / core_width, 2.0) - pow(offset.y / 0.065, 2.0))
			+ exp(-pow(offset.x / 0.065, 2.0) - pow(offset.y / core_width, 2.0));
		float twinkle = pow(0.5 + 0.5 * sin(phase * 1.6 + float(i) * 2.3), 3.0);
		glints += cross_light * twinkle * 0.65;
	}
	float pulse = 0.90 + 0.10 * sin(phase);
	float inner_alpha = inner_halo * 0.78 * pulse;
	float outer_alpha = outer_halo * 0.52 * pulse;
	vec3 gold = vec3(1.0, 0.84, 0.36);
	vec3 green = vec3(0.24, 0.48, 0.15);
	vec3 rim = mix(green, gold, inner_alpha / max(inner_alpha + outer_alpha * 0.6, 0.0001));
	float brightness = clamp(max(inner_alpha, outer_alpha) + glints, 0.0, 0.90);
	vec3 colour = mix(rim, vec3(1.0, 0.96, 0.70), clamp(glints * 2.0, 0.0, 1.0));
	COLOR = vec4(colour, brightness) * aura_modulate;
}
