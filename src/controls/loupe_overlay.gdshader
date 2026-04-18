shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear_mipmap;

uniform vec2 lens_center_uv = vec2(0.5, 0.5);
uniform float magnification : hint_range(1.0, 5.0) = 2.0;
uniform float lens_radius : hint_range(16.0, 512.0) = 120.0;
uniform float edge_softness : hint_range(0.5, 32.0) = 4.0;
uniform float rim_width : hint_range(1.0, 32.0) = 8.0;
uniform vec4 rim_color : source_color = vec4(0.85, 0.93, 1.0, 0.95);


void fragment() {
	vec2 local_uv = UV * 2.0 - 1.0;
	float radial_distance = length(local_uv) * lens_radius;
	float lens_mask = 1.0 - smoothstep(lens_radius - edge_softness, lens_radius, radial_distance);
	vec2 sample_uv = lens_center_uv + (SCREEN_UV - lens_center_uv) / magnification;
	sample_uv = clamp(sample_uv, vec2(0.0), vec2(1.0));

	vec4 zoomed_color = textureLod(screen_texture, sample_uv, 0.0);

	float rim_outer = 1.0 - smoothstep(lens_radius - edge_softness, lens_radius, radial_distance);
	float rim_inner = 1.0 - smoothstep(lens_radius - rim_width - edge_softness, lens_radius - rim_width, radial_distance);
	float rim = clamp(rim_inner - rim_outer, 0.0, 1.0);

	vec4 lens_color = mix(zoomed_color, rim_color, rim * rim_color.a);
	lens_color.a = max(lens_mask, rim);

	COLOR = lens_color;
}
