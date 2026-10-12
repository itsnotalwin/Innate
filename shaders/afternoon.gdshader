shader_type canvas_item;
render_mode unshaded;
uniform sampler2D world_screen : hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {
	vec2 uv = SCREEN_UV;
	vec3 source = texture(world_screen, uv).rgb;
	float luminance = dot(source, vec3(0.299, 0.587, 0.114));
	// Separate warm highlights from cool shade instead of laying a tint over both.
	vec3 graded = (source - 0.5) * 1.06 + 0.5;
	graded *= mix(vec3(0.90, 0.97, 1.06), vec3(1.08, 1.02, 0.93), smoothstep(0.28, 0.82, luminance));
	vec2 step_size = SCREEN_PIXEL_SIZE * 3.0;
	vec3 halo = max(texture(world_screen, uv + vec2(step_size.x, 0.0)).rgb - 0.79, vec3(0.0));
	halo += max(texture(world_screen, uv - vec2(step_size.x, 0.0)).rgb - 0.79, vec3(0.0));
	halo += max(texture(world_screen, uv + vec2(0.0, step_size.y)).rgb - 0.79, vec3(0.0));
	halo += max(texture(world_screen, uv - vec2(0.0, step_size.y)).rgb - 0.79, vec3(0.0));
	graded += halo * 0.20;
	float edge = smoothstep(0.48, 0.96, length((uv - 0.5) * vec2(0.8, 1.0)));
	COLOR = vec4(clamp(graded * (1.0 - edge * 0.035), 0.0, 1.0), 1.0);
}
