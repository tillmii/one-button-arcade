shader_type canvas_item;

uniform float brightness: hint_range(-1.0, 1.0, 0.01) = 0.0;
uniform float contrast: hint_range(-10.0, 10.0, 0.01) = 1.0;
uniform float saturation: hint_range(-10.0, 10.0, 0.01) = 1.0;

mat4 brightness_matrix(float b) {
	return mat4(
		vec4(1, 0, 0, 0),
		vec4(0, 1, 0, 0),
		vec4(0, 0, 1, 0),
		vec4(b, b, b, 1)
	);
}

mat4 contrast_matrix(float c) {
	float t = (1.0 - c) / 2.0;
	return mat4(
		vec4(c, 0, 0, 0),
		vec4(0, c, 0, 0),
		vec4(0, 0, c, 0),
		vec4(t, t, t, 1)
	);
}

mat4 saturation_matrix(float s) {
	vec3 luminance = vec3(0.3086, 0.6094, 0.0820);
	float sr = (1.0 - s) * luminance.r;
	float sg = (1.0 - s) * luminance.g;
	float sb = (1.0 - s) * luminance.b;
	return mat4(
		vec4(sr + s, sr, sr, 0),
		vec4(sg, sg + s, sg, 0),
		vec4(sb, sb, sb + s, 0),
		vec4(0, 0, 0, 1)
	);
}

void fragment() {
	//vec4 color = texture(TEXTURE, UV);
	vec4 color = vec4(1.0);
	color.r = sin(0.2 * TIME) + 1.0;
	color.g = sin(0.4 * TIME) + 1.0;
	color.b = sin(0.6 * TIME) + 1.0;
	mat4 matrix = brightness_matrix(brightness) * contrast_matrix(contrast) * saturation_matrix(saturation);
	COLOR = matrix * color;
}