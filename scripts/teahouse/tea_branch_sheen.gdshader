shader_type canvas_item;
render_mode unshaded;

uniform float effect_clock = 0.0;
uniform bool calm = false;
uniform sampler2D branch_texture_image : filter_linear, repeat_disable;
uniform vec4 branch_region = vec4(40.0, 230.0, 1176.0, 266.0);
uniform vec2 atlas_size = vec2(1254.0);
varying vec4 draw_tint;

void vertex() {
	// Draw-command tint, before the fragment samples its texture.
	draw_tint = COLOR;
}

float soft_alpha(sampler2D painted_texture, vec2 texel_size, vec2 uv, float radius) {
	vec2 step_uv = texel_size * vec2(3.5, 4.75) * radius;
	vec2 diagonal = step_uv * 0.707107;
	return (
		texture(painted_texture, uv + vec2(step_uv.x, 0.0)).a + texture(painted_texture, uv - vec2(step_uv.x, 0.0)).a +
		texture(painted_texture, uv + vec2(0.0, step_uv.y)).a + texture(painted_texture, uv - vec2(0.0, step_uv.y)).a +
		texture(painted_texture, uv + diagonal).a + texture(painted_texture, uv - diagonal).a +
		texture(painted_texture, uv + vec2(diagonal.x, -diagonal.y)).a + texture(painted_texture, uv + vec2(-diagonal.x, diagonal.y)).a
	) * 0.125;
}

void fragment() {
	vec4 painted = COLOR;
	vec2 local_uv = (UV * atlas_size - branch_region.xy) / branch_region.zw;
	bool on_branch = all(greaterThanEqual(local_uv, vec2(0.0))) && all(lessThanEqual(local_uv, vec2(1.0)));
	// Leave the bugs, legs, glints and dark contact shadow original.
	bool original_paint = min(draw_tint.r, min(draw_tint.g, draw_tint.b)) > 0.95 && draw_tint.a > 0.95;
	if (!calm && on_branch && original_paint) {
		float phase = mod(effect_clock + 0.45, 7.0);
		float envelope = smoothstep(0.0, 0.18, phase) * (1.0 - smoothstep(1.80, 2.20, phase));
		float front = clamp(phase / 2.20, 0.0, 1.0) * 1.28 - 0.14;
		float distance_to_front = local_uv.x - front + (local_uv.y - 0.5) * 0.07;
		float band = exp(-pow(distance_to_front / 0.085, 2.0)) * envelope;
		vec3 lit_paint = mix(painted.rgb, vec3(1.0, 0.96, 0.70), band * 0.48);
		lit_paint += vec3(0.10, 0.065, 0.018) * band;
		float breath = 0.875 + 0.125 * sin(effect_clock * 6.28318530718 / 7.0);
		float halo = (soft_alpha(branch_texture_image, TEXTURE_PIXEL_SIZE, UV, 1.0) * 0.22 + soft_alpha(branch_texture_image, TEXTURE_PIXEL_SIZE, UV, 2.2) * 0.10) * breath * (1.0 + band * 0.35);
		vec2 inset = vec2(1.0) / vec2(336.0, 56.0);
		vec2 edge = smoothstep(vec2(0.0), inset, local_uv) * (vec2(1.0) - smoothstep(vec2(1.0) - inset, vec2(1.0), local_uv));
		float halo_alpha = halo * (1.0 - painted.a) * edge.x * edge.y;
		float alpha = painted.a + halo_alpha;
		vec3 color = (lit_paint * painted.a + vec3(1.0, 0.78, 0.27) * halo_alpha) / max(alpha, 0.0001);
		COLOR = vec4(color, alpha);
	} else {
		COLOR = painted;
	}
}
