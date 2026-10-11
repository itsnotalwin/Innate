shader_type canvas_item;
render_mode unshaded;

void fragment() {
	vec2 uv = UV;
	// Broad diagonal shafts, not noisy per-pixel sparkle. One inexpensive pass.
	float beam = pow(max(0.0, sin((uv.x + uv.y * 0.55) * 17.0 + 0.7)), 8.0);
	float sunlight = beam * 0.035 + (1.0 - uv.y) * 0.018;
	float edge = smoothstep(0.25, 0.76, length((uv - 0.5) * vec2(0.8, 1.0)));
	vec3 tint = mix(vec3(1.0, 0.85, 0.57), vec3(0.24, 0.32, 0.40), edge);
	COLOR = vec4(tint, sunlight + edge * 0.055);
}
