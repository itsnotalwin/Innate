shader_type canvas_item;
varying vec2 world_position;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
	vec4 water = texture(TEXTURE, UV) * COLOR;
	vec2 p = floor(world_position);
	float ripple = sin(p.x * 0.13 + p.y * 0.24 - TIME * 0.9);
	// Broken glints travel downstream instead of sitting still on the water.
	float glint = pow(max(0.0, sin(p.y * 0.22 + sin(p.x * 0.08 + TIME * 0.25) * 0.45 - TIME * 0.75)), 16.0);
	glint *= smoothstep(0.42, 0.92, sin(p.x * 0.13 + sin(p.y * 0.035) + TIME * 0.20));
	float reflected_sky = 0.5 + 0.5 * sin(p.y * 0.018 + p.x * 0.009);
	water.rgb = mix(water.rgb, vec3(0.34, 0.62, 0.74), 0.32);
	water.rgb += vec3(0.08, 0.09, 0.08) * reflected_sky;
	water.rgb += vec3(0.13, 0.13, 0.09) * glint;
	water.rgb += vec3(0.025, 0.032, 0.032) * ripple;
	COLOR = water;
}
