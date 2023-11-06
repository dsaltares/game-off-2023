shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_lambert, specular_schlick_ggx;

instance uniform float tiling : hint_range(0.1, 100) = 5.0;
instance uniform vec4 water_color : source_color = vec4(0.200, 0.486, 1.000, 0.800000);

uniform sampler2D noise;
uniform sampler2D depth : hint_depth_texture;


void vertex() {
	vec2 uv = TIME / tiling * vec2(0.1, 0.1) + UV * tiling;
	vec4 noise_sample = texture(noise, uv);
	float max_height = 0.8;
	vec3 clamped_normal = NORMAL * max_height;
	VERTEX = fma(
		noise_sample,
		vec4(clamped_normal, 0.0),
		vec4(VERTEX, 0.0)
	).xyz;
}

float get_proximity_fade(vec2 screen_uv, mat4 inv_projection_matrix, vec3 vertex) {
	float depth_sample = texture(depth, screen_uv).r;
	vec4 depth_world_pos = inv_projection_matrix * vec4(screen_uv * 2.0 - 1.0, depth_sample, 1.0);
	depth_world_pos.xyz /= depth_world_pos.w;
	float max_value = 1.00000;
	return clamp(1.0 - smoothstep(depth_world_pos.z + max_value, depth_world_pos.z, vertex.z), 0.0, 1.0);
}

void fragment() {
	vec2 first_uv = TIME * vec2(0.10, 0.02) + UV * tiling;
	vec2 second_uv = TIME * vec2(-0.02, -0.10) + UV * tiling;
	vec4 first_sample = texture(noise, first_uv);
	vec4 second_sample = texture(noise, second_uv);
	vec4 combined_noise = pow(first_sample * second_sample, vec4(1.25));
	vec4 water_with_noise = water_color + combined_noise;
	
	float proximity_fade = 1.0 - get_proximity_fade(
		SCREEN_UV,
		INV_PROJECTION_MATRIX,
		VERTEX
	);
	float ripple_mask = abs(sin(4.0 * fma(TIME, 0.5, proximity_fade))) * proximity_fade;
	float rim_mask = pow(proximity_fade, 16);
	float mask = ripple_mask + rim_mask;

	ALBEDO = mix(water_with_noise, vec4(1.0, 1.0, 1.0, 1.0), mask).rgb;
	ALPHA = water_color.a;
	EMISSION = combined_noise.rgb;
	ROUGHNESS = 0.0;
}
