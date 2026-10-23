shader_type canvas_item;
render_mode unshaded;

uniform sampler2D painted_mask : filter_linear_mipmap, repeat_disable;
uniform vec4 mask_region;
uniform vec2 source_size = vec2(610.0, 515.0);
uniform vec2 bowl_size = vec2(152.0, 126.0);
uniform vec2 quad_size = vec2(208.0, 182.0);
uniform vec2 quad_origin = vec2(0.0);
uniform vec2 visible_size = vec2(300.0, 174.0);
uniform vec4 leaf_tint : source_color = vec4(0.46, 0.80, 0.22, 1.0);
uniform vec4 gold_tint : source_color = vec4(0.99, 0.83, 0.27, 1.0);
uniform float intensity : hint_range(0.0, 1.0) = 0.0;
uniform float elapsed = 0.0;
uniform bool calm = false;

float silhouette(vec2 pixel_offset, float lod) {
	vec2 local_uv = pixel_offset / bowl_size + vec2(0.5);
	vec2 mask_uv = mask_region.xy + local_uv * mask_region.zw;
	if (mask_uv.x < 0.0 || mask_uv.x > 1.0 || mask_uv.y < 0.0 || mask_uv.y > 1.0) {
		return 0.0;
	}
	return textureLod(painted_mask, mask_uv, lod).a;
}

float soft_edge(vec2 point, float radius, float lod) {
	float diagonal = radius * 0.707107;
	return (
		silhouette(point + vec2(radius, 0.0), lod) + silhouette(point - vec2(radius, 0.0), lod) +
		silhouette(point + vec2(0.0, radius), lod) + silhouette(point - vec2(0.0, radius), lod) +
		silhouette(point + vec2(diagonal, diagonal), lod) + silhouette(point - vec2(diagonal, diagonal), lod) +
		silhouette(point + vec2(diagonal, -diagonal), lod) + silhouette(point + vec2(-diagonal, diagonal), lod)
	) * 0.125;
}

void fragment() {
	vec2 point = (UV - vec2(0.5)) * quad_size;
	float painted = silhouette(point, 0.0);
	// A filtered mask smooths the sampled edge instead of forming stepped rings.
	float lod = log2(max(1.0, 6.0 * source_size.x / bowl_size.x));
	float near_edge = soft_edge(point, 4.0, lod);
	float middle_edge = soft_edge(point, 11.0, lod);
	float outer_edge = soft_edge(point, 22.0, lod);
	// Follow the real painted silhouette; leave the bowl itself fully legible.
	float halo = max(near_edge - painted, 0.0) * 0.60 +
		max(middle_edge - painted, 0.0) * 1.40 + max(outer_edge - painted, 0.0) * 0.95;
	float breath = calm ? 1.0 : 0.92 + 0.08 * sin(elapsed * 4.0);
	float warmth = smoothstep(0.1, 0.95, point.y / bowl_size.y + 0.5);
	vec3 tint = mix(leaf_tint.rgb, gold_tint.rgb, warmth);
	vec2 canvas_position = quad_origin + UV * quad_size;
	vec2 edge_fade = smoothstep(vec2(0.0), vec2(7.0), canvas_position) *
		(vec2(1.0) - smoothstep(visible_size - vec2(7.0), visible_size, canvas_position));
	COLOR = vec4(tint, clamp(halo * intensity * breath, 0.0, 0.72) * edge_fade.x * edge_fade.y);
}
