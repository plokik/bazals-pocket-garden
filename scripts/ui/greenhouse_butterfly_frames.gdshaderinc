// Twelve painted phases, in the same 4-by-3 sheet layout as the cat poses.
uniform int current_frame = 0;
uniform int next_frame = 1;
uniform float frame_mix = 0.0;

vec2 butterfly_cell(int frame) {
	return vec2(float(frame % 4), float(frame / 4));
}

vec4 butterfly_frame_paint(sampler2D atlas, vec2 point) {
	if (point.x < 0.0 || point.x > 1.0 || point.y < 0.0 || point.y > 1.0) {
		return vec4(0.0);
	}
	vec2 grid = vec2(4.0, 3.0);
	vec4 a = texture(atlas, (butterfly_cell(current_frame) + point) / grid);
	vec4 b = texture(atlas, (butterfly_cell(next_frame) + point) / grid);
	float alpha = mix(a.a, b.a, frame_mix);
	vec3 rgb = mix(a.rgb * a.a, b.rgb * b.a, frame_mix);
	return vec4(rgb / max(alpha, 0.0001), alpha);
}
