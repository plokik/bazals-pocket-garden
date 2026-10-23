// Shared deformation keeps the light attached to the animated painted silhouette.
uniform float left_wing_open = 1.0;
uniform float right_wing_open = 1.0;
uniform float flap_phase = 0.0;

float butterfly_body_mask(vec2 point) {
	float centre = 1.0 - smoothstep(0.027, 0.036, abs(point.x - 0.5));
	float antennae = (1.0 - smoothstep(0.40, 0.435, point.y)) * (1.0 - smoothstep(0.12, 0.145, abs(point.x - 0.5)));
	return max(centre, antennae);
}

vec2 butterfly_wing_uv(vec2 point) {
	float root_width = 0.030;
	float reach = max(0.0, abs(point.x - 0.5) - root_width);
	float upper = 1.0 - smoothstep(0.50, 0.65, point.y);
	float openness = point.x < 0.5 ? left_wing_open : right_wing_open;
	// Lower wings follow a little later; tips flex while the roots stay fixed.
	float lag = (cos(flap_phase - 0.40) - cos(flap_phase)) * 0.10 * (1.0 - upper);
	float projected_width = clamp(openness + lag, 0.55, 1.0);
	float source_reach = reach / projected_width;
	vec2 source = point;
	if (reach > 0.0) {
		source.x = 0.5 + sign(point.x - 0.5) * (root_width + source_reach);
		float flex = pow(clamp(source_reach / 0.46, 0.0, 1.0), 1.7) * (1.0 - projected_width);
		source.y -= flex * mix(-0.085, 0.125, upper);
	}
	return source;
}

vec4 butterfly_texture(sampler2D paint, vec2 point) {
	if (point.x < 0.0 || point.x > 1.0 || point.y < 0.0 || point.y > 1.0) {
		return vec4(0.0);
	}
	vec4 sampled = texture(paint, point);
	// Suppress faint cutout noise without thresholding the antialiased outline.
	sampled.a *= smoothstep(0.0, 0.10, sampled.a);
	return sampled;
}

vec4 butterfly_paint(sampler2D paint, vec2 point) {
	vec2 wing_uv = butterfly_wing_uv(point);
	vec4 wing = butterfly_texture(paint, wing_uv);
	wing.a *= 1.0 - butterfly_body_mask(wing_uv);
	float openness = point.x < 0.5 ? left_wing_open : right_wing_open;
	wing.rgb *= mix(0.96, 1.0, openness);
	vec4 body = butterfly_texture(paint, point);
	body.a *= butterfly_body_mask(point);
	float alpha = body.a + wing.a * (1.0 - body.a);
	vec3 rgb = body.rgb * body.a + wing.rgb * wing.a * (1.0 - body.a);
	return vec4(rgb / max(alpha, 0.0001), alpha);
}
