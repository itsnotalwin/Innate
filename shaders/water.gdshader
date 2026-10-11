shader_type canvas_item;
varying vec2 world_position;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
	vec4 water = texture(TEXTURE, UV) * COLOR;
	vec2 p = floor(world_position);
	float ripple = sin(p.x * 0.13 + p.y * 0.24 + TIME * 0.55);
	// Broken horizontal glints avoid continuous, laser-like stripes.
	float glint = pow(max(0.0, sin(p.y * 0.32 + sin(p.x * 0.08) * 0.4)), 18.0);
	glint *= smoothstep(0.55, 0.92, sin(p.x * 0.10 + sin(p.y * 0.03)));
	float reflected_sky = 0.5 + 0.5 * sin(p.y * 0.018 + p.x * 0.009);
	water.rgb = mix(water.rgb, vec3(0.34, 0.62, 0.74), 0.32);
	water.rgb += vec3(0.08, 0.09, 0.08) * reflected_sky;
	water.rgb += vec3(0.23, 0.21, 0.13) * glint;
	water.rgb += vec3(0.012, 0.018, 0.020) * ripple;
	COLOR = water;
}
