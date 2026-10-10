shader_type canvas_item;

// Recolour only the control's own paint. Child illustrations stay untouched.
uniform bool primary_action = false;
uniform bool unify_action_accent = false;
uniform bool text_only = false;
uniform bool restrict_regions = false;
uniform bool room_action_text = false;
uniform vec2 native_icon_pixel_size = vec2(0.0);
uniform vec4 region_a = vec4(0.0);
uniform vec4 region_b = vec4(0.0);
uniform vec4 region_c = vec4(0.0);
uniform vec4 exclude_a = vec4(0.0);
uniform vec4 exclude_b = vec4(0.0);
uniform vec4 exclude_c = vec4(0.0);
varying vec2 local_position;

void vertex() { local_position = VERTEX; }

bool inside(vec4 r) {
    return r.z > 0.0 && r.w > 0.0 && local_position.x >= r.x && local_position.y >= r.y && local_position.x <= r.x+r.z && local_position.y <= r.y+r.w;
}

bool action_text_band(vec4 r) {
    return inside(r) && local_position.y > r.y + r.w * 0.35 && local_position.y < r.y + r.w * 0.69 && local_position.x > r.x + 6.0 && local_position.x < r.x + r.z - 6.0;
}

void fragment() {
    vec4 original = COLOR;
    float light = dot(original.rgb, vec3(0.299, 0.587, 0.114));
    float warm = step(original.b + 0.055, original.g) * step(original.g + 0.055, original.r);
    float warning = step(original.g+0.15,original.r) * step(original.b+0.15,original.r) * (1.0-smoothstep(0.55,0.80,original.g));
    if (text_only) {
        // Preserve amber/red warnings and light lettering on dark plaques.
        float text_mask = (1.0 - warm) * (1.0-warning) * (1.0 - smoothstep(0.65,0.80,light));
        COLOR = vec4(mix(original.rgb, vec3(0.14,0.23,0.17),text_mask),original.a);
    } else {
        bool native_icon = native_icon_pixel_size.x > 0.0 && all(lessThan(abs(TEXTURE_PIXEL_SIZE-native_icon_pixel_size),vec2(0.000001)));
        bool region = !native_icon && (!restrict_regions || inside(region_a) || inside(region_b) || inside(region_c));
        if (region && !inside(exclude_a) && !inside(exclude_b) && !inside(exclude_c)) {
            // Keep warm wood, dark linework and the original painted gloss.
            float wood = unify_action_accent ? 0.0 : warm * (1.0 - smoothstep(0.67,0.84,light));
            float action_warning = unify_action_accent ? 0.0 : warning;
            float mask = smoothstep(0.16,0.28,light) * (1.0 - wood) * (1.0-action_warning);
            vec3 sage = mix(vec3(0.18,0.29,0.16),vec3(0.71,0.82,0.55),smoothstep(0.16,0.50,light));
            sage = mix(sage,vec3(0.94,0.97,0.84),smoothstep(0.67,0.94,light));
            if (primary_action) {
                sage = mix(sage,vec3(0.46,0.68,0.30),0.34 * (1.0-smoothstep(0.85,0.98,light)));
            }
            sage = mix(sage,vec3(1.0),smoothstep(0.95,1.0,light));
            if (room_action_text && (action_text_band(region_b) || action_text_band(region_c))) {
                sage = mix(sage,vec3(0.14,0.23,0.17),smoothstep(0.46,0.85,light));
                mask = max(mask,smoothstep(0.46,0.85,light));
            }
            COLOR = vec4(mix(original.rgb,sage,mask),original.a);
        }
    }
}
