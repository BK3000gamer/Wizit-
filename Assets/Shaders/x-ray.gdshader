shader_type spatial;
render_mode unshaded, depth_test_disabled;

uniform vec4 colour : source_color = vec4(0.0, 1.0, 1.0, 1.0);
uniform sampler2D depth_texture : hint_depth_texture, repeat_disable, filter_nearest;

uniform float thickness_margin : hint_range(0.0, 5.0) = 1.0;

void fragment() {
	float depth = texture(depth_texture, SCREEN_UV).x;
	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
	vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	view.xyz /= view.w;

	float linear_depth = -view.z;
	float frag_depth = -VERTEX.z;
	if (frag_depth <= linear_depth + thickness_margin) {
		discard;
	}

	ALBEDO = colour.rgb;
	ALPHA = colour.a;
}