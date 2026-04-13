shader_type canvas_item;

instance uniform bool active = true;
uniform vec3 color: source_color = vec3(1.0);

void fragment() {
	if (active) {
		COLOR = vec4(color, COLOR.a);
	}
}
