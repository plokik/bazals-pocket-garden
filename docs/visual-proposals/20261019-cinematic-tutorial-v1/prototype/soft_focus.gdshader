shader_type canvas_item;
uniform float blur_pixels = 7.0;
uniform float dim = 0.68;
void fragment() {
    vec2 d = TEXTURE_PIXEL_SIZE * blur_pixels;
    vec4 c = texture(TEXTURE, UV) * 0.20;
    c += texture(TEXTURE, UV + vec2(d.x, 0.0)) * 0.12;
    c += texture(TEXTURE, UV - vec2(d.x, 0.0)) * 0.12;
    c += texture(TEXTURE, UV + vec2(0.0, d.y)) * 0.12;
    c += texture(TEXTURE, UV - vec2(0.0, d.y)) * 0.12;
    c += texture(TEXTURE, UV + d) * 0.08;
    c += texture(TEXTURE, UV - d) * 0.08;
    c += texture(TEXTURE, UV + vec2(d.x, -d.y)) * 0.08;
    c += texture(TEXTURE, UV + vec2(-d.x, d.y)) * 0.08;
    float grey = dot(c.rgb, vec3(0.2126, 0.7152, 0.0722));
    vec3 muted = mix(c.rgb, vec3(grey), 0.50);
    muted = mix(muted, vec3(0.038, 0.095, 0.060), dim);
    float edge = smoothstep(0.25, 0.72, distance(UV, vec2(0.5, 0.45)));
    COLOR = vec4(muted * (1.0 - 0.32 * edge), c.a);
}
