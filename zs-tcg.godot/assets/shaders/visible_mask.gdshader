shader_type canvas_item;

uniform sampler2D mask;

varying vec4 v_vertex_color;

void vertex() {
	v_vertex_color = COLOR;
}

void fragment() {
	COLOR = v_vertex_color * texture(TEXTURE, UV);
	
	vec2 muv = UV;
	muv.y = 1.0 - muv.y;
	COLOR.a = COLOR.a-texture(mask, muv).r;
}
