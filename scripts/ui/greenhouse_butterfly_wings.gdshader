shader_type canvas_item;
render_mode unshaded;
uniform sampler2D butterfly_texture_image : filter_linear_mipmap, repeat_disable;
#include "res://scripts/ui/greenhouse_butterfly_frames.gdshaderinc"
varying vec4 sprite_modulate;

void vertex() {
	sprite_modulate = COLOR;
}

void fragment() {
	vec2 grid = vec2(4.0, 3.0);
	vec2 point = UV * grid - butterfly_cell(current_frame);
	vec2 dx = dFdx(UV) * grid * 0.25;
	vec2 dy = dFdy(UV) * grid * 0.25;
	vec4 a = butterfly_frame_paint(butterfly_texture_image, point - dx - dy);
	vec4 b = butterfly_frame_paint(butterfly_texture_image, point + dx - dy);
	vec4 c = butterfly_frame_paint(butterfly_texture_image, point - dx + dy);
	vec4 d = butterfly_frame_paint(butterfly_texture_image, point + dx + dy);
	float alpha = (a.a + b.a + c.a + d.a) * 0.25;
	vec3 rgb = (a.rgb * a.a + b.rgb * b.a + c.rgb * c.a + d.rgb * d.a) * 0.25;
	COLOR = vec4(rgb / max(alpha, 0.0001), alpha) * sprite_modulate;
}
