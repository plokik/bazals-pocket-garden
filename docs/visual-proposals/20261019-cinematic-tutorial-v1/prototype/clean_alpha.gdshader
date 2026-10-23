shader_type canvas_item;
void fragment() {
    // Suppress generation's low-alpha color islands while retaining a soft edge.
    COLOR.a = smoothstep(0.13, 0.50, COLOR.a);
    float cell_y = fract(UV.y * 3.0);
    COLOR.a *= 1.0 - smoothstep(0.83, 0.99, cell_y);
}
