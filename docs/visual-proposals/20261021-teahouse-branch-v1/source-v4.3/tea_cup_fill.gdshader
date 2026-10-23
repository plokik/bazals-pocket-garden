shader_type canvas_item;
render_mode unshaded;

uniform float fill_ratio : hint_range(0.0, 1.0) = 0.0;
uniform float animation_time = 0.0;
uniform float pour_strength : hint_range(0.0, 1.0) = 0.0;
uniform vec2 mouth_center = vec2(0.469, 0.292);
uniform vec2 mouth_radius = vec2(0.294, 0.098);

void fragment() {
	// CanvasItem fragment COLOR already includes texture and modulation.
	// https://docs.godotengine.org/en/latest/tutorials/shaders/shader_reference/canvas_item_shader.html
	vec4 painted = COLOR;
	vec2 p = (UV - mouth_center) / mouth_radius;
	// The liquid is restricted to the painted inner bowl, inside the gold rim.
	float bowl = 1.0 - smoothstep(0.91, 0.98, dot(p, p));
	float fill = clamp(fill_ratio, 0.0, 1.0);
	float level = mix(0.64, 0.01, fill);
	vec2 surface_radius = mix(vec2(0.45, 0.27), vec2(1.0, 0.95), fill);
	float wave = sin(p.x * 7.0 + animation_time * 2.2) * (0.012 + 0.013 * pour_strength);
	vec2 surface = vec2(p.x / surface_radius.x, (p.y - level + wave) / surface_radius.y);
	float liquid = 1.0 - smoothstep(0.93, 1.0, dot(surface, surface));
	float visible = bowl * liquid * smoothstep(0.005, 0.04, fill_ratio);
	vec3 tea = mix(vec3(0.50, 0.28, 0.09), vec3(0.75, 0.51, 0.18), 0.45 + p.y * 0.25);
	tea += vec3(0.07, 0.05, 0.015) * sin(p.x * 8.0 + animation_time) * 0.16;
	float edge = 1.0 - smoothstep(0.0, 0.07, abs(dot(surface, surface) - 0.94));
	tea += vec3(0.16, 0.13, 0.05) * edge;
	vec2 impact = vec2(p.x, (p.y - level) * 2.2);
	float distance_from_stream = length(impact);
	float ring_phase = fract(distance_from_stream * 1.5 - animation_time * 1.25);
	float ripple = (1.0 - smoothstep(0.025, 0.10, abs(ring_phase - 0.5))) * exp(-distance_from_stream * 1.8);
	tea += vec3(0.14, 0.11, 0.04) * ripple * pour_strength;
	// Retain brush texture and the original alpha; no pixels outside the cup.
	tea *= 0.89 + dot(painted.rgb, vec3(0.2126, 0.7152, 0.0722)) * 0.25;
	COLOR = vec4(mix(painted.rgb, tea, visible), painted.a);
}
