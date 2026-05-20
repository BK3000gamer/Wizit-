shader_type spatial;

render_mode unshaded, depth_test_inverted, depth_draw_never;
stencil_mode read, write, compare_not_equal, 1;

uniform vec3 colour:source_color;

void fragment() {
	ALBEDO = colour;
}