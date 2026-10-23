shader_type canvas_item;
render_mode unshaded, blend_mix;

// Interpolate premultiplied paint once, instead of stacking translucent cats.
uniform sampler2D poses : filter_linear, repeat_disable;
uniform sampler2D actions : filter_linear, repeat_disable;
uniform sampler2D life : filter_linear, repeat_disable;
uniform vec2 canvas_size;
uniform vec4 region_a;
uniform vec4 region_b;
uniform vec4 region_previous;
uniform vec2 body_a;
uniform vec2 body_b;
uniform vec2 body_previous;
uniform ivec3 atlases;
uniform vec3 directions;
uniform vec3 weights;
uniform float breath_offset;
varying vec4 paint_modulate;

void vertex() {
	paint_modulate = COLOR;
}

vec4 atlas_paint(sampler2D atlas, vec2 uv, vec4 region) {
	vec2 dimensions = vec2(textureSize(atlas, 0));
	vec2 texel = clamp(region.xy + uv * region.zw, region.xy + vec2(0.5), region.xy + region.zw - vec2(0.5));
	return texture(atlas, texel / dimensions);
}

vec4 frame_paint(vec2 point, vec2 body, vec4 region, int source, float direction) {
	point.x *= direction;
	vec2 uv = (point + vec2(0.0, breath_offset)) / body + vec2(0.5, 1.0);
	if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
		return vec4(0.0);
	}
	vec4 paint;
	if (source == 0) {
		paint = atlas_paint(poses, uv, region);
	} else if (source == 1) {
		paint = atlas_paint(actions, uv, region);
	} else {
		paint = atlas_paint(life, uv, region);
	}
	return vec4(paint.rgb * paint.a, paint.a);
}

void fragment() {
	vec2 point = (UV - vec2(0.5, 1.0)) * canvas_size;
	vec4 paint = frame_paint(point, body_a, region_a, atlases.x, directions.x) * weights.x;
	if (weights.y > 0.0) {
		paint += frame_paint(point, body_b, region_b, atlases.y, directions.y) * weights.y;
	}
	if (weights.z > 0.0) {
		paint += frame_paint(point, body_previous, region_previous, atlases.z, directions.z) * weights.z;
	}
	COLOR = vec4(paint.rgb / max(paint.a, 0.0001), paint.a) * paint_modulate;
}
