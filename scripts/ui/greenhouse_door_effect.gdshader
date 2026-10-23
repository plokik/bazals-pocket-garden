shader_type canvas_item;
render_mode unshaded;

uniform float handle_angle = 0.0;
uniform float handle_magic_phase = -1.0;
uniform float shine_phase = -1.0;
uniform float focus_strength = 0.0;
uniform float tea_wind_phase = 0.0;
uniform float tea_motion_strength = 0.0;

float lever_mask(vec2 point) {
	// The original painted lever and its round pivot, in source pixels.
	vec2 nearest = vec2(clamp(point.x, 570.0, 602.0), 922.0);
	float capsule = 1.0 - smoothstep(6.0, 8.0, length(point - nearest));
	float pivot = 1.0 - smoothstep(7.0, 9.0, length(point - vec2(606.0, 922.0)));
	return max(capsule, pivot);
}

float magic_star(vec2 relative, float size) {
	vec2 q = abs(relative) / size;
	// Tapered four-point glints, with a tiny soft centre, rather than a halo.
	float cross = 1.0 - smoothstep(0.72, 1.0, pow(q.x, 0.8) + pow(q.y, 0.8));
	float centre = exp(-dot(relative, relative) / (size * size * 0.09));
	return max(cross, centre * 0.38);
}

void fragment() {
	vec2 source_size = vec2(938.0, 1677.0);
	vec2 point = UV * source_size;
	vec2 paint_point = point;
	vec2 paint_uv = UV;
	if (tea_motion_strength > 0.0 && point.x > 8.0 && point.x < 342.0 && point.y > 737.0 && point.y < 1020.0) {
		// Only the approved tea crown moves. The pot, trunk base, doorway,
		// path and remaining painting retain their authored contact points.
		float crown = smoothstep(8.0, 42.0, point.x) * (1.0 - smoothstep(310.0, 342.0, point.x));
		crown *= smoothstep(737.0, 780.0, point.y) * (1.0 - smoothstep(988.0, 1020.0, point.y));
		// Hold the painted window bars behind the foliage perfectly still.
		crown *= smoothstep(10.0, 18.0, abs(point.x - 133.0));
		crown *= smoothstep(8.0, 16.0, abs(point.x - 240.0));
		crown *= smoothstep(8.0, 16.0, abs(point.y - 770.0));
		float breeze = sin(tea_wind_phase) + 0.22 * sin(tea_wind_phase * 2.0 + point.y * 0.021);
		paint_point.x += breeze * 1.6 * crown * tea_motion_strength;
		paint_point.y += sin(tea_wind_phase * 2.0 + point.x * 0.025) * 0.45 * crown * tea_motion_strength;
		paint_uv = paint_point / source_size;
	}
	vec4 painted = texture(TEXTURE, paint_uv);
	if (abs(handle_angle) > 0.0001 && point.x > 554.0 && point.x < 620.0 && point.y > 898.0 && point.y < 952.0) {
		vec2 pivot = vec2(606.0, 922.0);
		float cosine = cos(handle_angle);
		float sine = sin(handle_angle);
		vec2 relative = point - pivot;
		vec2 original = pivot + vec2(cosine * relative.x + sine * relative.y, -sine * relative.x + cosine * relative.y);
		// Fill only the small former lever footprint from adjacent painted
		// pixels; preserve the door, escutcheon and all surrounding artwork.
		float old_mask = lever_mask(point);
		vec4 backing = texture(TEXTURE, (point + vec2(0.0, -19.0)) / source_size);
		painted = mix(painted, backing, old_mask);
		painted = mix(painted, texture(TEXTURE, original / source_size), lever_mask(original));
	}
	if (handle_magic_phase >= 0.0 && handle_magic_phase < 1.0 && length(point - vec2(587.0, 922.0)) < 65.0) {
		float phase = handle_magic_phase;
		float envelope = smoothstep(0.0, 0.18, phase) * (1.0 - smoothstep(0.68, 1.0, phase));
		vec2 centre = vec2(587.0, 922.0);
		vec2 local = (point - centre) / vec2(38.0, 23.0);
		float theta = atan(local.y, local.x);
		float head = -2.8 + phase * 6.2;
		float trail_angle = mod(head - theta + 6.2831853, 6.2831853);
		float trail = (1.0 - smoothstep(0.0, 1.7, trail_angle));
		float line = (1.0 - smoothstep(0.02, 0.075, abs(length(local) - 1.0))) * trail;
		float stars = 0.0;
		for (int index = 0; index < 5; index++) {
			float i = float(index);
			float angle = i * 1.256637 + phase * 1.25;
			vec2 star_position = centre + vec2(cos(angle) * (32.0 + i * 1.2), sin(angle) * 24.0);
			float pulse = 0.5 + 0.5 * sin(phase * 9.0 + i * 1.8);
			stars += magic_star(point - star_position, 6.5 + pulse * 3.0) * pulse;
		}
		vec2 pivot = vec2(606.0, 922.0);
		vec2 relative = point - pivot;
		vec2 original = pivot + vec2(cos(handle_angle) * relative.x + sin(handle_angle) * relative.y, -sin(handle_angle) * relative.x + cos(handle_angle) * relative.y);
		float lever = lever_mask(original) * 0.30;
		float strength = clamp((line * 0.85 + stars + lever) * envelope, 0.0, 0.95);
		vec3 magic_colour = mix(vec3(1.0, 0.88, 0.43), vec3(1.0, 0.99, 0.83), clamp(stars * 2.0, 0.0, 1.0));
		painted.rgb = mix(painted.rgb, magic_colour, strength);
	}
	vec2 glass = (point - vec2(402.0, 614.0)) / vec2(189.0, 438.0);
	if (shine_phase >= 0.0 && shine_phase <= 1.0 && glass.x > 0.0 && glass.x < 1.0 && glass.y > 0.0 && glass.y < 1.0) {
		float center = mix(-0.45, 1.8, shine_phase);
		float distance_to_band = abs(glass.x + glass.y * 0.35 - center);
		float band = 1.0 - smoothstep(0.025, 0.14, distance_to_band);
		float edge = smoothstep(0.0, 0.045, glass.x) * smoothstep(0.0, 0.045, 1.0 - glass.x) * smoothstep(0.0, 0.025, glass.y) * smoothstep(0.0, 0.025, 1.0 - glass.y);
		float fade = sin(shine_phase * 3.14159265);
		painted.rgb = mix(painted.rgb, vec3(1.0, 0.985, 0.82), band * edge * fade * 0.27);
	}
	if (focus_strength > 0.0) {
		vec2 door = abs(point - vec2(494.5, 906.0)) - vec2(137.5, 325.0);
		float border = 1.0 - smoothstep(1.0, 3.0, abs(max(door.x, door.y)));
		painted.rgb = mix(painted.rgb, vec3(0.98, 0.93, 0.62), border * focus_strength);
	}
	COLOR = painted;
}
