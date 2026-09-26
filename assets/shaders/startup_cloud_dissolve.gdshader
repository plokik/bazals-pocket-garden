shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 0.0;

float cloud_noise(vec2 point) {
	vec2 cell = floor(point);
	vec2 local = fract(point);
	local = local * local * (3.0 - 2.0 * local);
	float a = fract(sin(dot(cell, vec2(127.1, 311.7))) * 43758.5453);
	float b = fract(sin(dot(cell + vec2(1.0, 0.0), vec2(127.1, 311.7))) * 43758.5453);
	float c = fract(sin(dot(cell + vec2(0.0, 1.0), vec2(127.1, 311.7))) * 43758.5453);
	float d = fract(sin(dot(cell + vec2(1.0, 1.0), vec2(127.1, 311.7))) * 43758.5453);
	return mix(mix(a, b, local.x), mix(c, d, local.x), local.y);
}

void fragment() {
	vec2 drift = vec2(sin(UV.y * 14.0 + TIME * 1.7) * 0.004, -progress * 0.014);
	vec4 old_screen = texture(TEXTURE, UV + drift * progress);
	float wide_cloud = cloud_noise(UV * vec2(5.0, 8.0) + vec2(TIME * 0.10, -TIME * 0.08));
	float fine_cloud = cloud_noise(UV * vec2(12.0, 18.0) - vec2(TIME * 0.15, 0.0));
	float cloud_front = UV.y * 0.63 + wide_cloud * 0.25 + fine_cloud * 0.12;
	float threshold = progress * 1.28 - 0.14;
	float remaining = smoothstep(threshold - 0.10, threshold + 0.10, cloud_front);
	float mist = 1.0 - smoothstep(0.0, 0.14, abs(cloud_front - threshold));
	COLOR = old_screen;
	COLOR.rgb = mix(COLOR.rgb, vec3(1.0, 0.985, 0.94), mist * 0.72);
	COLOR.a *= remaining;
}
