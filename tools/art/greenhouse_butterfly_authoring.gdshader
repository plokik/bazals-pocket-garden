shader_type canvas_item;
render_mode unshaded;
#include "res://scripts/ui/greenhouse_butterfly_paint.gdshaderinc"
varying vec4 sprite_modulate;

void vertex() {
	sprite_modulate = COLOR;
}

void fragment() {
	// Four subpixel samples smooth moving edges and small painted details.
	vec2 dx = dFdx(UV) * 0.25;
	vec2 dy = dFdy(UV) * 0.25;
	vec4 a = butterfly_paint(TEXTURE, UV - dx - dy);
	vec4 b = butterfly_paint(TEXTURE, UV + dx - dy);
	vec4 c = butterfly_paint(TEXTURE, UV - dx + dy);
	vec4 d = butterfly_paint(TEXTURE, UV + dx + dy);
	float alpha = (a.a + b.a + c.a + d.a) * 0.25;
	vec3 rgb = (a.rgb * a.a + b.rgb * b.a + c.rgb * c.a + d.rgb * d.a) * 0.25;
	COLOR = vec4(rgb / max(alpha, 0.0001), alpha) * sprite_modulate;
}
