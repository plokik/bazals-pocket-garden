shader_type canvas_item;

uniform float reveal_x : hint_range(0.0, 1.0) = 0.223;
uniform float badge_rounding : hint_range(0.0, 1.0) = 1.0;

float rounded_rect_mask_pixels(vec2 point, vec2 rect_min, vec2 rect_max, float radius) {
	vec2 center = (rect_min + rect_max) * 0.5;
	vec2 half_size = (rect_max - rect_min) * 0.5;
	vec2 distance_to_edge = abs(point - center) - half_size + vec2(radius);
	float signed_distance = length(max(distance_to_edge, vec2(0.0))) + min(max(distance_to_edge.x, distance_to_edge.y), 0.0) - radius;
	return 1.0 - smoothstep(-1.25, 1.25, signed_distance);
}

void fragment() {
	vec4 sampled_color = texture(TEXTURE, UV) * COLOR;
	vec2 texture_size = 1.0 / TEXTURE_PIXEL_SIZE;
	vec2 pixel_position = UV * texture_size;
	float outer_panel = rounded_rect_mask_pixels(
		pixel_position,
		vec2(31.0, 9.0),
		vec2(914.0, 174.0),
		24.0
	);
	float visible_part = 1.0 - step(reveal_x + 0.0001, UV.x);
	float rounded_badge = rounded_rect_mask_pixels(
		pixel_position,
		vec2(0.0),
		vec2(reveal_x * texture_size.x, texture_size.y),
		22.0
	);
	visible_part *= outer_panel * mix(1.0, rounded_badge, badge_rounding);
	COLOR = sampled_color * visible_part;
}
